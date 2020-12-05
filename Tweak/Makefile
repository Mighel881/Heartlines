ARCHS = arm64 arm64e
TARGET = iphone:clang::13.5

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Heartlines
$(TWEAK_NAME)_FILES = Tweak.x HLSLocalization.m
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation CoreText EventKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = AppSupport MediaRemote
$(TWEAK_NAME)_EXTRA_FRAMEWORKS = Cephei
$(TWEAK_NAME)_LIBRARIES = kitten pddokdo sparkcolourpicker

include $(THEOS_MAKE_PATH)/tweak.mk
