#import "Tap.h"
#import "TapUtils.h"
#import "TapData.h"
#import "TapSettings.h"
#import "TapController.h"

@implementation Tap

@synthesize resizeFull, delegate;

+ (id)sharedInstance {
    static Tap *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)sound:(TapSound)sound {
    [[TapSounds sharedInstance] playSound:sound];
 }

- (id)init {
    if (self = [super init]) {
        [TapUtils registerFont:[[NSBundle mainBundle] URLForResource:@"entypo" withExtension:@"ttf"]];
        [TapUtils registerFont:[[NSBundle mainBundle] URLForResource:@"fontawesome" withExtension:@"ttf"]];
        self.resizeFull = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeFullOn) name:TapResizeFull object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeFullOff) name:TapResizeSmall object:nil];
        [TapData sharedInstance];
   }
    return self;
}

-(void)resizeFullOn {
    self.resizeFull = YES;
}

-(void)resizeFullOff {
    self.resizeFull = NO;
}

- (UIWindow*)setApp:(UIViewController*)controller {
    UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.navigationController = [[TapNavigationController alloc] initWithRootViewController:controller];
    self.navigationController.navigationBarHidden = YES;
    window.backgroundColor = [UIColor blackColor];
    [window setRootViewController:self.navigationController];
    [window makeKeyAndVisible];
    return window;
}

- (void)share:(NSArray *)array sender:(UIView *)sender {
    TapController* controller = (TapController*)[[self navigationController] visibleViewController];
    if([controller isKindOfClass:[TapController class]]) {
        [controller waitOn];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    if ( [activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
        activityViewController.popoverPresentationController.sourceView = sender;
        activityViewController.popoverPresentationController.sourceRect = CGRectInset(sender.bounds, 8, 8);
    }
    [self.navigationController presentViewController:activityViewController animated:YES completion:^{
        if([controller isKindOfClass:[TapController class]]) {
            [controller waitOff];
        }
   }];
}

-(void)lightImpact {
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
}

-(void)mediumImpact {
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium] impactOccurred];
}

-(void)heavyImpact {
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy] impactOccurred];
}

-(void)pop:(BOOL)animated {
    [Tap sound:TapSoundTab1];
    [self.navigationController popViewControllerAnimated:animated];
}

- (void)push:(UIViewController*)controller animated:(BOOL)animated {
    [Tap sound:TapSoundTab2];
    [self.navigationController pushViewController:controller animated:animated];
}

- (float)safeHorizontalPadding {
    UIViewController* controller = self.navigationController.visibleViewController;
    if(controller.view.frame.size.width > controller.view.frame.size.height) {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    return 0.0f;
}

@end
