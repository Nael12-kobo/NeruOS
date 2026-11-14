import QtQml

QtObject {
    id: root

    property url defaultWallpaper: "qrc:/assets/nebula-wallpaper.png"

    readonly property url currentWallpaper: desktopSettings.wallpaperPath.length > 0
                                             ? desktopSettings.wallpaperPath
                                             : defaultWallpaper

    function setWallpaper(source) {
        if (source && source.toString().length > 0)
            desktopSettings.setWallpaperPath(source.toString())
    }

    function resetWallpaper() {
        desktopSettings.resetWallpaper()
    }
}
