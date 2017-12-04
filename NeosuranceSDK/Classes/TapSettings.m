#import "TapSettings.h"
#import "TapButton.h"
#import "TapUtils.h"
#import "NSRUtils.h"
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
        settings = [[NSMutableDictionary alloc] init];
        [settings setObject:[NSNumber numberWithInt:48] forKey:[NSNumber numberWithInt:TapSettingVideoSliderHeight]];
        [settings setObject:[NSNumber numberWithInt:48*2] forKey:[NSNumber numberWithInt:TapSettingVideoSliderMarginLeft]];
        [settings setObject:[NSNumber numberWithInt:88] forKey:[NSNumber numberWithInt:TapSettingSliderPaddingLeft]];
        [settings setObject:[NSNumber numberWithInt:88] forKey:[NSNumber numberWithInt:TapSettingSliderPaddingRight]];
        [settings setObject:[NSNumber numberWithInt:16] forKey:[NSNumber numberWithInt:TapSettingSliderPaddingTop]];
        [settings setObject:[NSNumber numberWithInt:16] forKey:[NSNumber numberWithInt:TapSettingSliderPaddingBottom]];
        [settings setObject:[NSNumber numberWithInt:4] forKey:[NSNumber numberWithInt:TapSettingSliderWheelPadding]];
        [settings setObject:[NSNumber numberWithInt:12] forKey:[NSNumber numberWithInt:TapSettingSliderWheelStep]];
        [settings setObject:[NSNumber numberWithInt:4] forKey:[NSNumber numberWithInt:TapSettingSliderIndicatorPadding]];
        [settings setObject:[NSNumber numberWithInt:48] forKey:[NSNumber numberWithInt:TapSettingButtonSize]];
        [settings setObject:[NSNumber numberWithFloat:0.4] forKey:[NSNumber numberWithInt:TapSettingButtonIconScale]];
        [settings setObject:[NSNumber numberWithInt:5] forKey:[NSNumber numberWithInt:TapSettingVideoFastSeekSeconds]];
        [settings setObject:[NSNumber numberWithInt:22] forKey:[NSNumber numberWithInt:TapSettingHeaderPaddingLeft]];
        [settings setObject:[NSNumber numberWithInt:22] forKey:[NSNumber numberWithInt:TapSettingHeaderPaddingRight]];
        [settings setObject:[NSNumber numberWithInt:8] forKey:[NSNumber numberWithInt:TapSettingProgressBarHeight]];
        [settings setObject:[NSNumber numberWithInt:48] forKey:[NSNumber numberWithInt:TapSettingProgressHeight]];
        [settings setObject:[NSNumber numberWithInt:0x00000066] forKey:[NSNumber numberWithInt:TapSettingProgressColor]];
        [settings setObject:[NSNumber numberWithInt:0xffffffff] forKey:[NSNumber numberWithInt:TapSettingProgressBarColor]];
        [settings setObject:[NSNumber numberWithInt:0xffffff33] forKey:[NSNumber numberWithInt:TapSettingProgressBarBackgroundColor]];
        [settings setObject:[NSNumber numberWithInt:0x33333300] forKey:[NSNumber numberWithInt:TapSettingHeaderBackgroundColor]];
        [settings setObject:[NSNumber numberWithInt:0xffffffff] forKey:[NSNumber numberWithInt:TapSettingHeaderColor]];
        [settings setObject:[NSNumber numberWithInt:0xF44336ff] forKey:[NSNumber numberWithInt:TapSettingColorDanger]];
        [settings setObject:[NSNumber numberWithInt:0xFF9800ff] forKey:[NSNumber numberWithInt:TapSettingColorWarning]];
        [settings setObject:[NSNumber numberWithInt:0x4CAF50ff] forKey:[NSNumber numberWithInt:TapSettingColorSuccess]];
        [settings setObject:[NSNumber numberWithInt:0x666666ff] forKey:[NSNumber numberWithInt:TapSettingColorBackground]];
        [settings setObject:[NSNumber numberWithInt:48] forKey:[NSNumber numberWithInt:TapSettingHeaderHeight]];
        [TapUtils registerFont:[[NSRUtils frameworkBundle] URLForResource:@"entypo" withExtension:@"ttf"]];
        sound = [[TapSound alloc] init];
    }
    return self;
}

- (void)set:(NSString*)key value:(NSObject*)value {
    [settings setObject:value forKey:key];
}

- (NSString*)valueOf:(TapSetting)setting {
    return [settings objectForKey:[NSNumber numberWithInt:setting]];
}

- (UIColor*)color:(TapSetting)setting {
    return [UIColor colorWithRGBAHex:[[settings objectForKey:[NSNumber numberWithInt:setting]] intValue]];
}

- (int)number:(TapSetting)setting {
    return [[self valueOf:setting] intValue];
}

- (void)play:(NSURL*)url {
    [sound play:url];
}

@end
