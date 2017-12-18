#import "TapView.h"
#import "TapScrollView.h"

@class MMMaterialDesignSpinner;


typedef NS_ENUM(NSInteger, TapImageStyle) {
    TapImageStyleDefault = 1,
    TapImageStyleContainsLeft,
    TapImageStyleContains
};


@interface TapImage : TapView<UIScrollViewDelegate> {
    UIImageView* imageView;
    TapScrollView* scrollView;
    UIView* container;
    NSURL* localUrl;
    TapImageStyle imageStyle;
}

@property (nonatomic, copy) NSURL* localUrl;
@property TapImageStyle imageStyle;

-(void)shareImage:(NSNotification*)notification;

@end
