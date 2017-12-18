#import "TapController.h"
#import "TapView.h"
#import "Tap.h"
#import "TapSettings.h"
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>
#import <UIColor_Utilities/UIColor+Expanded.h>

@implementation TapController

@synthesize info;

- (void)viewDidLoad {
    [super viewDidLoad];
    {
        TapView *controllerView = [[TapView alloc] init];
        self.view = controllerView;
        self.view.backgroundColor = [UIColor clearColor];
    }
    {
        UIColor* spinnerColor = [[TapSettings sharedInstance] color:TapSettingSpinnerColor];
        UIColor* spinnerBgColor = [[TapSettings sharedInstance] color:TapSettingSpinnerBackgroundColor];
        spinnerBgColor = [spinnerBgColor colorWithAlphaComponent:[[[TapSettings sharedInstance] number:TapSettingSpinnerBackgroundOpacity] floatValue]];
        spinnerBg = [[UIView alloc] init];
        spinnerBg.backgroundColor = spinnerBgColor;
        [self.view addSubview:spinnerBg];
        int spinnerSize = [[[TapSettings sharedInstance] number:TapSettingSpinnerSize] intValue];
        int spinnerLineWidth = [[[TapSettings sharedInstance] number:TapSettingSpinnerLineWidth] intValue];
        spinner = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, spinnerSize, spinnerSize)];
        spinner.lineCap = kCALineCapRound;
        spinner.lineWidth = spinnerLineWidth;
        spinner.tintColor = spinnerColor;
        [spinnerBg addSubview:spinner];
        spinnerBg.alpha = 0;
    }
    header = [[TapControllerHeader alloc] init];
    [header setTitle:info[TapDataTitleKey]];
    [self.view addSubview:header];
    progressView = [[UIView alloc] init];
    UIColor* progressColor = [[TapSettings sharedInstance] color:TapSettingProgressColor];
    progressView.backgroundColor = progressColor;
    [self.view addSubview:progressView];
    progressPercentage = 0;
    statusBarHidden = NO;
    toggleUiEnabled = YES;
     
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pop) name:TapHeaderBackTouchUpInside object:header];
    [self loadUi];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeChanged:) name:TapViewSizeChanged object:self.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleUiAnimated) name:TapScrollViewTap object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileError:) name:TapDataFileError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileReady:) name:TapDataFileReady object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileChanged:) name:TapDataFileChanged object:nil];
}

-(void)toggleUi {
    if(!toggleUiEnabled) {
        return;
    }
    if(header.alpha != 0) {
        statusBarHidden = YES;
    } else {
        statusBarHidden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    header.alpha = !header.alpha;
    [self setupUiAnimated];
}

-(void)fileError:(NSNotification*)notification {
}

-(void)fileChanged:(NSNotification*)notification {
    NSDictionary* file = notification.object;
    NSString* urlAsString = [NSString stringWithFormat:@"%@", info[TapDataUrlKey]];
    NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[TapDataUrlKey]];
    if([urlAsString compare:fileUrlAsString] == NSOrderedSame) {
        float percentage = [file[TapDataPercentageKey] floatValue];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:percentage] waitUntilDone:YES];
    }
}

-(void)fileReady:(NSNotification*)notification {
    progressPercentage = 1;
}

-(void)updateProgress:(NSNumber*)percentage {
    float safeAreaLeft = 0;
    float safeAreaRight = 0;
    float safeAreaTop = 0;
    float safeAreaBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaRight = self.view.safeAreaInsets.right;
        safeAreaLeft = self.view.safeAreaInsets.left;
        safeAreaTop = self.view.safeAreaInsets.top;
        safeAreaBottom = self.view.safeAreaInsets.bottom;
    }
    CGSize size = self.view.frame.size;
    progressPercentage = [percentage floatValue];
    int ph = [[[TapSettings sharedInstance] number:TapSettingProgressHeight] intValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    progressView.alpha = (progressPercentage != 0 && progressPercentage != 1);
    progressView.frame = CGRectMake(0,size.height-ph-safeAreaBottom,progressPercentage*size.width,ph);
    [UIView commitAnimations];
}

-(void)toggleUiAnimated {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    [self toggleUi];
    [UIView commitAnimations];
}

-(void)pop {
    [[Tap sharedInstance] pop:YES];
}

- (void)waitOn {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    spinnerBg.alpha = 1;
    [UIView commitAnimations];
    [spinner startAnimating];
}

- (void)waitOff {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    spinnerBg.alpha = 0;
    [UIView commitAnimations];
    [spinner stopAnimating];
}

- (void)setupUiAnimated {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didSetupUiAnimated)];
    [self setupUi:self.view.frame.size];
    [UIView commitAnimations];
}

- (void)didSetupUiAnimated {
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)sizeChanged:(NSNotification *)notification {
     [self performSelector:@selector(needsSetupUi) withObject:nil afterDelay:0];
}

- (void)loadUi {
     [self performSelector:@selector(didLoadUi) withObject:nil afterDelay:0];
}

- (void)unloadUi {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)needsSetupUi {
    [self setupUi:self.view.frame.size];
}

- (void)setupUi:(CGSize)size {
    float safeAreaLeft = 0;
    float safeAreaRight = 0;
    float safeAreaTop = 0;
    float safeAreaBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaRight = self.view.safeAreaInsets.right;
        safeAreaLeft = self.view.safeAreaInsets.left;
        safeAreaTop = self.view.safeAreaInsets.top;
        safeAreaBottom = self.view.safeAreaInsets.bottom;
    }
    spinner.center = CGPointMake(size.width / 2, size.height / 2);
    spinnerBg.frame = CGRectMake(0, 0, size.width, size.height);
    int hh = [[[TapSettings sharedInstance] number:TapSettingHeaderHeight] intValue];
    int ph = [[[TapSettings sharedInstance] number:TapSettingProgressHeight] intValue];
    progressView.alpha = (progressPercentage != 0 && progressPercentage != 1);
    progressView.frame = CGRectMake(0,size.height-ph-safeAreaBottom,progressPercentage*size.width,ph);
    int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
    header.frame = CGRectMake(0, 0, size.width, hh+sh+safeAreaTop);
    [self performSelector:@selector(didSetupUi) withObject:nil afterDelay:0];
}

- (void)didLoadUi {
}

- (void)didSetupUi {
    [self.view bringSubviewToFront:spinnerBg];
    [self.view bringSubviewToFront:header];
    [self.view bringSubviewToFront:progressView];
 }

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[[TapSettings sharedInstance] number:TapSettingStatusBarStyle] intValue];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self needsSetupUi];
}

@end

