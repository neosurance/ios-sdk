#import "TapSliderWheel.h"
#import "TapSettings.h"

@implementation TapSliderWheel

-(void)loadUi {
    [super loadUi];
    bg.alpha = 0;
    value = 0.5;
    gradient1 = [[TapGradient alloc] initWithColorA:[UIColor colorWithWhite:1 alpha:0] colorB:[UIColor colorWithWhite:1 alpha:0.25] horizontal:YES];
    [self addSubview:gradient1];
    gradient2 = [[TapGradient alloc] initWithColorA:[UIColor colorWithWhite:1 alpha:0.25] colorB:[UIColor colorWithWhite:1 alpha:0] horizontal:YES];
    [self addSubview:gradient2];
 }

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    for(UIView* view in [indicator subviews]) {
        [view removeFromSuperview];
    }
    int pt = 16;
    int pb = 16;
    int pr = 8;
    int pl = 8;
    int wp = 4;
    int ws = 12;
     float x = 0;
    while(x < indicator.frame.origin.x-pl) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(-x, wp, 1, indicator.frame.size.height - wp*2)];
        [indicator addSubview:view];
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:(1-x/fabs(indicator.frame.origin.x-pl))/10];
        x += ws;
    }
    x = 0;
    while(x < size.width-pr-indicator.frame.origin.x) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(x, wp, 1, indicator.frame.size.height - wp*2)];
        [indicator addSubview:view];
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:(1-x/fabs(size.width-pr-indicator.frame.origin.x))/10];
        x += ws;
    }
    gradient1.frame = CGRectMake(pl, pt, size.width/2-pl, size.height - pt - pb);
    gradient2.frame = CGRectMake(size.width/2, pt, size.width/2-pr, size.height - pt - pb);
    indicator.alpha = 0.5+0.5*(1-fabs(size.width/2-indicator.frame.origin.x)/(size.width/2));
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGSize size = self.frame.size;
    int pr = 8;
    int pl = 8;
    float pw = size.width-pr-pl;
    CGPoint tap = [[touches anyObject] locationInView:self];
    float startx = value*pw+pl;
    float tapx = tap.x;
    touchValue = startx-tapx;
    [self handleTouch:touches withEvent:event];
    if([self.delegate respondsToSelector:@selector(onTapDown:)]) {
        [self.delegate onTapDown:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouch:touches withEvent:event];
    if([self.delegate respondsToSelector:@selector(onTapMove:)]) {
        [self.delegate onTapMove:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self.delegate respondsToSelector:@selector(onTapUp:)]) {
        [self.delegate onTapUp:self];
    }
}

@end
