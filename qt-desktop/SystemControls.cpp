#include "SystemControls.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>
#include <QStandardPaths>

#include <algorithm>

SystemControls::SystemControls(QObject *parent)
    : QObject(parent)
{
    m_nmcliPath = QStandardPaths::findExecutable(QStringLiteral("nmcli"));
    m_wpctlPath = QStandardPaths::findExecutable(QStringLiteral("wpctl"));
    m_pactlPath = QStandardPaths::findExecutable(QStringLiteral("pactl"));
    m_bluetoothctlPath = QStandardPaths::findExecutable(QStringLiteral("bluetoothctl"));

    m_wifiAvailable = !m_nmcliPath.isEmpty();
    m_audioBackend = !m_wpctlPath.isEmpty() ? QStringLiteral("wpctl")
                    : (!m_pactlPath.isEmpty() ? QStringLiteral("pactl") : QString());
    m_audioAvailable = !m_audioBackend.isEmpty();
    m_bluetoothAvailable = !m_bluetoothctlPath.isEmpty();

    connect(&m_wifiProcess,
            qOverload<int, QProcess::ExitStatus>(&QProcess::finished),
            this, &SystemControls::handleWifiFinished);
    connect(&m_audioProcess,
            qOverload<int, QProcess::ExitStatus>(&QProcess::finished),
            this, &SystemControls::handleAudioFinished);
    connect(&m_bluetoothProcess,
            qOverload<int, QProcess::ExitStatus>(&QProcess::finished),
            this, &SystemControls::handleBluetoothFinished);

    m_refreshTimer.setInterval(7000);
    m_refreshTimer.setTimerType(Qt::CoarseTimer);
    connect(&m_refreshTimer, &QTimer::timeout, this, &SystemControls::refresh);

    refresh();
    m_refreshTimer.start();
}

bool SystemControls::wifiAvailable() const { return m_wifiAvailable; }
bool SystemControls::wifiKnown() const { return m_wifiKnown; }
bool SystemControls::wifiEnabled() const { return m_wifiEnabled; }
bool SystemControls::wifiBusy() const { return m_wifiProcess.state() != QProcess::NotRunning; }

QString SystemControls::wifiStatus() const
{
    if (!m_wifiAvailable)
        return QStringLiteral("NetworkManager unavailable");
    if (wifiBusy())
        return QStringLiteral("Updating…");
    if (!m_wifiKnown)
        return QStringLiteral("Checking…");
    return m_wifiEnabled ? QStringLiteral("On") : QStringLiteral("Off");
}

bool SystemControls::audioAvailable() const { return m_audioAvailable; }
bool SystemControls::audioKnown() const { return m_audioKnown; }
bool SystemControls::audioMuted() const { return m_audioMuted; }
bool SystemControls::audioBusy() const { return m_audioProcess.state() != QProcess::NotRunning; }
int SystemControls::volume() const { return m_volume; }

QString SystemControls::audioStatus() const
{
    if (!m_audioAvailable)
        return QStringLiteral("Audio service unavailable");
    if (audioBusy())
        return QStringLiteral("Updating…");
    if (!m_audioKnown)
        return QStringLiteral("No default output");
    return m_audioMuted ? QStringLiteral("Muted") : QStringLiteral("%1%").arg(m_volume);
}

bool SystemControls::bluetoothAvailable() const { return m_bluetoothAvailable; }
bool SystemControls::bluetoothKnown() const { return m_bluetoothKnown; }
bool SystemControls::bluetoothBusy() const { return m_bluetoothProcess.state() != QProcess::NotRunning; }
bool SystemControls::bluetoothPowered() const { return m_bluetoothPowered; }

QString SystemControls::bluetoothStatus() const
{
    if (!m_bluetoothAvailable)
        return QStringLiteral("Bluetooth service not installed");
    if (bluetoothBusy())
        return QStringLiteral("Updating…");
    if (!m_bluetoothKnown)
        return QStringLiteral("No controller detected");
    return m_bluetoothPowered ? QStringLiteral("On") : QStringLiteral("Off");
}

bool SystemControls::batteryAvailable() const { return m_batteryAvailable; }
int SystemControls::batteryPercent() const { return m_batteryPercent; }
QString SystemControls::batteryStatus() const
{
    if (!m_batteryAvailable)
        return QStringLiteral("No battery detected");
    return QStringLiteral("%1% · %2").arg(m_batteryPercent).arg(m_batteryStatus);
}

bool SystemControls::brightnessAvailable() const { return m_brightnessAvailable; }
bool SystemControls::brightnessWritable() const { return m_brightnessWritable; }
int SystemControls::brightness() const { return m_brightness; }

QString SystemControls::brightnessStatus() const
{
    if (!m_brightnessAvailable)
        return QStringLiteral("No backlight device");
    if (!m_brightnessWritable)
        return QStringLiteral("Read-only for this user");
    return QStringLiteral("%1%").arg(m_brightness);
}

void SystemControls::refresh()
{
    refreshWifi();
    refreshAudio();
    refreshBluetooth();
    refreshBattery();
    refreshBrightness();
    emit stateChanged();
}

void SystemControls::refreshWifi()
{
    if (!m_wifiAvailable || m_wifiProcess.state() != QProcess::NotRunning)
        return;

    m_wifiOperation = QStringLiteral("query");
    m_wifiProcess.start(m_nmcliPath,
                        {QStringLiteral("-t"),
                         QStringLiteral("-f"), QStringLiteral("WIFI"),
                         QStringLiteral("general")});
}

void SystemControls::refreshAudio()
{
    if (!m_audioAvailable || m_audioProcess.state() != QProcess::NotRunning)
        return;

    if (m_audioBackend == QStringLiteral("wpctl")) {
        m_audioOperation = QStringLiteral("query-wpctl");
        m_audioProcess.start(m_wpctlPath,
                             {QStringLiteral("get-volume"),
                              QStringLiteral("@DEFAULT_AUDIO_SINK@")});
    } else {
        m_audioOperation = QStringLiteral("query-pactl");
        m_audioProcess.start(m_pactlPath,
                             {QStringLiteral("get-sink-volume"),
                              QStringLiteral("@DEFAULT_SINK@")});
    }
}

void SystemControls::refreshBluetooth()
{
    if (!m_bluetoothAvailable ||
        m_bluetoothProcess.state() != QProcess::NotRunning)
        return;

    m_bluetoothOperation = QStringLiteral("query");
    m_bluetoothProcess.start(m_bluetoothctlPath, {QStringLiteral("show")});
}

void SystemControls::refreshBattery()
{
    const QDir powerSupplyDirectory(QStringLiteral("/sys/class/power_supply"));
    const QStringList devices = powerSupplyDirectory.entryList(
        QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);

    m_batteryAvailable = false;
    m_batteryPercent = 0;
    m_batteryStatus.clear();

    for (const QString &device : devices) {
        const QString base = powerSupplyDirectory.filePath(device);
        QFile typeFile(base + QStringLiteral("/type"));
        if (!typeFile.open(QIODevice::ReadOnly) ||
            typeFile.readAll().trimmed() != QByteArrayLiteral("Battery"))
            continue;

        QFile capacityFile(base + QStringLiteral("/capacity"));
        QFile statusFile(base + QStringLiteral("/status"));
        if (!capacityFile.open(QIODevice::ReadOnly) ||
            !statusFile.open(QIODevice::ReadOnly))
            continue;

        bool valueOk = false;
        const int capacity = capacityFile.readAll().trimmed().toInt(&valueOk);
        if (!valueOk || capacity < 0 || capacity > 100)
            continue;

        m_batteryPercent = capacity;
        m_batteryStatus = QString::fromLocal8Bit(statusFile.readAll().trimmed());
        if (m_batteryStatus.isEmpty())
            m_batteryStatus = QStringLiteral("Unknown");
        m_batteryAvailable = true;
        break;
    }
}

void SystemControls::refreshBrightness()
{
    const QDir backlightDirectory(QStringLiteral("/sys/class/backlight"));
    const QStringList devices = backlightDirectory.entryList(
        QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);

    m_brightnessAvailable = false;
    m_brightnessWritable = false;
    m_brightnessPath.clear();
    m_brightnessMaximum = 0;

    for (const QString &device : devices) {
        const QString base = backlightDirectory.filePath(device);
        const QString valuePath = base + QStringLiteral("/brightness");
        const QString maximumPath = base + QStringLiteral("/max_brightness");

        QFile valueFile(valuePath);
        QFile maximumFile(maximumPath);
        if (!valueFile.open(QIODevice::ReadOnly) ||
            !maximumFile.open(QIODevice::ReadOnly))
            continue;

        bool valueOk = false;
        bool maximumOk = false;
        const qint64 value = valueFile.readAll().trimmed().toLongLong(&valueOk);
        const qint64 maximum = maximumFile.readAll().trimmed().toLongLong(&maximumOk);
        if (!valueOk || !maximumOk || maximum <= 0)
            continue;

        m_brightnessPath = valuePath;
        m_brightnessMaximum = maximum;
        m_brightness = static_cast<int>(std::clamp<qint64>(
            (value * 100 + maximum / 2) / maximum, 0, 100));
        m_brightnessAvailable = true;
        m_brightnessWritable = QFileInfo(valuePath).isWritable();
        break;
    }
}

void SystemControls::toggleWifi()
{
    if (!m_wifiAvailable || wifiBusy())
        return;

    m_wifiOperation = QStringLiteral("toggle");
    const QString target = m_wifiEnabled ? QStringLiteral("off")
                                          : QStringLiteral("on");
    emit stateChanged();
    m_wifiProcess.start(m_nmcliPath,
                        {QStringLiteral("radio"), QStringLiteral("wifi"), target});
}

void SystemControls::setVolume(int percent)
{
    if (!m_audioAvailable || audioBusy())
        return;

    const int clamped = std::clamp(percent, 0, 100);
    m_audioOperation = QStringLiteral("set-volume");

    if (m_audioBackend == QStringLiteral("wpctl")) {
        m_audioProcess.start(m_wpctlPath,
                             {QStringLiteral("set-volume"),
                              QStringLiteral("@DEFAULT_AUDIO_SINK@"),
                              QStringLiteral("%1%").arg(clamped)});
    } else {
        m_audioProcess.start(m_pactlPath,
                             {QStringLiteral("set-sink-volume"),
                              QStringLiteral("@DEFAULT_SINK@"),
                              QStringLiteral("%1%").arg(clamped)});
    }
}

void SystemControls::toggleMute()
{
    if (!m_audioAvailable || audioBusy())
        return;

    m_audioOperation = QStringLiteral("toggle-mute");
    if (m_audioBackend == QStringLiteral("wpctl")) {
        m_audioProcess.start(m_wpctlPath,
                             {QStringLiteral("set-mute"),
                              QStringLiteral("@DEFAULT_AUDIO_SINK@"),
                              m_audioMuted ? QStringLiteral("0") : QStringLiteral("1")});
    } else {
        m_audioProcess.start(m_pactlPath,
                             {QStringLiteral("set-sink-mute"),
                              QStringLiteral("@DEFAULT_SINK@"),
                              m_audioMuted ? QStringLiteral("0") : QStringLiteral("1")});
    }
}

void SystemControls::toggleBluetooth()
{
    if (!m_bluetoothAvailable || !m_bluetoothKnown || bluetoothBusy())
        return;

    m_bluetoothOperation = QStringLiteral("toggle");
    const QString target = m_bluetoothPowered ? QStringLiteral("off")
                                               : QStringLiteral("on");
    emit stateChanged();
    m_bluetoothProcess.start(m_bluetoothctlPath,
                             {QStringLiteral("power"), target});
}

void SystemControls::setBrightness(int percent)
{
    if (!m_brightnessAvailable || !m_brightnessWritable ||
        m_brightnessMaximum <= 0 || m_brightnessPath.isEmpty())
        return;

    const int clamped = std::clamp(percent, 0, 100);
    const qint64 rawValue =
        (static_cast<qint64>(clamped) * m_brightnessMaximum + 50) / 100;

    QFile file(m_brightnessPath);
    if (!file.open(QIODevice::WriteOnly)) {
        emit operationFailed(QStringLiteral("Could not change display brightness: permission denied."));
        return;
    }

    const QByteArray value = QByteArray::number(rawValue);
    if (file.write(value) != value.size()) {
        emit operationFailed(QStringLiteral("Could not write the display brightness value."));
        return;
    }

    m_brightness = clamped;
    emit stateChanged();
}

void SystemControls::handleWifiFinished(int exitCode, QProcess::ExitStatus status)
{
    const QString operation = m_wifiOperation;
    const QByteArray output = m_wifiProcess.readAllStandardOutput();
    const QString error = QString::fromLocal8Bit(m_wifiProcess.readAllStandardError()).trimmed();
    m_wifiOperation.clear();

    if (operation == QStringLiteral("query")) {
        if (status == QProcess::NormalExit && exitCode == 0) {
            const QString result = QString::fromLocal8Bit(output).trimmed().toLower();
            m_wifiKnown = result == QStringLiteral("enabled") ||
                          result == QStringLiteral("disabled");
            if (m_wifiKnown)
                m_wifiEnabled = result == QStringLiteral("enabled");
        } else {
            m_wifiKnown = false;
        }
    } else if (operation == QStringLiteral("toggle")) {
        if (status != QProcess::NormalExit || exitCode != 0) {
            emit operationFailed(error.isEmpty()
                ? QStringLiteral("NetworkManager could not change Wi-Fi state.")
                : error);
        }
        refreshWifi();
    }

    emit stateChanged();
}

void SystemControls::handleAudioFinished(int exitCode, QProcess::ExitStatus status)
{
    const QString operation = m_audioOperation;
    const QByteArray output = m_audioProcess.readAllStandardOutput();
    const QString error = QString::fromLocal8Bit(m_audioProcess.readAllStandardError()).trimmed();
    m_audioOperation.clear();

    if (operation == QStringLiteral("query-wpctl")) {
        if (status == QProcess::NormalExit && exitCode == 0) {
            const QString result = QString::fromLocal8Bit(output);
            const QRegularExpression volumePattern(QStringLiteral(R"(Volume:\s*([0-9]+(?:\.[0-9]+)?))"));
            const auto match = volumePattern.match(result);
            if (match.hasMatch()) {
                const double value = match.captured(1).toDouble();
                m_volume = std::clamp(static_cast<int>(value * 100.0 + 0.5), 0, 100);
                m_audioMuted = result.contains(QStringLiteral("[MUTED]"));
                m_audioKnown = true;
            } else {
                m_audioKnown = false;
            }
        } else {
            m_audioKnown = false;
        }
    } else if (operation == QStringLiteral("query-pactl")) {
        if (status == QProcess::NormalExit && exitCode == 0) {
            const QString result = QString::fromLocal8Bit(output);
            const QRegularExpression volumePattern(QStringLiteral(R"(/\s*([0-9]{1,3})%/)"));
            const auto match = volumePattern.match(result);
            if (match.hasMatch()) {
                m_volume = std::clamp(match.captured(1).toInt(), 0, 100);
                m_audioKnown = true;
                m_audioOperation = QStringLiteral("query-pactl-mute");
                m_audioProcess.start(m_pactlPath,
                                     {QStringLiteral("get-sink-mute"),
                                      QStringLiteral("@DEFAULT_SINK@")});
                return;
            }
            m_audioKnown = false;
        } else {
            m_audioKnown = false;
        }
    } else if (operation == QStringLiteral("query-pactl-mute")) {
        const QString result = QString::fromLocal8Bit(output).trimmed().toLower();
        if (status == QProcess::NormalExit && exitCode == 0) {
            m_audioMuted = result.contains(QStringLiteral("yes"));
            m_audioKnown = true;
        } else {
            m_audioKnown = false;
        }
    } else if (operation == QStringLiteral("set-volume") ||
               operation == QStringLiteral("toggle-mute")) {
        if (status != QProcess::NormalExit || exitCode != 0) {
            emit operationFailed(error.isEmpty()
                ? QStringLiteral("The audio service could not apply the requested setting.")
                : error);
        }
        refreshAudio();
    }

    emit stateChanged();
}

void SystemControls::handleBluetoothFinished(int exitCode, QProcess::ExitStatus status)
{
    const QString operation = m_bluetoothOperation;
    const QString output = QString::fromLocal8Bit(m_bluetoothProcess.readAllStandardOutput());
    const QString error = QString::fromLocal8Bit(m_bluetoothProcess.readAllStandardError()).trimmed();
    m_bluetoothOperation.clear();

    if (operation == QStringLiteral("query")) {
        if (status == QProcess::NormalExit && exitCode == 0 &&
            output.contains(QStringLiteral("Powered:"), Qt::CaseInsensitive)) {
            m_bluetoothKnown = true;
            m_bluetoothPowered = output.contains(
                QRegularExpression(QStringLiteral(R"(Powered:\s*yes)"),
                                   QRegularExpression::CaseInsensitiveOption));
        } else {
            m_bluetoothKnown = false;
            m_bluetoothPowered = false;
            if (!error.isEmpty() &&
                !error.contains(QStringLiteral("No default controller"), Qt::CaseInsensitive)) {
                emit operationFailed(error);
            }
        }
    } else if (operation == QStringLiteral("toggle")) {
        if (status != QProcess::NormalExit || exitCode != 0) {
            emit operationFailed(error.isEmpty()
                ? QStringLiteral("Bluetooth could not change power state.")
                : error);
        }
        refreshBluetooth();
    }

    emit stateChanged();
}
