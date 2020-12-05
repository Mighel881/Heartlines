#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>

@interface HLSAppearanceSettings : HBAppearanceSettings
@end

@interface HLSWeatherSubPrefsListController : HBListController
@property(nonatomic, retain)UILabel* titleLabel;
@end