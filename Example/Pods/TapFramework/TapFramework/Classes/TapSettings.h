#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TapSetting) {
    TapSettingAnimationDuration = 1,
    TapSettingBackgroundColor,
    TapSettingForegroundColor,
    TapSettingSpinnerColor,
    TapSettingThemeColor,
    TapSettingSpinnerSize,
    TapSettingSpinnerLineWidth,
    TapSettingSpinnerBackgroundColor,
    TapSettingSpinnerBackgroundOpacity,
    TapSettingHeaderBackgroundColor,
    TapSettingHeaderForegroundColor,
    TapSettingHeaderOpacity,
    TapSettingBlurred,
    TapSettingBlurEffectStyle,
    TapSettingHeaderHeight,
    TapSettingButtonWidth,
    TapSettingButtonHeight,
    TapSettingButtonIconColor,
    TapSettingButtonIconScale,
    TapSettingFontSize,
    TapSettingOpacityNotVisible,
    TapSettingEffectVolume,
    TapSettingStatusBarStyle,
    TapSettingColorDanger,
    TapSettingProgressColor,
    TapSettingProgressHeight,
};

@interface TapSettings : NSObject {
    NSMutableDictionary* settings;
}

+ (id)sharedInstance;
- (void)set:(NSObject*)anObject key:(id <NSCopying>)aKey;
- (NSString*)string:(TapSetting)setting;
- (NSNumber*)number:(TapSetting)setting;
- (UIColor*)color:(TapSetting)setting;

@end
