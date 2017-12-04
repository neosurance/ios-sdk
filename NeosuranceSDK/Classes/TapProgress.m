#import "TapProgress.h"
#import "TapSettings.h"
#import <QuartzCore/QuartzCore.h>

@implementation TapProgress

@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        self.delegate = nil;
    }
    return self;
}

-(void)loadUi {
    self.backgroundColor = [[TapSettings sharedInstance] color:TapSettingHeaderBackgroundColor];
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    blurEffectView.frame = self.bounds;
//    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self addSubview:blurEffectView];
    downloadBg = [[UIView alloc] init];
    downloadBg.backgroundColor = [[TapSettings sharedInstance] color:TapSettingProgressBarBackgroundColor];
    int h = [[TapSettings sharedInstance] number:TapSettingProgressBarHeight];
    downloadBg.layer.cornerRadius = h/2;
    downloadBg.clipsToBounds = YES;
    [self addSubview:downloadBg];
    downloadProgress = [[UIView alloc] init];
    downloadProgress.backgroundColor = [[TapSettings sharedInstance] color:TapSettingProgressBarColor];
    [downloadBg addSubview:downloadProgress];
    downloadLabel = [[UILabel alloc] init];
    downloadLabel.font = [UIFont boldSystemFontOfSize:10];
    downloadLabel.textAlignment = NSTextAlignmentCenter;
    downloadLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    [self addSubview:downloadLabel];
    downloadCancelBtn = [[TapButton alloc] initWithIcon:TapButtonIconCancel];
    [downloadCancelBtn addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:downloadCancelBtn];
    self.value = 0;
}

-(void)cancelDownload {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TapProgressCancelDownload" object:self];
}

-(void)setupUi:(CGSize)size {
    int bs = [[TapSettings sharedInstance] number:TapSettingButtonSize];
    int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
    int h = [[TapSettings sharedInstance] number:TapSettingProgressBarHeight];
    int p = (size.height-h-sh)/2;
    downloadBg.frame = CGRectMake(size.width/5,p,size.width*3/5,h);
    float percentage = fmax(0,fmin(1,self.value));
    downloadProgress.frame = CGRectMake(0,0,percentage*downloadBg.frame.size.width,h);
    downloadLabel.text = [NSString stringWithFormat:@"%.f%%", percentage*100];
    downloadLabel.frame = CGRectMake(0,0,size.width/5,size.height-sh);
    downloadCancelBtn.center = CGPointMake(size.width*9/10, bs/2);
    if(percentage == 1.0f) {
        if([self.delegate respondsToSelector:@selector(onComplete:)]) {
            [self.delegate onComplete:self];
        }
    }
 }

@end
