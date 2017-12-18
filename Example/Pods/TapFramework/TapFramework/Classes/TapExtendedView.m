#import "TapExtendedView.h"

@implementation TapExtendedView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    for (UIView *subview in self.subviews) {
        CGPoint newPoint = [self convertPoint:point toView:subview];
        view = [subview hitTest:newPoint withEvent:event];
    }
    return view;
}

@end
