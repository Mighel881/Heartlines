#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <EventKit/EventKit.h>
#import <MediaRemote/MediaRemote.h>
#import <Kitten/libKitten.h>
#import "libpddokdo.h"
#import "SparkColourPickerUtils.h"
#import "HLSLocalization.h"
#import <Cephei/HBPreferences.h>

HBPreferences* preferences;
NSDictionary* preferencesColorDictionary;

extern BOOL enabled;
extern CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void *, int, void *);

BOOL firstTimeLoaded = NO;
BOOL isLocked = NO;
BOOL justPluggedIn = NO;
UILabel* weatherReportLabel;
UILabel* weatherConditionLabel;
UILabel* timeLabel;
UILabel* dateLabel;
UILabel* upNextLabel;
UILabel* upNextEventLabel;
UIView* invisibleInk;
NSTimer* timer = nil;
UIColor* backgroundWallpaperColor;
UIColor* primaryWallpaperColor;
UIColor* secondaryWallpaperColor;
UIImage* currentArtwork;
UIColor* backgroundArtworkColor;
UIColor* primaryArtworkColor;
UIColor* secondaryArtworkColor;

// style & position
NSString* styleValue = @"0";
NSString* positionValue = @"0";

// faceid lock
BOOL hideFaceIDLockSwitch = NO;
BOOL alignFaceIDLockSwitch = YES;
BOOL smallerFaceIDLockSwitch = YES;

// text
BOOL useCustomFontSwitch = NO;
NSString* timeFormatValue = @"HH:mm";
NSString* dateFormatValue = @"EEEE d MMMM";

// colors
NSString* weatherUpNextEventColorValue = @"1";
NSString* timeDateUpNextColorValue = @"3";
BOOL artworkBasedColorsSwitch = YES;
NSString* weatherUpNextEventArtworkColorValue = @"1";
NSString* timeDateUpNextArtworkColorValue = @"0";

// weather
BOOL showWeatherSwitch = YES;

// up next
BOOL showUpNextSwitch = YES;
BOOL showCalendarEventsSwitch = YES;
BOOL showRemindersSwitch = YES;
BOOL prioritizeRemindersSwitch = NO;
NSString* dayRangeValue = @"3";
BOOL hideUntilAuthenticatedSwitch = NO;
BOOL invisibleInkEffectSwitch = YES;

@interface SBUIProudLockIconView : UIView
- (void)setContentColor:(UIColor *)arg1;
@end

@interface UIMorphingLabel : UIView
@end

@interface SBFLockScreenDateView : UIView
- (void)updateHeartlinesUpNext:(NSNotification *)notification;
@end

@interface CSCoverSheetViewController : UIViewController
- (void)updateHeartlines;
@end

@interface SBBacklightController : NSObject
- (void)updateHeartlines;
@end

@interface SBUIController : NSObject
- (BOOL)isOnAC;
- (int)batteryCapacityAsPercentage;
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (void)setNowPlayingInfo:(id)arg1;
@end