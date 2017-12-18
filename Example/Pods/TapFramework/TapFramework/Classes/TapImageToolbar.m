#import "TapImageToolbar.h"
#import "TapSettings.h"
#import "Tap.h"

@implementation TapImageToolbar

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
    btnResizeFull = [[TapButton alloc] initWithIcon:TapButtonIconResizeFull];
    [self addSubview:btnResizeFull];
    [btnResizeFull addTarget:self action:@selector(resizeFullOn) forControlEvents:UIControlEventTouchUpInside];
    btnResizeSmall = [[TapButton alloc] initWithIcon:TapButtonIconResizeSmall];
    [self addSubview:btnResizeSmall];
    [btnResizeSmall addTarget:self action:@selector(resizeFullOff) forControlEvents:UIControlEventTouchUpInside];
    if([[Tap sharedInstance] resizeFull]) {
        btnResizeFull.alpha = 0;
    } else {
        btnResizeSmall.alpha = 0;
    }
    btnShare = [[TapButton alloc] initWithIcon:TapButtonIconShare];
    [self addSubview:btnShare];
    [btnShare addTarget:self action:@selector(shareImage) forControlEvents:UIControlEventTouchUpInside];
}

-(void)resizeFullOn {
    [self resize:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:TapResizeFull object:self];
}

-(void)resizeFullOff {
    [self resize:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:TapResizeSmall object:self];
}

-(void)shareImage {
    [[NSNotificationCenter defaultCenter] postNotificationName:TapShare object:self];
}

-(void)resize:(BOOL)full {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    btnResizeFull.alpha = !full;
    btnResizeSmall.alpha = full;
    [UIView commitAnimations];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    int bw = [[[TapSettings sharedInstance] number:TapSettingButtonWidth] intValue];
    btnResizeSmall.center = CGPointMake(size.width-bw*1.5, btnResizeSmall.center.y);
    btnResizeFull.center = CGPointMake(size.width-bw*1.5, btnResizeFull.center.y);
    btnShare.center = CGPointMake(size.width-bw*0.5, btnShare.center.y);
}

@end
