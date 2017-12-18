#import "TapView.h"
#import "TapButton.h"

@interface TapImageToolbar : TapView {
    TapButton* btnResizeFull;
    TapButton* btnResizeSmall;
    TapButton* btnShare;
}

@property (readonly) TapButton* btnShare;

@end
