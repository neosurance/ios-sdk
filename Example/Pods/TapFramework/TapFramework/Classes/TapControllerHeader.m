#import "TapControllerHeader.h"
#import "TapSettings.h"
#import "Tap.h"

@implementation TapControllerHeader

@synthesize title;

-(void)loadUi {
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
    titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:[[[TapSettings sharedInstance] number:TapSettingFontSize] intValue]];
    //titleLabel.font = [UIFont boldSystemFontOfSize:[[[TapSettings sharedInstance] number:TapSettingFontSize] intValue]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [[TapSettings sharedInstance] color:TapSettingHeaderForegroundColor];
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.numberOfLines = 1;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:titleLabel];
    backBtn = [[TapButton alloc] initWithIcon:TapButtonIconLeftOpen];
    UINavigationController* navigationController = [[Tap sharedInstance] navigationController];
    if([[navigationController viewControllers] count] != 1) {
        [backBtn addTarget:self action:@selector(cancelTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backBtn];
    }
}

-(void)cancelTouchUpInside {
    [[NSNotificationCenter defaultCenter] postNotificationName:TapHeaderBackTouchUpInside object:self];
}

-(void)setupUi:(CGSize)size {
    float safeAreaLeft = 0;
    float safeAreaRight = 0;
    float safeAreaTop = 0;
    float safeAreaBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaRight = [self superview].safeAreaInsets.right;
        safeAreaLeft = [self superview].safeAreaInsets.left;
        safeAreaTop = [self superview].safeAreaInsets.top;
        safeAreaBottom = [self superview].safeAreaInsets.bottom;
    }
   int bw = [[[TapSettings sharedInstance] number:TapSettingButtonWidth] intValue];
    int bh = [[[TapSettings sharedInstance] number:TapSettingButtonHeight] intValue];
    //int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
    titleLabel.text = title;
    titleLabel.frame = CGRectMake(bw, size.height-bh, size.width-bw*2, bh);
    backBtn.center = CGPointMake(bw/2+safeAreaLeft, size.height-bh/2);
}

-(void)setTitle:(NSString*)title {
    self->title = title;
    [self needsSetupUi];
}

@end
