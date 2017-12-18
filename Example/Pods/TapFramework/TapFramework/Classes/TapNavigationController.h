#import <UIKit/UIKit.h>
#import "TapView.h"


@interface TopLeftMask : UIView

@end
@interface TopRightMask : UIView

@end

@interface TapNavigationController : UINavigationController {
    TapView *statusBarBg;
    TopLeftMask* topLeftMask;
    TopRightMask* topRightMask;
}

@end


