#export THEOS=/var/mobile/theos
ARCHS = arm64
#Add arm64e if it needed
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 34306jit

$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController Metal MetalKit

$(TWEAK_NAME)_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value

# Add dobby hook
$(TWEAK_NAME)_OBJ_FILES = libdobby.a

# Add all necessary source files (Obj-C, C++, and ImGui implementation)
$(TWEAK_NAME)_FILES = ImGuiDrawView.mm \
                      IMGUI/imgui.cpp \
                      IMGUI/imgui_draw.cpp \
                      IMGUI/imgui_widgets.cpp \
                      IMGUI/imgui_tables.cpp \
                      IMGUI/imgui_demo.cpp \
                      IMGUI/imgui_impl_metal.mm \
                      $(wildcard Esp/*.mm) \
                      $(wildcard Esp/*.m)

include $(THEOS_MAKE_PATH)/tweak.mk
