#import "TapScrollView.h"
#import "Tap.h"

@implementation TapScrollView

- (id)init {
    if (self = [super init]) {
        if (@available(iOS 11.0, *)) {
            self.insetsLayoutMarginsFromSafeArea = NO;
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    endTap = [[touches anyObject] locationInView:self];
    NSUInteger tapCount = [touch tapCount];
    switch (tapCount) {
        case 1:
            [self performSelector:@selector(tap) withObject:nil afterDelay:.3];
            break;
        case 2:
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tap) object:nil];
            [self performSelector:@selector(doubleTap) withObject:nil afterDelay:0];
            break;
        default:
            break;
    }
}

- (void)tap {
    [[NSNotificationCenter defaultCenter] postNotificationName:TapScrollViewTap object:self];
}

- (void)doubleTap {
    if (self.maximumZoomScale == 1)
        return;
    CGSize size = self.frame.size;
    if (self.zoomScale == 1.0) {
        [self zoomToRect:CGRectMake(endTap.x - size.width / 8, endTap.y - size.height / 8, size.width / 4, size.height / 4) animated:YES];
    } else {
        [self setZoomScale:1.0 animated:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TapScrollViewDoubleTap object:self];
}

@end
