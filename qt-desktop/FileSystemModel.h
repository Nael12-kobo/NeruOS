#pragma once

#include <QAbstractListModel>
#include <QVector>
#include <QFileInfo>

class FileSystemModel final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString currentPath READ currentPath NOTIFY currentPathChanged)
    Q_PROPERTY(QString homePath READ homePath CONSTANT)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool showHidden READ showHidden NOTIFY showHiddenChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        PathRole,
        IsDirectoryRole,
        SizeRole,
        ModifiedRole,
        HiddenRole
    };
    Q_ENUM(Roles)

    explicit FileSystemModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString currentPath() const;
    QString homePath() const;
    int count() const;
    bool showHidden() const;

    Q_INVOKABLE void setShowHidden(bool enabled);
    Q_INVOKABLE bool navigate(const QString &path);
    Q_INVOKABLE bool goUp();
    Q_INVOKABLE bool goHome();
    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool openItem(const QString &path);
    Q_INVOKABLE bool createFolder(const QString &name);
    Q_INVOKABLE bool renameItem(const QString &path, const QString &newName);
    Q_INVOKABLE bool moveToTrash(const QString &path);

signals:
    void currentPathChanged();
    void countChanged();
    void showHiddenChanged();
    void operationFailed(const QString &message);
    void itemOpened(const QString &path);

private:
    void loadDirectory();
    bool isSafeChildName(const QString &name) const;
    QString normalizedPath(const QString &path) const;

    QString m_currentPath;
    QString m_homePath;
    bool m_showHidden = false;
    QVector<QFileInfo> m_entries;
};
