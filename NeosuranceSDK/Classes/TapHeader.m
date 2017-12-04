#import "TapHeader.h"
#import "TapSettings.h"

@implementation TapHeader

@synthesize title;

-(void)loadUi {
    self.backgroundColor = [[TapSettings sharedInstance] color:TapSettingHeaderBackgroundColor];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:blurEffectView];
    titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:12];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [[TapSettings sharedInstance] color:TapSettingHeaderColor];
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:titleLabel];
    cancelBtn = [[TapButton alloc] initWithIcon:TapButtonIconLeftOpen];
    [cancelBtn addTarget:self action:@selector(cancelTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
 }

-(void)cancelTouchUpInside {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TapHeaderCancelTouchUpInside" object:self];
}

-(void)setupUi:(CGSize)size {
    int bs = [[TapSettings sharedInstance] number:TapSettingButtonSize];
    int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
    titleLabel.text = title;
    titleLabel.frame = CGRectMake(size.width/5, sh, size.width*3/5, size.height-sh);
    cancelBtn.center = CGPointMake(size.width*1/10, size.height-bs/2);
}

-(void)setTitle:(NSString*)title {
    self->title = title;
    [self needsSetupUi];
}

@end
