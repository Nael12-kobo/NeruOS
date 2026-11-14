cmake_minimum_required(VERSION 3.21)
project(NeruOSNebulaPrototype VERSION 0.4.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2 Svg DBus)
find_package(PkgConfig REQUIRED)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)
qt_standard_project_setup(REQUIRES 6.5)

# Pick up individually replaceable application PNGs without editing the
# resource list every time a new icon is added.
file(GLOB NEBULA_ICON_ASSETS CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/icons/*.png"
)

qt_add_executable(neruos-nebula
    main.cpp
    AppCatalog.cpp
    AppCatalog.h
    SystemControls.cpp
    SystemControls.h
    FileSystemModel.cpp
    FileSystemModel.h
    DesktopSettings.cpp
    DesktopSettings.h
    SessionManager.cpp
    SessionManager.h
    NotificationBridge.cpp
    NotificationBridge.h
    WorkspaceController.cpp
    WorkspaceController.h
    UpdateChecker.cpp
    UpdateChecker.h
)

qt_add_qml_module(neruos-nebula
    URI NeruOS
    VERSION 1.0
    QML_FILES
        Main.qml
        NeruBar.qml
        NeruDock.qml
        DesktopBackground.qml
        DesktopLogo.qml
        WallpaperManager.qml
        ApplicationDock.qml
        DockItem.qml
        GlassPanel.qml
        BootAnimation.qml
        BootSplash.qml
        NeruFiles.qml
        NeruSettings.qml
        NotificationCenter.qml
        SessionPanel.qml
)

qt_add_resources(neruos-nebula "nebula_assets"
    PREFIX "/"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}"
    FILES
        assets/nebula-wallpaper.png
        assets/nebula-wallpaper.svg
        assets/logo-mark.svg
        ${NEBULA_ICON_ASSETS}
)

target_link_libraries(neruos-nebula PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
    Qt6::DBus
    PkgConfig::GIO
)
