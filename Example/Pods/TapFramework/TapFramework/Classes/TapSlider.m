#import "TapSlider.h"
#import "TapSettings.h"
#import <QuartzCore/QuartzCore.h>

@implementation TapSlider

@synthesize value, delegate, style;

- (id)init {
    if (self = [super init]) {
        self.delegate = nil;
        style = TapSliderStyleRounded;
    }
    return self;
}

- (id)initWithStyle:(TapSliderStyle)theStyle {
    if (self = [super init]) {
        self.delegate = nil;
        style = theStyle;
    }
    return self;
}

-(void)loadUi {
    [super loadUi];
    bg = [[UIView alloc] init];
    bg.backgroundColor =  [UIColor colorWithWhite:1 alpha:0.25];
    [self addSubview:bg];
    indicator = [[UIView alloc] init];
    indicator.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    [self addSubview:indicator];
    value = 0;
}

-(UIView*)bg {
    return bg;
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    int pt = 16;
    int pb = 16;
    int pr = 8;
    int pl = 8;
    int ip = 2;
    float sw = size.width-pr-pl;
    float sh = size.height-pt-pb;
    if(style == TapSliderStyleRounded) {
        bg.frame = CGRectMake(pl-sh/2, pt, sw+sh, sh);
        bg.layer.cornerRadius = sh/2;
        indicator.frame = CGRectMake(fmin(fmax(0, pl+value*sw),size.width-pr-1)-sh/2+ip,pt+ip, sh-ip*2, sh-ip*2);
        indicator.layer.cornerRadius = sh/2-ip;
    } else {
        bg.frame = CGRectMake(pl, pt, sw, sh);
        indicator.frame = CGRectMake(fmin(fmax(0, pl+value*sw),size.width-pr-1),pt, 1, sh);
    }
    if([self.delegate respondsToSelector:@selector(onTapValueChanged:)]) {
        [self.delegate onTapValueChanged:self];
    }
}

-(void)set:(float)newValue {
    value = fmin(fmax(0, newValue),1);
    [self setupUi:self.frame.size];
}

-(void)setAnimated:(float)newValue {
    value = fmin(fmax(0, newValue),1);
    [self setupUiAnimated];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    touchValue = 0;
    [self handleTouch:touches withEvent:event];
    if([self.delegate respondsToSelector:@selector(onTapDown:)]) {
        [self.delegate onTapDown:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    touchValue = 0;
    [self handleTouch:touches withEvent:event];
    if([self.delegate respondsToSelector:@selector(onTapMove:)]) {
        [self.delegate onTapMove:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchValue = 0;
    [self handleTouch:touches withEvent:event];
    if([self.delegate respondsToSelector:@selector(onTapUp:)]) {
        [self.delegate onTapUp:self];
    }
}

- (void)handleTouch:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint tap = [[touches anyObject] locationInView:self];
    tap.x += touchValue;
    CGSize size = self.frame.size;
    int pr = 32;
    int pl = 32;
    float w = size.width-pr-pl;
    [self set:(tap.x-pl)/w];
}

@end
