#import <UIKit/UIKit.h>
#import "TapControllerHeader.h"

@class MMMaterialDesignSpinner;

@interface TapController : UIViewController {
    MMMaterialDesignSpinner *spinner;
    UIView *spinnerBg;
    UIView* progressView;
    float progressPercentage;
    TapControllerHeader* header;
    NSDictionary* info;
    BOOL statusBarHidden;
    BOOL toggleUiEnabled;
}

@property (nonatomic, copy) NSDictionary* info;

- (void)loadUi;
- (void)unloadUi;
- (void)setupUi:(CGSize)size;
- (void)needsSetupUi;
- (void)setupUiAnimated;
- (void)waitOn;
- (void)waitOff;
- (void)didLoadUi;
- (void)didSetupUi;
- (void)didSetupUiAnimated;
- (void)pop;
- (void)toggleUi;
- (void)toggleUiAnimated;
- (void)updateProgress:(NSNumber*)percentage;
- (void)fileReady:(NSNotification*)notification;

@end
