#import "TapDeletableView.h"
#import "TapSettings.h"
#import "TapController.h"
#import "Tap.h"

@implementation TapDeletableView

-(void)loadUi {
    [super loadUi];
    deleteBg = [[UIView alloc] init];
    [self addSubview:deleteBg];
    deleteBg.backgroundColor = [[TapSettings sharedInstance] color:TapSettingColorDanger];
    deleteBtn = [[TapButton alloc] initWithIcon:TapButtonIconTrash];
    [deleteBtn addTarget:self action:@selector(confirmDelete) forControlEvents:UIControlEventTouchUpInside];
    [deleteBg addSubview:deleteBtn];
    deleteBg.userInteractionEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetMe:) name:TapDeletableTouchesMoved object:nil];
}

-(void)resetMe:(NSNotification*)notification {
    if(notification.object != self) {
        [self resetMe];
        needsReset = YES;
    }
}

-(void)resetMe {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    CGRect rect = self.frame;
    rect.origin.x = 0;
    self.frame = rect;
    [UIView commitAnimations];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ( CGRectContainsPoint(deleteBg.frame, point) )
        return YES;
    return [super pointInside:point withEvent:event];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    deleteBg.frame = CGRectMake(size.width, 0, 0, size.height);
    int w = [[[TapSettings sharedInstance] number:TapSettingButtonWidth] intValue];
    deleteBtn.frame = CGRectMake(0, (size.height-w)/2, w, w);
    self.alpha = 1;
    [self didSetupDeleteBg];
}

-(void)touchUpInside {
    if(needsReset) return;
}

-(void)confirmDelete {
    if(needsReset) return;
    [self removeFromSuperview];
    TapController* controller = (TapController*)[[[Tap sharedInstance] navigationController] visibleViewController];
    if([controller isKindOfClass:[TapController class]]) {
        [controller setupUiAnimated];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    touchBeganLocation = [[touches anyObject] locationInView:[self superview]];
    touchBeganX = self.frame.origin.x;
    moved = NO;
    autoDelete = NO;
    needsReset = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(needsReset) return;
    [self handleTouch:touches withEvent:event];
    moved = YES;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(needsReset) return;
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(needsReset) return;
    if(touchBeganX == self.frame.origin.x && !moved) {
        [self touchUpInside];
    }
    int w = [[[TapSettings sharedInstance] number:TapSettingButtonWidth] intValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    deleteBtn.center = CGPointMake(w/2, self.frame.size.height/2);
    CGRect rect = self.frame;
    if(-self.frame.origin.x > [self superview].frame.size.width*3/4) {
        rect.origin.x = -self.frame.size.width;
        deleteBg.frame = CGRectMake(0, 0, self.frame.size.width*2, self.frame.size.height);
        [self confirmDelete];
        [self didSetupDeleteBg];
    } else if(-self.frame.origin.x > w) {
        rect.origin.x = -w;
    } else {
        rect.origin.x = 0;
    }
    self.frame = rect;
    [UIView commitAnimations];
}

- (void)handleTouch:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(needsReset) return;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    CGPoint tap = [[touches anyObject] locationInView:[self superview]];
    CGRect rect = self.frame;
    float x = touchBeganX+tap.x-touchBeganLocation.x;
    rect.origin.x = fmin(0, x);
    self.frame = rect;
    deleteBg.frame = CGRectMake(self.frame.size.width, 0, -self.frame.origin.x, self.frame.size.height);
    int w = [[[TapSettings sharedInstance] number:TapSettingButtonWidth] intValue];
    if(-self.frame.origin.x > [self superview].frame.size.width*3/4) {
        deleteBtn.center = CGPointMake(w/2, self.frame.size.height/2);
        if(autoDelete == NO) {
            UIImpactFeedbackGenerator* feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
            [feedbackGenerator impactOccurred];
            autoDelete = YES;
        }
    } else {
        deleteBtn.center = CGPointMake(fmax(w/2, deleteBg.frame.size.width-w/2), self.frame.size.height/2);
        if(autoDelete == YES) {
            UIImpactFeedbackGenerator* feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
            [feedbackGenerator impactOccurred];
           autoDelete = NO;
        }
    }
    [self didSetupDeleteBg];
    [UIView commitAnimations];
    if(deleteBg.alpha != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TapDeletableTouchesMoved object:self];
    }
}

-(void)didSetupDeleteBg {
    
}

@end
