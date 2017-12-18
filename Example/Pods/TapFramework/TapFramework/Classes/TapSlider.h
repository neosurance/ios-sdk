#import "TapView.h"


typedef NS_ENUM(NSInteger, TapSliderStyle) {
    TapSliderStyleRect = 1,
    TapSliderStyleRounded
};

@class TapSlider;

@protocol TapSliderDelegate <NSObject>
@optional
- (void)onTapDown:(TapSlider*)slider;
- (void)onTapMove:(TapSlider*)slider;
- (void)onTapUp:(TapSlider*)slider;
- (void)onTapValueChanged:(TapSlider*)slider;
@end

@interface TapSlider : TapView {
    UIView* bg;
    UIView* indicator;
    float value;
    float touchValue;
    TapSliderStyle style;
    __weak id <TapSliderDelegate> delegate;
}

@property (nonatomic, weak) id <TapSliderDelegate> delegate;
@property float value;
@property TapSliderStyle style;

-(id)initWithStyle:(TapSliderStyle)style;
-(void)handleTouch:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)set:(float)value;
-(void)setAnimated:(float)newValue;
-(UIView*)bg;

@end

