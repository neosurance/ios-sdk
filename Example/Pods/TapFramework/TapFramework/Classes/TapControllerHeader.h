#import "TapView.h"
#import "TapButton.h"

@interface TapControllerHeader : TapView {
    UILabel* titleLabel;
    NSString* title;
    TapButton* backBtn;
}

@property (nonatomic, copy) NSString* title;

@end
