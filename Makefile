ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 34306jit

$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController Metal MetalKit

# Trỏ include path ra thư mục hiện tại (.) thay vì IMGUI/
$(TWEAK_NAME)_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG -I.
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value

# Link thư viện dobby
$(TWEAK_NAME)_OBJ_FILES = libdobby.a

# Bỏ chữ "IMGUI/" vì file đang nằm ở root
# Tự động gom các file .mm/.m trong thư mục Esp/ (nếu có)
$(TWEAK_NAME)_FILES = ImGuiDrawView.mm \
                      imgui.cpp \
                      imgui_draw.cpp \
                      imgui_widgets.cpp \
                      imgui_tables.cpp \
                      imgui_demo.cpp \
                      imgui_impl_metal.mm \
                      $(wildcard Esp/*.mm) \
                      $(wildcard Esp/*.m)

include $(THEOS_MAKE_PATH)/tweak.mk
