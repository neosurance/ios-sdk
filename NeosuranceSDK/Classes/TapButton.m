#import "TapButton.h"
#import "TapUtils.h"
#import "TapSettings.h"

@implementation TapButton

- (id)initWithIcon:(TapButtonIcon)buttonIcon {
    return [self initWithIcon:buttonIcon iconScale:1.0];
}

- (id)initWithIcon:(TapButtonIcon)buttonIcon iconScale:(float)scale {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.001];
        int btnSize = [[[TapSettings sharedInstance] valueOf:TapSettingButtonSize] intValue];
        float iconScale = [[[TapSettings sharedInstance] valueOf:TapSettingButtonIconScale] floatValue];
        icon = [[UILabel alloc] init];
        icon.backgroundColor = [UIColor clearColor];
        icon.textColor = [UIColor colorWithWhite:1 alpha:1];
        icon.text = [self buttonIconAsString:buttonIcon];
        icon.textAlignment = NSTextAlignmentCenter;
        icon.font = [UIFont fontWithName:@"entypo" size:btnSize*iconScale*scale];
        [self addSubview:icon];
        self.userInteractionEnabled = YES;
        btn = [[UIButton alloc] init];
        [self addSubview:btn];
        [self addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
        self.frame = CGRectMake(0, 0, btnSize, btnSize);
        [self setupUi:self.frame.size];
    }
    return self;
}

-(void)setupUi:(CGSize)size {
    icon.frame = CGRectMake(0, 0, size.width, size.height);
    btn.frame = CGRectMake(0, 0, size.width, size.height);
}

-(void)playSound {
    [TapUtils play:[[NSBundle mainBundle] URLForResource:@"Button4" withExtension:@"m4a"]];
}

-(void)unloadUi {
    [super unloadUi];
    [[NSNotificationCenter defaultCenter] removeObserver:btn];
}

- (NSString*)buttonIconAsString:(TapButtonIcon) buttonIcon {
    NSArray *iconsString = @[
                             @"\u25b6",//TapButtonIconPlay,
                             @"\u25a0",//TapButtonIconStop,
                             @"\u2389",//TapButtonIconPause,
                             @"\u26ab",//TapButtonIconRecord
                             @"\u23e9",//TapButtonIconFastForward,
                             @"\u23ea",//TapButtonIconFastBackward,
                             @"\u2715",//TapButtonIconCancel
                             @"\ue75d",//TapButtonIconLeftOpen
                             @"\ue75e",//TapButtonIconRightOpen
                             @"\ue776",//TapButtonIconNetwork
                             @"\ue73c",//TapButtonIconShare
                             @"\u2b05",//TapButtonIconLeft
                             @"\u27a1",//TapButtonIconRight
                             @"\u27f3",//TapButtonIconCw
                             @"\U0001f4c4",//TapButtonIconDocText
                             @"\U0001f4f0",//TapButtonIconNewspaper
                             @"\U0001f3ac",//TapButtonIconVideo
                             @"\ue738",//TapButtonIconArchive
                             @"\ue729",//TapButtonIconTrash
                             ];
    return (NSString *)[iconsString objectAtIndex:buttonIcon];
}

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [btn addTarget:target action:action forControlEvents:controlEvents];
}

@end
