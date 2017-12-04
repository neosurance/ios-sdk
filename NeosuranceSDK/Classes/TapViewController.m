#import "TapViewController.h"
#import "TapView.h"
#import "TapSettings.h"
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>

@implementation TapViewController

@synthesize info, showHeader;

- (void)viewDidLoad {
    [super viewDidLoad];
    showHeader = YES;
    TapView *controllerView = [[TapView alloc] init];
    self.view = controllerView;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeChanged:) name:@"TapViewSizeChanged" object:self.view];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.window.backgroundColor = self.view.backgroundColor;
    spinnerBg = [[UIView alloc] init];
    spinnerBg.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    [self.view addSubview:spinnerBg];
    spinner = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    spinner.lineWidth = 2;
    spinner.tintColor = [UIColor colorWithWhite:1 alpha:0.5];
    [spinnerBg addSubview:spinner];
    spinnerBg.alpha = 0;
    progressView = [[TapProgress alloc] init];
    [self.view addSubview:progressView];
    headerView = [[TapHeader alloc] init];
    [self.view addSubview:headerView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pop) name:@"TapHeaderCancelTouchUpInside" object:headerView];
    [self loadUi];
}

-(void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)waitOn {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    spinnerBg.alpha = 1;
    [UIView commitAnimations];
    [spinner startAnimating];
}

- (void)waitOff {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    spinnerBg.alpha = 0;
    [UIView commitAnimations];
    [spinner stopAnimating];
}

- (void)setupUiAnimated {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didSetupUiAnimated)];
    [self setupUi:self.view.frame.size];
    [UIView commitAnimations];
}

- (void)didSetupUiAnimated {
}

- (void)sizeChanged:(NSNotification *)notification {
    UIView *view = notification.object;
    [self setupUi:view.frame.size];
}

- (void)loadUi {
    [headerView setTitle:info[@"title"]];
//    self.edgesForExtendedLayout = UIRectEdgeAll;
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self performSelector:@selector(didLoadUi) withObject:nil afterDelay:0];
}

- (void)unloadUi {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)needsSetupUi {
    [self setupUi:self.view.frame.size];
}

- (void)setupUi:(CGSize)size {
    spinner.center = CGPointMake(size.width / 2, size.height / 2);
    spinnerBg.frame = CGRectMake(0, 0, size.width, size.height);
    int hh = [[[TapSettings sharedInstance] valueOf:TapSettingHeaderHeight] intValue];
    int ph = [[[TapSettings sharedInstance] valueOf:TapSettingProgressHeight] intValue];
    int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
    if(showHeader) {
        headerView.frame = CGRectMake(0, 0, size.width, hh+sh);
        progressView.frame = CGRectMake(0, size.height-((progressView.value == 0 || progressView.value == 1)?0:(ph+sh)), size.width, ph+sh);
    } else {
        headerView.frame = CGRectMake(0, -(hh+sh), size.width, hh+sh);
        progressView.frame = CGRectMake(0, size.height-((progressView.value == 0 || progressView.value == 1)?0:(ph+sh)), size.width, ph+sh);
    }
     [self performSelector:@selector(didSetupUi) withObject:nil afterDelay:0];
}

- (void)didLoadUi {
}

- (void)didSetupUi {
    [self.view bringSubviewToFront:spinnerBg];
    [self.view bringSubviewToFront:headerView];
    [self.view bringSubviewToFront:progressView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
