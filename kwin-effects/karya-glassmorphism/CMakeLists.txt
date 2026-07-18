cmake_minimum_required(VERSION 3.16)
project(karya-glassmorphism)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(Qt6 REQUIRED COMPONENTS Core Gui)
find_package(KF6WindowSystem REQUIRED)
find_package(KWin REQUIRED)

set(kwin_effects_install_dir ${KWIN_EFFECTS_INSTALL_DIR})

add_library(karyaglassmorphism MODULE
    karyaglassmorphism.cpp
)

target_link_libraries(karyaglassmorphism
    Qt6::Core
    Qt6::Gui
    KF6::WindowSystem
    KWin::kwin
)

target_compile_definitions(karyaglassmorphism PRIVATE -DQT_NO_KEYWORDS)

install(TARGETS karyaglassmorphism
    DESTINATION ${kwin_effects_install_dir}
)
