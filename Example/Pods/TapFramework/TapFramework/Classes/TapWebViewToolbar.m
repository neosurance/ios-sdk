#import "TapWebViewToolbar.h"
#import "Tap.h"
#import "TapSettings.h"

@implementation TapWebViewToolbar

@synthesize btnShare;

-(void)loadUi {
    [super loadUi];
    UIColor* bgcolor = [[TapSettings sharedInstance] color:TapSettingHeaderBackgroundColor];
    bgcolor = [bgcolor colorWithAlphaComponent:[[[TapSettings sharedInstance] number:TapSettingHeaderOpacity] floatValue]];
    self.backgroundColor = bgcolor;
    if([[[TapSettings sharedInstance] number:TapSettingBlurred] boolValue]) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[[[TapSettings sharedInstance] number:TapSettingBlurEffectStyle] intValue]];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:blurEffectView];
    }
    btnShare = [[TapButton alloc] initWithIcon:TapButtonIconShare];
    [self addSubview:btnShare];
    [btnShare addTarget:self action:@selector(shareUrl) forControlEvents:UIControlEventTouchUpInside];
}

-(void)shareUrl {
    [[NSNotificationCenter defaultCenter] postNotificationName:TapShare object:self];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    int bw = [[[TapSettings sharedInstance] number:TapSettingButtonWidth] intValue];
    btnShare.center = CGPointMake(size.width-bw*0.5, btnShare.center.y);
}

@end

