#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <UIKit/UIKit.h>
#import "TapSound.h"

typedef NS_ENUM(NSInteger, TapSetting) {
    TapSettingVideoSliderHeight = 1,
    TapSettingSliderPaddingLeft,
    TapSettingSliderPaddingRight,
    TapSettingSliderPaddingTop,
    TapSettingSliderPaddingBottom,
    TapSettingSliderWheelPadding,
    TapSettingSliderWheelStep,
    TapSettingSliderIndicatorPadding,
    TapSettingButtonSize,
    TapSettingButtonIconScale,
    TapSettingVideoSliderMarginLeft,
    TapSettingVideoFastSeekSeconds,
    TapSettingHeaderPaddingRight,
    TapSettingHeaderPaddingLeft,
    TapSettingProgressHeight,
    TapSettingProgressBarHeight,
     TapSettingProgressColor,
    TapSettingProgressBarColor,
    TapSettingProgressBarBackgroundColor,
    TapSettingHeaderBackgroundColor,
    TapSettingHeaderColor,
    TapSettingHeaderHeight,
    TapSettingColorDanger,
    TapSettingColorWarning,
    TapSettingColorSuccess,
    TapSettingColorBackground,
 };

@interface TapSettings : NSObject {
    NSMutableDictionary* settings;
    TapSound* sound;
}

+ (id)sharedInstance;
- (NSString*)valueOf:(TapSetting)setting;
- (UIColor*)color:(TapSetting)setting;
- (int)number:(TapSetting)setting;
- (void)play:(NSURL*)url;
- (void)set:(NSString*)key value:(NSObject*)value;

@end
