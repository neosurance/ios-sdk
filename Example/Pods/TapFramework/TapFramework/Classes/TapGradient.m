#import "TapGradient.h"

@implementation TapGradient

- (id)initWithColorA:(UIColor *)colorA colorB:(UIColor *)colorB horizontal:(BOOL)horizontal {
    self = [super init];
    if (self) {
        [self setupWithColorA:colorA colorB:colorB horizontal:horizontal];
    }
    return self;
}

- (void)setupWithColorA:(UIColor *)colorA colorB:(UIColor *)colorB horizontal:(BOOL)horizontal {
    gradient = [CAGradientLayer layer];
    gradient.colors = [NSArray arrayWithObjects:(id)[colorA CGColor], (id)[colorB CGColor], nil];
    gradient.startPoint = horizontal ? CGPointMake(0, 0.5) : CGPointMake(0.5, 0);
    gradient.endPoint = horizontal ? CGPointMake(1, 0.5) : CGPointMake(0.5, 1);
    [self.layer insertSublayer:gradient atIndex:0];
}

- (void)layoutSubviews {
    gradient.frame = self.bounds;
}

@end
