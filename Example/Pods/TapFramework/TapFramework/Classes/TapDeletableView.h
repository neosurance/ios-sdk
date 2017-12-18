#import "TapView.h"
#import "TapButton.h"

@interface TapDeletableView : TapView {
    CGPoint touchBeganLocation;
    float touchBeganX;
    UIView* deleteBg;
    TapButton* deleteBtn;
    BOOL moved;
    BOOL autoDelete;
    BOOL needsReset;
}

-(void)confirmDelete;
-(void)touchUpInside;
-(void)didSetupDeleteBg;
-(void)resetMe;

@end
