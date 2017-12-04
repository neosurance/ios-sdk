#import "TapView.h"
#import "TapButton.h"


@class TapProgress;

@protocol TapProgressDelegate <NSObject>
@optional
- (void)onComplete:(TapProgress*)progress;
@end

@interface TapProgress : TapView {
    UIView* downloadProgress;
    UIView* downloadBg;
    UILabel* downloadLabel;
    TapButton* downloadCancelBtn;
    __weak id <TapProgressDelegate> delegate;
}

@property (nonatomic, weak) id <TapProgressDelegate> delegate;

@property float value;

@end
