cmake_minimum_required(VERSION 3.21)
project(NeruOSNebulaPrototype VERSION 0.4.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2 Svg)
find_package(PkgConfig REQUIRED)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(neruos-nebula
    main.cpp
    AppCatalog.cpp
    AppCatalog.h
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
)

qt_add_resources(neruos-nebula "nebula_assets"
    PREFIX "/"
    FILES
        assets/nebula-wallpaper.svg
        assets/logo-mark.svg
)

target_link_libraries(neruos-nebula PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
    PkgConfig::GIO
)
