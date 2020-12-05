#import "HLSTextSubPrefsListController.h"

UIBlurEffect* blur;
UIVisualEffectView* blurView;

@implementation HLSTextSubPrefsListController

- (instancetype)init {

    self = [super init];

    if (self) {
        HLSAppearanceSettings *appearanceSettings = [[HLSAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;

}

- (id)specifiers {

    return _specifiers;

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [blurView setFrame:[[self view] bounds]];
    [blurView setAlpha:1.0];
    [[self view] addSubview:blurView];

    [UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [blurView setAlpha:0.0];
    } completion:nil];

}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {

    NSString *sub = [specifier propertyForKey:@"HLSSub"];
    NSString *title = [specifier name];

    _specifiers = [[self loadSpecifiersFromPlistName:sub target:self] retain];

    [self setTitle:title];
    [self.navigationItem setTitle:title];

}

- (void)setSpecifier:(PSSpecifier *)specifier {

    [self loadFromSpecifier:specifier];
    [super setSpecifier:specifier];

}

- (bool)shouldReloadSpecifiersOnResume {

    return false;

}

- (void)showFontPicker {
    
    UIFontPickerViewController* fontPicker = [[UIFontPickerViewController alloc] init];
    fontPicker.delegate = self;
    [self presentViewController:fontPicker animated:YES completion:nil];
    
}

- (void)fontPickerViewControllerDidPickFont:(UIFontPickerViewController *)viewController {
    
    UIFontDescriptor* descriptor = viewController.selectedFontDescriptor;
    UIFont* font = [UIFont fontWithDescriptor:descriptor size:17];

    HBPreferences* preferences = [[HBPreferences alloc] initWithIdentifier: @"love.litten.heartlinespreferences"];
    [preferences setObject:font.familyName forKey:@"customFont"];
    
}

@end