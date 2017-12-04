#import "TapView.h"
#import "TapButton.h"

@interface TapHeader : TapView {
    UILabel* titleLabel;
    TapButton* cancelBtn;
    NSString* title;
}

@property (nonatomic, copy) NSString* title;

@end
