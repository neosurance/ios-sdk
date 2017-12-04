#import <UIKit/UIKit.h>
#import "TapProgress.h"
#import "TapHeader.h"

@class MMMaterialDesignSpinner;


@interface TapViewController : UIViewController {
    MMMaterialDesignSpinner *spinner;
    UIView *spinnerBg;
    TapProgress* progressView;
    TapHeader* headerView;
    NSDictionary* info;
    BOOL showHeader;
}

@property (nonatomic, copy) NSDictionary* info;
@property BOOL showHeader;

- (void)loadUi;
- (void)unloadUi;
- (void)setupUi:(CGSize)size;
- (void)needsSetupUi;
- (void)setupUiAnimated;
- (void)waitOn;
- (void)waitOff;
- (void)didLoadUi;
- (void)didSetupUi;
- (void)pop;

@end

