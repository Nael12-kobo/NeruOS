#pragma once

#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QString>

class SystemControls final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool wifiAvailable READ wifiAvailable NOTIFY stateChanged)
    Q_PROPERTY(bool wifiKnown READ wifiKnown NOTIFY stateChanged)
    Q_PROPERTY(bool wifiEnabled READ wifiEnabled NOTIFY stateChanged)
    Q_PROPERTY(bool wifiBusy READ wifiBusy NOTIFY stateChanged)
    Q_PROPERTY(QString wifiStatus READ wifiStatus NOTIFY stateChanged)

    Q_PROPERTY(bool audioAvailable READ audioAvailable NOTIFY stateChanged)
    Q_PROPERTY(bool audioKnown READ audioKnown NOTIFY stateChanged)
    Q_PROPERTY(bool audioMuted READ audioMuted NOTIFY stateChanged)
    Q_PROPERTY(bool audioBusy READ audioBusy NOTIFY stateChanged)
    Q_PROPERTY(int volume READ volume NOTIFY stateChanged)
    Q_PROPERTY(QString audioStatus READ audioStatus NOTIFY stateChanged)

    Q_PROPERTY(bool bluetoothAvailable READ bluetoothAvailable NOTIFY stateChanged)
    Q_PROPERTY(bool bluetoothKnown READ bluetoothKnown NOTIFY stateChanged)
    Q_PROPERTY(bool bluetoothBusy READ bluetoothBusy NOTIFY stateChanged)
    Q_PROPERTY(bool bluetoothPowered READ bluetoothPowered NOTIFY stateChanged)
    Q_PROPERTY(QString bluetoothStatus READ bluetoothStatus NOTIFY stateChanged)

    Q_PROPERTY(bool batteryAvailable READ batteryAvailable NOTIFY stateChanged)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY stateChanged)
    Q_PROPERTY(QString batteryStatus READ batteryStatus NOTIFY stateChanged)

    Q_PROPERTY(bool brightnessAvailable READ brightnessAvailable NOTIFY stateChanged)
    Q_PROPERTY(bool brightnessWritable READ brightnessWritable NOTIFY stateChanged)
    Q_PROPERTY(int brightness READ brightness NOTIFY stateChanged)
    Q_PROPERTY(QString brightnessStatus READ brightnessStatus NOTIFY stateChanged)

public:
    explicit SystemControls(QObject *parent = nullptr);
    ~SystemControls() override = default;

    bool wifiAvailable() const;
    bool wifiKnown() const;
    bool wifiEnabled() const;
    bool wifiBusy() const;
    QString wifiStatus() const;

    bool audioAvailable() const;
    bool audioKnown() const;
    bool audioMuted() const;
    bool audioBusy() const;
    int volume() const;
    QString audioStatus() const;

    bool bluetoothAvailable() const;
    bool bluetoothKnown() const;
    bool bluetoothBusy() const;
    bool bluetoothPowered() const;
    QString bluetoothStatus() const;

    bool batteryAvailable() const;
    int batteryPercent() const;
    QString batteryStatus() const;

    bool brightnessAvailable() const;
    bool brightnessWritable() const;
    int brightness() const;
    QString brightnessStatus() const;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void toggleWifi();
    Q_INVOKABLE void setVolume(int percent);
    Q_INVOKABLE void toggleMute();
    Q_INVOKABLE void toggleBluetooth();
    Q_INVOKABLE void setBrightness(int percent);

signals:
    void stateChanged();
    void operationFailed(const QString &message);

private:
    void refreshWifi();
    void refreshAudio();
    void refreshBluetooth();
    void refreshBattery();
    void refreshBrightness();
    void handleWifiFinished(int exitCode, QProcess::ExitStatus status);
    void handleAudioFinished(int exitCode, QProcess::ExitStatus status);
    void handleBluetoothFinished(int exitCode, QProcess::ExitStatus status);

    QProcess m_wifiProcess;
    QProcess m_audioProcess;
    QProcess m_bluetoothProcess;
    QTimer m_refreshTimer;

    QString m_nmcliPath;
    QString m_wpctlPath;
    QString m_pactlPath;
    QString m_bluetoothctlPath;
    QString m_audioBackend;

    QString m_wifiOperation;
    QString m_audioOperation;
    QString m_bluetoothOperation;

    bool m_wifiAvailable = false;
    bool m_wifiEnabled = false;
    bool m_wifiKnown = false;

    bool m_audioAvailable = false;
    bool m_audioMuted = false;
    bool m_audioKnown = false;
    int m_volume = 0;

    bool m_bluetoothAvailable = false;
    bool m_bluetoothPowered = false;
    bool m_bluetoothKnown = false;

    bool m_batteryAvailable = false;
    int m_batteryPercent = 0;
    QString m_batteryStatus;

    QString m_brightnessPath;
    qint64 m_brightnessMaximum = 0;
    bool m_brightnessAvailable = false;
    bool m_brightnessWritable = false;
    int m_brightness = 0;
};
