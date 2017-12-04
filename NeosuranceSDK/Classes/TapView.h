#import <UIKit/UIKit.h>

@interface TapView : UIView {
    CGSize previousSize;
    NSDictionary* info;
}

@property (nonatomic, copy) NSDictionary* info;

- (void)loadUi;
- (void)unloadUi;
- (void)setupUi:(CGSize)size;
- (void)needsSetupUi;
- (void)setupUiAnimated;
- (void)didLoadUi;
- (void)didSetupUi;

@end
