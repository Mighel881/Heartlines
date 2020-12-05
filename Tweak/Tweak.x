#import "Heartlines.h"

BOOL enabled;

SBUIProudLockIconView* faceIDLock;

%group Heartlines

%hook SBUIProudLockIconView

- (id)initWithFrame:(CGRect)frame { // get an instance of the faceid lock

    id selv = %orig;
    faceIDLock = self;

    return selv;

}

- (void)setHidden:(BOOL)hidden { // hide faceid lock

    if (hideFaceIDLockSwitch)
        %orig(YES);
    else
        %orig;
    
}

- (void)setFrame:(CGRect)frame { // align and set the size of the face id lock

    %orig;

    if (alignFaceIDLockSwitch) {
        if ([positionValue intValue] == 0) {
            if (smallerFaceIDLockSwitch) self.center = CGPointMake(self.center.x / 4, self.center.y + 10);
            else self.center = CGPointMake(self.center.x / 4, self.center.y);
        } else if ([positionValue intValue] == 1) {
            if (smallerFaceIDLockSwitch) self.center = CGPointMake(self.center.x, self.center.y + 10);
        } else if ([positionValue intValue] == 2) {
            if (smallerFaceIDLockSwitch) self.center = CGPointMake(self.center.x * 1.75, self.center.y + 10);
            else self.center = CGPointMake(self.center.x * 1.75, self.center.y);
        }
    }
    
    if (smallerFaceIDLockSwitch) self.transform = CGAffineTransformMakeScale(0.85, 0.85);
    if (!alignFaceIDLockSwitch && smallerFaceIDLockSwitch) self.center = CGPointMake(self.center.x, self.center.y + 10);

}

- (void)setContentColor:(UIColor *)arg1 { // set faceid lock color

    if (artworkBasedColorsSwitch && ([[%c(SBMediaController) sharedInstance] isPlaying] || [[%c(SBMediaController) sharedInstance] isPaused])) return %orig;
    if ([timeDateUpNextColorValue intValue] == 0)
        %orig(backgroundWallpaperColor);
    else if ([timeDateUpNextColorValue intValue] == 1)
        %orig(primaryWallpaperColor);
    else if ([timeDateUpNextColorValue intValue] == 2)
        %orig(secondaryWallpaperColor);
    else if ([timeDateUpNextColorValue intValue] == 3)
        %orig([SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customTimeDateUpNextColor"] withFallback:@"#FFFFFF"]);
    else
        %orig;

}

%end

%hook UIMorphingLabel

- (id)initWithFrame:(CGRect)frame {

    return nil;

}

%end

%hook SBFLockScreenDateViewController

- (void)setContentAlpha:(double)arg1 withSubtitleVisible:(BOOL)arg2 { // hide original time and date

    %orig(0, NO);

}

%end

%hook SBFLockScreenDateView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHeartlinesUpNext:) name:@"heartlinesUpdateUpNext" object:nil];

    return %orig;
    
}

- (void)didMoveToWindow { // add heartlines

	%orig;

    if (firstTimeLoaded) return;
    firstTimeLoaded = YES;

    // load sf pro text regular font if not using a custom chosen one
    if (!useCustomFontSwitch) {
        NSData* inData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/PreferenceBundles/HeartlinesPrefs.bundle/SF-Pro-Text-Regular.otf"]];
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);

        // load sf pro text semibold font
        NSData* inData2 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/PreferenceBundles/HeartlinesPrefs.bundle/SF-Pro-Text-Semibold.otf"]];
        CFErrorRef error2;
        CGDataProviderRef provider2 = CGDataProviderCreateWithCFData((CFDataRef)inData2);
        CGFontRef font2 = CGFontCreateWithDataProvider(provider2);
        if (!CTFontManagerRegisterGraphicsFont(font2, &error2)) {
            CFStringRef errorDescription2 = CFErrorCopyDescription(error2);
            CFRelease(errorDescription2);
        }
        CFRelease(font2);
        CFRelease(provider2);
    }

    if ([styleValue intValue] == 0) {
        // up next label
        if (!upNextLabel && showUpNextSwitch) {
            upNextLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [upNextLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:19]];
            else [upNextLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:19]];
            
            if ([[HLSLocalization stringForKey:@"UP_NEXT"] isEqual:nil]) [upNextLabel setText:@"Up next"];
            else if (![[HLSLocalization stringForKey:@"UP_NEXT"] isEqual:nil]) [upNextLabel setText:[NSString stringWithFormat:@"%@", [HLSLocalization stringForKey:@"UP_NEXT"]]];
            
            if ([positionValue intValue] == 0) [upNextLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [upNextLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [upNextLabel setTextAlignment:NSTextAlignmentRight];


            [upNextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [upNextLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [upNextLabel.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![upNextLabel isDescendantOfView:self]) [self addSubview:upNextLabel];
            
            if ([positionValue intValue] == 0) [upNextLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [upNextLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [upNextLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            [upNextLabel.centerYAnchor constraintEqualToAnchor:self.topAnchor constant:16].active = YES;
        }

        // up next event label
        if (!upNextEventLabel && showUpNextSwitch) {
            upNextEventLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [upNextEventLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:15]];
            else [upNextEventLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:15]];
            
            if ([[HLSLocalization stringForKey:@"NO_UPCOMING_EVENTS"] isEqual:nil]) [upNextEventLabel setText:@"No upcoming events"];
            else if (![[HLSLocalization stringForKey:@"NO_UPCOMING_EVENTS"] isEqual:nil]) [upNextEventLabel setText:[NSString stringWithFormat:@"%@", [HLSLocalization stringForKey:@"NO_UPCOMING_EVENTS"]]];
            
            if ([positionValue intValue] == 0) [upNextEventLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [upNextEventLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [upNextEventLabel setTextAlignment:NSTextAlignmentRight];
            

            [upNextEventLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [upNextEventLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [upNextEventLabel.heightAnchor constraintEqualToConstant:16].active = YES;
            
            if (![upNextEventLabel isDescendantOfView:self]) [self addSubview:upNextEventLabel];
            
            if ([positionValue intValue] == 0) [upNextEventLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [upNextEventLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [upNextEventLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            [upNextEventLabel.centerYAnchor constraintEqualToAnchor:upNextLabel.bottomAnchor constant:16].active = YES;
        }

        // invisible ink
        if (!invisibleInk && invisibleInkEffectSwitch && hideUntilAuthenticatedSwitch && showUpNextSwitch) {
            invisibleInk = [[NSClassFromString(@"CKInvisibleInkImageEffectView") alloc] init];
            [invisibleInk setHidden:YES];


            [invisibleInk setTranslatesAutoresizingMaskIntoConstraints:NO];
            [invisibleInk.widthAnchor constraintEqualToConstant:160].active = YES;
            [invisibleInk.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![invisibleInk isDescendantOfView:self]) [self addSubview:invisibleInk];
            
            if ([positionValue intValue] == 0) [invisibleInk.centerXAnchor constraintEqualToAnchor:self.leftAnchor constant:87.5].active = YES;
            else if ([positionValue intValue] == 1) [invisibleInk.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [invisibleInk.centerXAnchor constraintEqualToAnchor:self.rightAnchor constant:-75].active = YES;
            
            [invisibleInk.centerYAnchor constraintEqualToAnchor:upNextLabel.bottomAnchor constant:16].active = YES;
        }

        // time label
        if (!timeLabel) {
            timeLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [timeLabel setFont:[UIFont fontWithName:@"SFProText-Regular" size:61]];
            else [timeLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:61]];
            
            NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:timeFormatValue];
            [timeLabel setText:[timeFormat stringFromDate:[NSDate date]]];
            
            if ([positionValue intValue] == 0) [timeLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [timeLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [timeLabel setTextAlignment:NSTextAlignmentRight];
            

            [timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [timeLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [timeLabel.heightAnchor constraintEqualToConstant:73].active = YES;
            
            if (![timeLabel isDescendantOfView:self]) [self addSubview:timeLabel];
            
            if ([positionValue intValue] == 0) [timeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [timeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [timeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            if (showUpNextSwitch) [timeLabel.centerYAnchor constraintEqualToAnchor:upNextEventLabel.bottomAnchor constant:40].active = YES;
            else if (!showUpNextSwitch) [timeLabel.centerYAnchor constraintEqualToAnchor:self.topAnchor constant:40].active = YES;
        }

        // date label
        if (!dateLabel) {
            dateLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [dateLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:17]];
            else [dateLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:17]];
            
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:dateFormatValue];
            [dateLabel setText:[[dateFormat stringFromDate:[NSDate date]] capitalizedString]];
            
            if ([positionValue intValue] == 0) [dateLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [dateLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [dateLabel setTextAlignment:NSTextAlignmentRight];
            

            [dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [dateLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [dateLabel.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![dateLabel isDescendantOfView:self]) [self addSubview:dateLabel];
            
            if ([positionValue intValue] == 0) [dateLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [dateLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [dateLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            [dateLabel.centerYAnchor constraintEqualToAnchor:timeLabel.bottomAnchor constant:8].active = YES;
        }

        // weather report label
        if (showWeatherSwitch && !weatherReportLabel) {
            weatherReportLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [weatherReportLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:14]];
            else [weatherReportLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:14]];
            
            [[PDDokdo sharedInstance] refreshWeatherData];
            if ([[HLSLocalization stringForKey:@"CURRENTLY_ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"Currently it's %@", [[PDDokdo sharedInstance] currentTemperature]]];
            else if (![[HLSLocalization stringForKey:@"CURRENTLY_ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"%@ %@", [HLSLocalization stringForKey:@"CURRENTLY_ITS"], [[PDDokdo sharedInstance] currentTemperature]]];
            
            if ([positionValue intValue] == 0) [weatherReportLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [weatherReportLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [weatherReportLabel setTextAlignment:NSTextAlignmentRight];


            [weatherReportLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [weatherReportLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [weatherReportLabel.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![weatherReportLabel isDescendantOfView:self]) [self addSubview:weatherReportLabel];
            
            if ([positionValue intValue] == 0) [weatherReportLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [weatherReportLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [weatherReportLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            [weatherReportLabel.centerYAnchor constraintEqualToAnchor:dateLabel.bottomAnchor constant:16].active = YES;
        }

        // weather condition label
        if (showWeatherSwitch && !weatherConditionLabel) {
            weatherConditionLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [weatherConditionLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:14]];
            else [weatherConditionLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:14]];
            
            [weatherConditionLabel setText:[NSString stringWithFormat:@"%@", [[PDDokdo sharedInstance] currentConditions]]];
            
            if ([positionValue intValue] == 0) [weatherConditionLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [weatherConditionLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [weatherConditionLabel setTextAlignment:NSTextAlignmentRight];
            

            [weatherConditionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [weatherConditionLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [weatherConditionLabel.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![weatherConditionLabel isDescendantOfView:self]) [self addSubview:weatherConditionLabel];
            
            if ([positionValue intValue] == 0) [weatherConditionLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [weatherConditionLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [weatherConditionLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            [weatherConditionLabel.centerYAnchor constraintEqualToAnchor:weatherReportLabel.bottomAnchor constant:8].active = YES;
        }
    } else if ([styleValue intValue] == 1) {
        // weather condition label
        if (showWeatherSwitch && !weatherConditionLabel) {
            weatherConditionLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [weatherConditionLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:15]];
            else [weatherConditionLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:15]];
            
            [[PDDokdo sharedInstance] refreshWeatherData];
            [weatherConditionLabel setText:[NSString stringWithFormat:@"%@, %@",[[PDDokdo sharedInstance] currentConditions], [[PDDokdo sharedInstance] currentTemperature]]];

            if ([positionValue intValue] == 0) [weatherConditionLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [weatherConditionLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [weatherConditionLabel setTextAlignment:NSTextAlignmentRight];
            
            
            [weatherConditionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [weatherConditionLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [weatherConditionLabel.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![weatherConditionLabel isDescendantOfView:self]) [self addSubview:weatherConditionLabel];
            
            if ([positionValue intValue] == 0) [weatherConditionLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [weatherConditionLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [weatherConditionLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            [weatherConditionLabel.centerYAnchor constraintEqualToAnchor:self.topAnchor constant:16].active = YES;
        }

        // date label
        if (!dateLabel) {
            dateLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [dateLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:17]];
            else [dateLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:17]];
            
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:dateFormatValue];
            [dateLabel setText:[[dateFormat stringFromDate:[NSDate date]] capitalizedString]];
            
            if ([positionValue intValue] == 0) [dateLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [dateLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [dateLabel setTextAlignment:NSTextAlignmentRight];
            

            [dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [dateLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [dateLabel.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![dateLabel isDescendantOfView:self]) [self addSubview:dateLabel];
            
            if ([positionValue intValue] == 0) [dateLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [dateLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [dateLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            if (showWeatherSwitch) [dateLabel.centerYAnchor constraintEqualToAnchor:weatherConditionLabel.bottomAnchor constant:8].active = YES;
            else if (!showWeatherSwitch) [dateLabel.centerYAnchor constraintEqualToAnchor:self.topAnchor constant:16].active = YES;
        }

        // time label
        if (!timeLabel) {
            timeLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [timeLabel setFont:[UIFont fontWithName:@"SFProText-Regular" size:61]];
            else [timeLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:61]];
            
            NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:timeFormatValue];
            [timeLabel setText:[timeFormat stringFromDate:[NSDate date]]];
            
            if ([positionValue intValue] == 0) [timeLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [timeLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [timeLabel setTextAlignment:NSTextAlignmentRight];
            

            [timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [timeLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [timeLabel.heightAnchor constraintEqualToConstant:73].active = YES;
            
            if (![timeLabel isDescendantOfView:self]) [self addSubview:timeLabel];
            
            if ([positionValue intValue] == 0) [timeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [timeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [timeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            [timeLabel.centerYAnchor constraintEqualToAnchor:dateLabel.bottomAnchor constant:32].active = YES;
        }

        // up next label
        if (!upNextLabel && showUpNextSwitch) {
            upNextLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [upNextLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:19]];
            else [upNextLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:19]];
            
            if ([[HLSLocalization stringForKey:@"UP_NEXT"] isEqual:nil]) [upNextLabel setText:@"Up next"];
            else if (![[HLSLocalization stringForKey:@"UP_NEXT"] isEqual:nil]) [upNextLabel setText:[NSString stringWithFormat:@"%@", [HLSLocalization stringForKey:@"UP_NEXT"]]];
            
            if ([positionValue intValue] == 0) [upNextLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [upNextLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [upNextLabel setTextAlignment:NSTextAlignmentRight];


            [upNextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [upNextLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [upNextLabel.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![upNextLabel isDescendantOfView:self]) [self addSubview:upNextLabel];
            
            if ([positionValue intValue] == 0) [upNextLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [upNextLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [upNextLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            [upNextLabel.centerYAnchor constraintEqualToAnchor:timeLabel.bottomAnchor constant:8].active = YES;
        }

        // up next event label
        if (!upNextEventLabel && showUpNextSwitch) {
            upNextEventLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [upNextEventLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:15]];
            else [upNextEventLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:15]];
            
            if ([[HLSLocalization stringForKey:@"NO_UPCOMING_EVENTS"] isEqual:nil]) [upNextEventLabel setText:@"No upcoming events"];
            else if (![[HLSLocalization stringForKey:@"NO_UPCOMING_EVENTS"] isEqual:nil]) [upNextEventLabel setText:[NSString stringWithFormat:@"%@", [HLSLocalization stringForKey:@"NO_UPCOMING_EVENTS"]]];
            
            if ([positionValue intValue] == 0) [upNextEventLabel setTextAlignment:NSTextAlignmentLeft];
            else if ([positionValue intValue] == 1) [upNextEventLabel setTextAlignment:NSTextAlignmentCenter];
            else if ([positionValue intValue] == 2) [upNextEventLabel setTextAlignment:NSTextAlignmentRight];
            

            [upNextEventLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [upNextEventLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [upNextEventLabel.heightAnchor constraintEqualToConstant:16].active = YES;
            
            if (![upNextEventLabel isDescendantOfView:self]) [self addSubview:upNextEventLabel];
            
            if ([positionValue intValue] == 0) [upNextEventLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            else if ([positionValue intValue] == 1) [upNextEventLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [upNextEventLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            
            [upNextEventLabel.centerYAnchor constraintEqualToAnchor:upNextLabel.bottomAnchor constant:16].active = YES;
        }

        // invisible ink
        if (!invisibleInk && invisibleInkEffectSwitch && hideUntilAuthenticatedSwitch && showUpNextSwitch) {
            invisibleInk = [[NSClassFromString(@"CKInvisibleInkImageEffectView") alloc] init];
            [invisibleInk setHidden:YES];

            [invisibleInk setTranslatesAutoresizingMaskIntoConstraints:NO];
            [invisibleInk.widthAnchor constraintEqualToConstant:160].active = YES;
            [invisibleInk.heightAnchor constraintEqualToConstant:21].active = YES;
            if (![invisibleInk isDescendantOfView:self]) [self addSubview:invisibleInk];
            if ([positionValue intValue] == 0) [invisibleInk.centerXAnchor constraintEqualToAnchor:self.leftAnchor constant:87.5].active = YES;
            else if ([positionValue intValue] == 1) [invisibleInk.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
            else if ([positionValue intValue] == 2) [invisibleInk.centerXAnchor constraintEqualToAnchor:self.rightAnchor constant:-75].active = YES;
            [invisibleInk.centerYAnchor constraintEqualToAnchor:upNextLabel.bottomAnchor constant:16].active = YES;
        }
    } else if ([styleValue intValue] == 2) {
        // time label
        if (!timeLabel) {
            timeLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [timeLabel setFont:[UIFont fontWithName:@"SFProText-Regular" size:61]];
            else [timeLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:61]];
            
            NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:timeFormatValue];
            [timeLabel setText:[timeFormat stringFromDate:[NSDate date]]];
            
            [timeLabel setTextAlignment:NSTextAlignmentLeft];
            

            [timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [timeLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [timeLabel.heightAnchor constraintEqualToConstant:73].active = YES;
            
            if (![timeLabel isDescendantOfView:self]) [self addSubview:timeLabel];
            
            [timeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            [timeLabel.centerYAnchor constraintEqualToAnchor:self.topAnchor constant:50].active = YES;
        }

        // date label
        if (!dateLabel) {
            dateLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [dateLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:17]];
            else [dateLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:17]];
            
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:dateFormatValue];
            [dateLabel setText:[[dateFormat stringFromDate:[NSDate date]] capitalizedString]];
            
            [dateLabel setTextAlignment:NSTextAlignmentLeft];
            

            [dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [dateLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [dateLabel.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![dateLabel isDescendantOfView:self]) [self addSubview:dateLabel];
            
            [dateLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:8].active = YES;
            [dateLabel.centerYAnchor constraintEqualToAnchor:timeLabel.bottomAnchor constant:8].active = YES;
        }

        // weather report label
        if (showWeatherSwitch && !weatherReportLabel) {
            weatherReportLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [weatherReportLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:14]];
            else [weatherReportLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:14]];
            
            [[PDDokdo sharedInstance] refreshWeatherData];
            if ([[HLSLocalization stringForKey:@"ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"It's %@", [[PDDokdo sharedInstance] currentTemperature]]];
            else if (![[HLSLocalization stringForKey:@"ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"%@ %@", [HLSLocalization stringForKey:@"ITS"], [[PDDokdo sharedInstance] currentTemperature]]];
            
            [weatherReportLabel setTextAlignment:NSTextAlignmentRight];


            [weatherReportLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [weatherReportLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [weatherReportLabel.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![weatherReportLabel isDescendantOfView:self]) [self addSubview:weatherReportLabel];
            
            [weatherReportLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            [weatherReportLabel.centerYAnchor constraintEqualToAnchor:self.topAnchor constant:55].active = YES;
        }

        // weather condition label
        if (showWeatherSwitch && !weatherConditionLabel) {
            weatherConditionLabel = [[UILabel alloc] init];
            
            if (!useCustomFontSwitch) [weatherConditionLabel setFont:[UIFont fontWithName:@"SFProText-Semibold" size:14]];
            else [weatherConditionLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", [preferences objectForKey:@"customFont"]] size:14]];
            
            [weatherConditionLabel setText:[NSString stringWithFormat:@"%@", [[PDDokdo sharedInstance] currentConditions]]];
            [weatherConditionLabel setTextAlignment:NSTextAlignmentRight];

            
            [weatherConditionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [weatherConditionLabel.widthAnchor constraintEqualToConstant:self.bounds.size.width].active = YES;
            [weatherConditionLabel.heightAnchor constraintEqualToConstant:21].active = YES;
            
            if (![weatherConditionLabel isDescendantOfView:self]) [self addSubview:weatherConditionLabel];
            
            [weatherConditionLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-8].active = YES;
            [weatherConditionLabel.centerYAnchor constraintEqualToAnchor:weatherReportLabel.bottomAnchor constant:8].active = YES;
        }
    }

    // get lockscreen wallpaper
    NSData* lockWallpaperData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"];
    CFDataRef lockWallpaperDataRef = (__bridge CFDataRef)lockWallpaperData;
    NSArray* imageArray = (__bridge NSArray *)CPBitmapCreateImagesFromData(lockWallpaperDataRef, NULL, 1, NULL);
    UIImage* wallpaper = [UIImage imageWithCGImage:(CGImageRef)imageArray[0]];

    // get lockscreen wallpaper based colors
    backgroundWallpaperColor = [libKitten backgroundColor:wallpaper];
    primaryWallpaperColor = [libKitten primaryColor:wallpaper];
    secondaryWallpaperColor = [libKitten secondaryColor:wallpaper];

    // set weather & up next event label color
    if ([weatherUpNextEventColorValue intValue] == 0) {
        [weatherReportLabel setTextColor:backgroundWallpaperColor];
        [weatherConditionLabel setTextColor:backgroundWallpaperColor];
        [upNextEventLabel setTextColor:backgroundWallpaperColor];
    } else if ([weatherUpNextEventColorValue intValue] == 1) {
        [weatherReportLabel setTextColor:primaryWallpaperColor];
        [weatherConditionLabel setTextColor:primaryWallpaperColor];
        [upNextEventLabel setTextColor:primaryWallpaperColor];
    } else if ([weatherUpNextEventColorValue intValue] == 2) {
        [weatherReportLabel setTextColor:secondaryWallpaperColor];
        [weatherConditionLabel setTextColor:secondaryWallpaperColor];
        [upNextEventLabel setTextColor:secondaryWallpaperColor];
    } else if ([weatherUpNextEventColorValue intValue] == 3) {
        [weatherReportLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customWeatherUpNextEventColor"] withFallback:@"#FFFFFF"]];
        [weatherConditionLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customWeatherUpNextEventColor"] withFallback:@"#FFFFFF"]];
        [upNextEventLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customWeatherUpNextEventColor"] withFallback:@"#FFFFFF"]];
    }

    // set faceid lock, time, date & up next label color
    if ([timeDateUpNextColorValue intValue] == 0) {
        [faceIDLock setContentColor:backgroundWallpaperColor];
        [timeLabel setTextColor:backgroundWallpaperColor];
        [dateLabel setTextColor:backgroundWallpaperColor];
        [upNextLabel setTextColor:backgroundWallpaperColor];
    } else if ([timeDateUpNextColorValue intValue] == 1) {
        [faceIDLock setContentColor:primaryWallpaperColor];
        [timeLabel setTextColor:primaryWallpaperColor];
        [dateLabel setTextColor:primaryWallpaperColor];
        [upNextLabel setTextColor:primaryWallpaperColor];
    } else if ([timeDateUpNextColorValue intValue] == 2) {
        [faceIDLock setContentColor:secondaryWallpaperColor];
        [timeLabel setTextColor:secondaryWallpaperColor];
        [dateLabel setTextColor:secondaryWallpaperColor];
        [upNextLabel setTextColor:secondaryWallpaperColor];
    } else if ([timeDateUpNextColorValue intValue] == 3) {
        [faceIDLock setContentColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customTimeDateUpNextColor"] withFallback:@"#FFFFFF"]];
        [timeLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customTimeDateUpNextColor"] withFallback:@"#FFFFFF"]];
        [dateLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customTimeDateUpNextColor"] withFallback:@"#FFFFFF"]];
        [upNextLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customTimeDateUpNextColor"] withFallback:@"#FFFFFF"]];
    }

}

%new
- (void)updateHeartlinesUpNext:(NSNotification *)notification { // update up next

    if (![notification.name isEqual:@"heartlinesUpdateUpNext"]) return;
    EKEventStore* store = [[EKEventStore alloc] init];
    NSCalendar* calendar = [NSCalendar currentCalendar];

    NSDateComponents* todayComponents = [[NSDateComponents alloc] init];
    todayComponents.day = -1;
    NSDate* today = [calendar dateByAddingComponents:todayComponents toDate:[NSDate date] options:0];

    NSDateComponents* daysFromNowComponents = [[NSDateComponents alloc] init];
    daysFromNowComponents.day = [dayRangeValue intValue];
    NSDate* daysFromNow = [calendar dateByAddingComponents:daysFromNowComponents toDate:[NSDate date] options:0];

    NSPredicate* calendarPredicate = [store predicateForEventsWithStartDate:today endDate:daysFromNow calendars:nil];

    NSArray* events = [store eventsMatchingPredicate:calendarPredicate];

    NSPredicate* reminderPredicate = [store predicateForIncompleteRemindersWithDueDateStarting:today ending:daysFromNow calendars:nil];

    // get first event
    if ([events count]) {
        [upNextEventLabel setText:[NSString stringWithFormat:@"%@", [events[0] title]]];
        if (!(hideUntilAuthenticatedSwitch && isLocked)) [upNextEventLabel setHidden:NO];
    }

    // return if user has events and does not prioritize reminders
    if (!prioritizeRemindersSwitch && [events count]) return;

    // get first reminder and manage no events status
    [store fetchRemindersMatchingPredicate:reminderPredicate completion:^(NSArray* reminders) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([reminders count]) {
                [upNextEventLabel setText:[NSString stringWithFormat:@"%@", [reminders[0] title]]];
                if (!(hideUntilAuthenticatedSwitch && isLocked)) [upNextEventLabel setHidden:NO];
                return;
            } else if (![reminders count] && ![events count]) {
                if ([[HLSLocalization stringForKey:@"NO_UPCOMING_EVENTS"] isEqual:nil]) [upNextEventLabel setText:@"No upcoming events"];
                else if (![[HLSLocalization stringForKey:@"NO_UPCOMING_EVENTS"] isEqual:nil]) [upNextEventLabel setText:[NSString stringWithFormat:@"%@", [HLSLocalization stringForKey:@"NO_UPCOMING_EVENTS"]]];
            }
        });
    }];

}

%end

%hook CSCoverSheetViewController

- (void)viewWillAppear:(BOOL)animated { // update heartlines when lockscreen appears

	%orig;

	[self updateHeartlines];

	if (!timer) timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateHeartlines) userInfo:nil repeats:YES];

}

- (void)viewWillDisappear:(BOOL)animated { // stop timer when lockscreen disappears

	%orig;

	[timer invalidate];
	timer = nil;

}

%new
- (void)updateHeartlines { // update heartlines

	NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:timeFormatValue];
    if (!justPluggedIn) [timeLabel setText:[timeFormat stringFromDate:[NSDate date]]];

	NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:dateFormatValue];
    [dateLabel setText:[[dateFormat stringFromDate:[NSDate date]] capitalizedString]];

    if (showWeatherSwitch) {
        [[PDDokdo sharedInstance] refreshWeatherData];
        if ([styleValue intValue] == 0) {
            if ([[HLSLocalization stringForKey:@"CURRENTLY_ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"Currently it's %@", [[PDDokdo sharedInstance] currentTemperature]]];
            else if (![[HLSLocalization stringForKey:@"CURRENTLY_ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"%@ %@", [HLSLocalization stringForKey:@"CURRENTLY_ITS"], [[PDDokdo sharedInstance] currentTemperature]]];
            
            [weatherConditionLabel setText:[NSString stringWithFormat:@"%@", [[PDDokdo sharedInstance] currentConditions]]];
        } else if ([styleValue intValue] == 1) {
            [weatherConditionLabel setText:[NSString stringWithFormat:@"%@, %@",[[PDDokdo sharedInstance] currentConditions], [[PDDokdo sharedInstance] currentTemperature]]];
        } else if ([styleValue intValue] == 2) {
            if ([[HLSLocalization stringForKey:@"ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"It's %@", [[PDDokdo sharedInstance] currentTemperature]]];
            else if (![[HLSLocalization stringForKey:@"ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"%@ %@", [HLSLocalization stringForKey:@"ITS"], [[PDDokdo sharedInstance] currentTemperature]]];
            
            [weatherConditionLabel setText:[NSString stringWithFormat:@"%@", [[PDDokdo sharedInstance] currentConditions]]];
        }
    }

    if (showUpNextSwitch && [styleValue intValue] != 2) [[NSNotificationCenter defaultCenter] postNotificationName:@"heartlinesUpdateUpNext" object:nil];
    
}

%end

%hook SBLockScreenManager

- (void)lockUIFromSource:(int)arg1 withOptions:(id)arg2 { // stop timer when device was locked

	%orig;

	[timer invalidate];
	timer = nil;

}

%end

%hook SBBacklightController

- (void)turnOnScreenFullyWithBacklightSource:(long long)arg1 { // update heartlines when screen turns on

	%orig;

	[self updateHeartlines];

	if (!timer) timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateHeartlines) userInfo:nil repeats:YES];

}

%new
- (void)updateHeartlines { // update heartlines

	NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:timeFormatValue];
    if (!justPluggedIn) [timeLabel setText:[timeFormat stringFromDate:[NSDate date]]];

	NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:dateFormatValue];
    [dateLabel setText:[[dateFormat stringFromDate:[NSDate date]] capitalizedString]];

    if (showWeatherSwitch) {
        [[PDDokdo sharedInstance] refreshWeatherData];
        if ([styleValue intValue] == 0) {
            if ([[HLSLocalization stringForKey:@"CURRENTLY_ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"Currently it's %@", [[PDDokdo sharedInstance] currentTemperature]]];
            else if (![[HLSLocalization stringForKey:@"CURRENTLY_ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"%@ %@", [HLSLocalization stringForKey:@"CURRENTLY_ITS"], [[PDDokdo sharedInstance] currentTemperature]]];
            
            [weatherConditionLabel setText:[NSString stringWithFormat:@"%@", [[PDDokdo sharedInstance] currentConditions]]];
        } else if ([styleValue intValue] == 1) {
            [weatherConditionLabel setText:[NSString stringWithFormat:@"%@, %@",[[PDDokdo sharedInstance] currentConditions], [[PDDokdo sharedInstance] currentTemperature]]];
        } else if ([styleValue intValue] == 2) {
            if ([[HLSLocalization stringForKey:@"ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"It's %@", [[PDDokdo sharedInstance] currentTemperature]]];
            else if (![[HLSLocalization stringForKey:@"ITS"] isEqual:nil]) [weatherReportLabel setText:[NSString stringWithFormat:@"%@ %@", [HLSLocalization stringForKey:@"ITS"], [[PDDokdo sharedInstance] currentTemperature]]];
            
            [weatherConditionLabel setText:[NSString stringWithFormat:@"%@", [[PDDokdo sharedInstance] currentConditions]]];
        }
    }

    if (showUpNextSwitch && [styleValue intValue] != 2) [[NSNotificationCenter defaultCenter] postNotificationName:@"heartlinesUpdateUpNext" object:nil];
    
}

%end

%hook CSTodayViewController

- (void)viewWillAppear:(BOOL)animated { // fade heartlines out when today view appears

    %orig;

    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [faceIDLock setAlpha:0.0];
        [upNextLabel setAlpha:0.0];
        [upNextEventLabel setAlpha:0.0];
        [invisibleInk setAlpha:0.0];
        [timeLabel setAlpha:0.0];
        [dateLabel setAlpha:0.0];
        [weatherReportLabel setAlpha:0.0];
        [weatherConditionLabel setAlpha:0.0];
    } completion:nil];

}

- (void)viewWillDisappear:(BOOL)animated { // fade heartlines in when today view disappears

    %orig;

    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [faceIDLock setAlpha:1.0];
        [upNextLabel setAlpha:1.0];
        [upNextEventLabel setAlpha:1.0];
        [invisibleInk setAlpha:1.0];
        [timeLabel setAlpha:1.0];
        [dateLabel setAlpha:1.0];
        [weatherReportLabel setAlpha:1.0];
        [weatherConditionLabel setAlpha:1.0];
    } completion:nil];

}

%end

%hook CSCombinedListViewController

- (double)_minInsetsToPushDateOffScreen { // adjust notification list position depending on style

    if ([styleValue intValue] == 0) {
        if (showUpNextSwitch && showWeatherSwitch) {
            double orig = %orig;
            return orig + 65;
        } else if (!showUpNextSwitch && showWeatherSwitch) {
            double orig = %orig;
            return orig + 15;
        } else if (showUpNextSwitch && !showWeatherSwitch) {
            double orig = %orig;
            return orig + 20;
        } else if (!showUpNextSwitch && !showWeatherSwitch) {
            return %orig;
        } else {
            return %orig;
        }
    } else if ([styleValue intValue] == 1) {
        if (showUpNextSwitch && showWeatherSwitch) {
            double orig = %orig;
            return orig + 30;
        } else if (!showUpNextSwitch && showWeatherSwitch) {
            return %orig;
        } else if (showUpNextSwitch && !showWeatherSwitch) {
            double orig = %orig;
            return orig + 10;
        } else if (!showUpNextSwitch && !showWeatherSwitch) {
            return %orig;
        } else {
            return %orig;
        }
    } else if ([styleValue intValue] == 2) {
        double orig = %orig;
        return orig - 15;
    } else {
        return %orig;
    }

}

- (UIEdgeInsets)_listViewDefaultContentInsets { // adjust notification list position depending on style

    if ([styleValue intValue] == 0) {
        if (showUpNextSwitch && showWeatherSwitch) {
            UIEdgeInsets originalInsets = %orig;
            originalInsets.top += 65;
            return originalInsets;
        } else if (!showUpNextSwitch && showWeatherSwitch) {
            UIEdgeInsets originalInsets = %orig;
            originalInsets.top += 15;
            return originalInsets;
        } else if (showUpNextSwitch && !showWeatherSwitch) {
            UIEdgeInsets originalInsets = %orig;
            originalInsets.top += 20;
            return originalInsets;
        } else if (!showUpNextSwitch && !showWeatherSwitch) {
            return %orig;
        } else {
            return %orig;
        }
    } else if ([styleValue intValue] == 1) {
        if (showUpNextSwitch && showWeatherSwitch) {
            UIEdgeInsets originalInsets = %orig;
            originalInsets.top += 30;
            return originalInsets;
        } else if (!showUpNextSwitch && showWeatherSwitch) {
            return %orig;
        } else if (showUpNextSwitch && !showWeatherSwitch) {
            UIEdgeInsets originalInsets = %orig;
            originalInsets.top += 10;
            return originalInsets;
        } else if (!showUpNextSwitch && !showWeatherSwitch) {
            return %orig;
        } else {
            return %orig;
        }
    } else if ([styleValue intValue] == 2) {
        UIEdgeInsets originalInsets = %orig;
        originalInsets.top -= 15;
        return originalInsets;
    } else {
        return %orig;
    }

}

%end

%hook SBUIController

- (void)ACPowerChanged { // display battery percentage in the time label when plugged in

	%orig;

	if ([self isOnAC]) {
        justPluggedIn = YES;
        [UIView transitionWithView:timeLabel duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			[timeLabel setText:[NSString stringWithFormat:@"%d%%", [self batteryCapacityAsPercentage]]];
		} completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [UIView transitionWithView:timeLabel duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
                    [timeFormat setDateFormat:timeFormatValue];
                    [timeLabel setText:[timeFormat stringFromDate:[NSDate date]]];
                } completion:nil];
                justPluggedIn = NO;
            });
        }];
    }

}

%end

%hook CSCoverSheetViewController

- (void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3 { // hide charging view

	%orig(NO, NO, NO);

}

%end

%hook SBLockScreenManager

- (void)lockUIFromSource:(int)arg1 withOptions:(id)arg2 completion:(id)arg3 { // unhide invisible ink and hide up next when authenticated

    %orig;

    if (!hideUntilAuthenticatedSwitch) return;
    isLocked = YES;
    [UIView transitionWithView:upNextEventLabel duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [upNextEventLabel setHidden:YES];
    } completion:nil];
    [UIView transitionWithView:invisibleInk duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        if (invisibleInkEffectSwitch) [invisibleInk setHidden:NO];
    } completion:nil];

}

%end

%hook SBDashBoardLockScreenEnvironment

- (void)setAuthenticated:(BOOL)arg1 { // hide invisible ink and unhide up next when authenticated

	%orig;

    if (!hideUntilAuthenticatedSwitch) return;
	if (arg1) {
        isLocked = NO;
        [UIView transitionWithView:upNextEventLabel duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [upNextEventLabel setHidden:NO];
        } completion:nil];
        [UIView transitionWithView:invisibleInk duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (invisibleInkEffectSwitch) [invisibleInk setHidden:YES];
        } completion:nil];
    }

}

%end

%end

%group HeartlinesData

%hook SBMediaController

- (void)setNowPlayingInfo:(id)arg1 { // get artwork colors

    %orig;

    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        if (information) {
            NSDictionary* dict = (__bridge NSDictionary *)information;

            currentArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]]; // get artwork

            if (dict) {
                if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]) {
                    // get artwork colors
                    backgroundArtworkColor = [libKitten backgroundColor:currentArtwork];
                    primaryArtworkColor = [libKitten primaryColor:currentArtwork];
                    secondaryArtworkColor = [libKitten secondaryColor:currentArtwork];

                    // set weather & up next event label artwork color
                    if ([weatherUpNextEventArtworkColorValue intValue] != 3) {
                        if ([weatherUpNextEventArtworkColorValue intValue] == 0) {
                            [weatherReportLabel setTextColor:backgroundArtworkColor];
                            [weatherConditionLabel setTextColor:backgroundArtworkColor];
                            [upNextEventLabel setTextColor:backgroundArtworkColor];
                        } else if ([weatherUpNextEventArtworkColorValue intValue] == 1) {
                            [weatherReportLabel setTextColor:primaryArtworkColor];
                            [weatherConditionLabel setTextColor:primaryArtworkColor];
                            [upNextEventLabel setTextColor:primaryArtworkColor];
                        } else if ([weatherUpNextEventArtworkColorValue intValue] == 2) {
                            [weatherReportLabel setTextColor:secondaryArtworkColor];
                            [weatherConditionLabel setTextColor:secondaryArtworkColor];
                            [upNextEventLabel setTextColor:secondaryArtworkColor];
                        }
                    }

                    // set time, date & up next label artwork color
                    if ([timeDateUpNextArtworkColorValue intValue] != 3) {
                        if ([timeDateUpNextArtworkColorValue intValue] == 0) {
                            [faceIDLock setContentColor:backgroundArtworkColor];
                            [timeLabel setTextColor:backgroundArtworkColor];
                            [dateLabel setTextColor:backgroundArtworkColor];
                            [upNextLabel setTextColor:backgroundArtworkColor];
                        } else if ([timeDateUpNextArtworkColorValue intValue] == 1) {
                            [faceIDLock setContentColor:primaryArtworkColor];
                            [timeLabel setTextColor:primaryArtworkColor];
                            [dateLabel setTextColor:primaryArtworkColor];
                            [upNextLabel setTextColor:primaryArtworkColor];
                        } else if ([timeDateUpNextArtworkColorValue intValue] == 2) {
                            [faceIDLock setContentColor:secondaryArtworkColor];
                            [timeLabel setTextColor:secondaryArtworkColor];
                            [dateLabel setTextColor:secondaryArtworkColor];
                            [upNextLabel setTextColor:secondaryArtworkColor];
                        }
                    }
                }
            }
        } else { // reset colors when nothing is playing
            // set weather & up next event label color
            if ([weatherUpNextEventColorValue intValue] == 0) {
                [weatherReportLabel setTextColor:backgroundWallpaperColor];
                [weatherConditionLabel setTextColor:backgroundWallpaperColor];
                [upNextEventLabel setTextColor:backgroundWallpaperColor];
            } else if ([weatherUpNextEventColorValue intValue] == 1) {
                [weatherReportLabel setTextColor:primaryWallpaperColor];
                [weatherConditionLabel setTextColor:primaryWallpaperColor];
                [upNextEventLabel setTextColor:primaryWallpaperColor];
            } else if ([weatherUpNextEventColorValue intValue] == 2) {
                [weatherReportLabel setTextColor:secondaryWallpaperColor];
                [weatherConditionLabel setTextColor:secondaryWallpaperColor];
                [upNextEventLabel setTextColor:secondaryWallpaperColor];
            } else if ([weatherUpNextEventColorValue intValue] == 3) {
                [weatherReportLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customWeatherUpNextEventColor"] withFallback:@"#FFFFFF"]];
                [weatherConditionLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customWeatherUpNextEventColor"] withFallback:@"#FFFFFF"]];
                [upNextEventLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customWeatherUpNextEventColor"] withFallback:@"#FFFFFF"]];
            }

            // set faceid lock, time, date & up next label color
            if ([timeDateUpNextColorValue intValue] == 0) {
                [faceIDLock setContentColor:backgroundWallpaperColor];
                [timeLabel setTextColor:backgroundWallpaperColor];
                [dateLabel setTextColor:backgroundWallpaperColor];
                [upNextLabel setTextColor:backgroundWallpaperColor];
            } else if ([timeDateUpNextColorValue intValue] == 1) {
                [faceIDLock setContentColor:primaryWallpaperColor];
                [timeLabel setTextColor:primaryWallpaperColor];
                [dateLabel setTextColor:primaryWallpaperColor];
                [upNextLabel setTextColor:primaryWallpaperColor];
            } else if ([timeDateUpNextColorValue intValue] == 2) {
                [faceIDLock setContentColor:secondaryWallpaperColor];
                [timeLabel setTextColor:secondaryWallpaperColor];
                [dateLabel setTextColor:secondaryWallpaperColor];
                [upNextLabel setTextColor:secondaryWallpaperColor];
            } else if ([timeDateUpNextColorValue intValue] == 3) {
                [faceIDLock setContentColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customTimeDateUpNextColor"] withFallback:@"#FFFFFF"]];
                [timeLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customTimeDateUpNextColor"] withFallback:@"#FFFFFF"]];
                [dateLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"customTimeDateUpNextColor"] withFallback:@"#FFFFFF"]];
                [upNextLabel setTextColor:[SparkColourPickerUtils colourWithString:[preferencesColorDictionary objectForKey:@"timeDateUpNextColor"] withFallback:@"#FFFFFF"]];
            }
        }
  	});
    
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 { // reload data after respring

    %orig;

    [[%c(SBMediaController) sharedInstance] setNowPlayingInfo:0];
    
}

%end

%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.heartlinespreferences"];
    preferencesColorDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/love.litten.heartlines.colorspreferences.plist"];

	[preferences registerBool:&enabled default:nil forKey:@"Enabled"];

    // style & position
    [preferences registerObject:&styleValue default:@"0" forKey:@"style"];
    [preferences registerObject:&positionValue default:@"0" forKey:@"position"];

    // faceid lock
    [preferences registerBool:&hideFaceIDLockSwitch default:NO forKey:@"hideFaceIDLock"];
    [preferences registerBool:&alignFaceIDLockSwitch default:YES forKey:@"alignFaceIDLock"];
    [preferences registerBool:&smallerFaceIDLockSwitch default:YES forKey:@"smallerFaceIDLock"];

    // text
    [preferences registerBool:&useCustomFontSwitch default:NO forKey:@"useCustomFont"];
    [preferences registerObject:&timeFormatValue default:@"HH:mm" forKey:@"timeFormat"];
    [preferences registerObject:&dateFormatValue default:@"EEEE d MMMM" forKey:@"dateFormat"];

    // colors
    [preferences registerObject:&weatherUpNextEventColorValue default:@"1" forKey:@"weatherUpNextEventColor"];
    [preferences registerObject:&timeDateUpNextColorValue default:@"3" forKey:@"timeDateUpNextColor"];
    [preferences registerBool:&artworkBasedColorsSwitch default:YES forKey:@"artworkBasedColors"];
    [preferences registerObject:&weatherUpNextEventArtworkColorValue default:@"1" forKey:@"weatherUpNextEventArtworkColor"];
    [preferences registerObject:&timeDateUpNextArtworkColorValue default:@"0" forKey:@"timeDateUpNextArtworkColor"];

    // weather
    [preferences registerBool:&showWeatherSwitch default:YES forKey:@"showWeather"];

    // up next
    [preferences registerBool:&showUpNextSwitch default:YES forKey:@"showUpNext"];
    [preferences registerBool:&showCalendarEventsSwitch default:YES forKey:@"showCalendarEvents"];
    [preferences registerBool:&showRemindersSwitch default:YES forKey:@"showReminders"];
    [preferences registerBool:&prioritizeRemindersSwitch default:NO forKey:@"prioritizeReminders"];
    [preferences registerObject:&dayRangeValue default:@"3" forKey:@"dayRange"];
    [preferences registerBool:&hideUntilAuthenticatedSwitch default:NO forKey:@"hideUntilAuthenticated"];
    [preferences registerBool:&invisibleInkEffectSwitch default:YES forKey:@"invisibleInkEffect"];

	if (enabled) {
        if (hideUntilAuthenticatedSwitch && invisibleInkEffectSwitch) dlopen("/System/Library/PrivateFrameworks/ChatKit.framework/ChatKit", RTLD_NOW);
		%init(Heartlines);
		if (artworkBasedColorsSwitch) %init(HeartlinesData);
	}

}