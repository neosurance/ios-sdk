#import "TapSettings.h"
#import <UIColor_Utilities/UIColor+Expanded.h>

@implementation TapSettings

+ (id)sharedInstance {
    static TapSettings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        UIColor* bgcolor = [UIColor colorWithRGBHex:0x464646];
        UIColor* fgcolor = [bgcolor contrastingColor];
        settings = [[NSMutableDictionary alloc] init];
        [settings setObject:[NSNumber numberWithInt:[[UIColor blackColor] rgbHex]] forKey:[NSNumber numberWithInt:TapSettingHeaderBackgroundColor]];
        [settings setObject:[NSNumber numberWithInt:0xF44336] forKey:[NSNumber numberWithInt:TapSettingColorDanger]];
        [settings setObject:[NSNumber numberWithInt:0x4CAF50] forKey:[NSNumber numberWithInt:TapSettingProgressColor]];
        [settings setObject:[NSNumber numberWithInt:2] forKey:[NSNumber numberWithInt:TapSettingProgressHeight]];
        [settings setObject:[NSNumber numberWithInt:[fgcolor rgbHex]] forKey:[NSNumber numberWithInt:TapSettingHeaderForegroundColor]];
        [settings setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:TapSettingBlurred]];
        [settings setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:TapSettingBlurEffectStyle]];
        [settings setObject:[NSNumber numberWithFloat:0.0f] forKey:[NSNumber numberWithInt:TapSettingHeaderOpacity]];
        [settings setObject:[NSNumber numberWithFloat:0.5f] forKey:[NSNumber numberWithInt:TapSettingAnimationDuration]];
        [settings setObject:[NSNumber numberWithInt:[bgcolor rgbHex]] forKey:[NSNumber numberWithInt:TapSettingBackgroundColor]];
        [settings setObject:[NSNumber numberWithInt:[fgcolor rgbHex]] forKey:[NSNumber numberWithInt:TapSettingForegroundColor]];
        [settings setObject:[NSNumber numberWithInt:[fgcolor rgbHex]] forKey:[NSNumber numberWithInt:TapSettingSpinnerColor]];
        [settings setObject:[NSNumber numberWithInt:[fgcolor rgbHex]] forKey:[NSNumber numberWithInt:TapSettingButtonIconColor]];
        [settings setObject:[NSNumber numberWithInt:[bgcolor rgbHex]] forKey:[NSNumber numberWithInt:TapSettingSpinnerBackgroundColor]];
        [settings setObject:[NSNumber numberWithFloat:0.2f] forKey:[NSNumber numberWithInt:TapSettingSpinnerBackgroundOpacity]];
        [settings setObject:[NSNumber numberWithInt:96] forKey:[NSNumber numberWithInt:TapSettingSpinnerSize]];
        [settings setObject:[NSNumber numberWithInt:3] forKey:[NSNumber numberWithInt:TapSettingSpinnerLineWidth]];
        [settings setObject:[NSNumber numberWithInt:48] forKey:[NSNumber numberWithInt:TapSettingHeaderHeight]];
        [settings setObject:[NSNumber numberWithInt:80] forKey:[NSNumber numberWithInt:TapSettingButtonWidth]];
        [settings setObject:[NSNumber numberWithInt:48] forKey:[NSNumber numberWithInt:TapSettingButtonHeight]];
        [settings setObject:[NSNumber numberWithFloat:0.5f] forKey:[NSNumber numberWithInt:TapSettingButtonIconScale]];
        [settings setObject:[NSNumber numberWithFloat:0.001f] forKey:[NSNumber numberWithInt:TapSettingOpacityNotVisible]];
        [settings setObject:[NSNumber numberWithFloat:0.05f] forKey:[NSNumber numberWithInt:TapSettingEffectVolume]];
        [settings setObject:[NSNumber numberWithInt:12] forKey:[NSNumber numberWithInt:TapSettingFontSize]];
        [settings setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:TapSettingStatusBarStyle]];
        bgcolor = [self color:TapSettingBackgroundColor];
    }
    return self;
}

- (NSString*)string:(TapSetting)setting {
    return [NSString stringWithFormat:@"%@", [settings objectForKey:[NSNumber numberWithInt:setting]]];
}

- (NSNumber*)number:(TapSetting)setting {
    return [settings objectForKey:[NSNumber numberWithInt:setting]];
}

- (void)set:(NSObject*)anObject key:(id <NSCopying>)aKey {
    [settings setObject:anObject forKey:aKey];
}

- (UIColor*)color:(TapSetting)setting {
    return [UIColor colorWithRGBHex:[[settings objectForKey:[NSNumber numberWithInt:setting]] intValue]];
}

@end
