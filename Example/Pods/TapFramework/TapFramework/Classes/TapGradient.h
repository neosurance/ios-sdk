#import <UIKit/UIKit.h>

@interface TapGradient : UIView {
    CAGradientLayer *gradient;
}

- (id)initWithColorA:(UIColor *)colorA colorB:(UIColor *)colorB horizontal:(BOOL)horizontal;

@end
