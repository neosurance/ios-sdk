#import "TapButton.h"
#import "TapUtils.h"
#import "TapSettings.h"
#import "Tap.h"

@implementation TapButton

- (id)initWithIcon:(NSString*)buttonIcon {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:[[[TapSettings sharedInstance] number:TapSettingOpacityNotVisible] floatValue]];
        int w = [[[TapSettings sharedInstance] number:TapSettingButtonWidth] intValue];
        int h = [[[TapSettings sharedInstance] number:TapSettingButtonHeight] intValue];
        float scale = [[[TapSettings sharedInstance] number:TapSettingButtonIconScale] floatValue];
        icon = [[UILabel alloc] init];
        icon.backgroundColor = [UIColor clearColor];
        UIColor* iconColor = [[TapSettings sharedInstance] color:TapSettingButtonIconColor];
        icon.textColor = iconColor;
        icon.textAlignment = NSTextAlignmentCenter;
        NSArray *components = [buttonIcon componentsSeparatedByString:@"|"];
        icon.font = [UIFont fontWithName:components[0] size:h*scale];
        icon.text = components[1];
        [self addSubview:icon];
        self.userInteractionEnabled = YES;
        btn = [[UIButton alloc] init];
        [self addSubview:btn];
        [self addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
        self.frame = CGRectMake(0, 0, w, h);
        [self setupUi:self.frame.size];
    }
    return self;
}

-(void)playSound {
    [Tap sound:TapSoundButton4];
}

-(void)setupUi:(CGSize)size {
    icon.frame = CGRectMake(0, 0, size.width, size.height);
    btn.frame = CGRectMake(0, 0, size.width, size.height);
}

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [btn addTarget:target action:action forControlEvents:controlEvents];
}

@end
