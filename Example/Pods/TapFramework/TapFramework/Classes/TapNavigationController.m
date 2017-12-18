#import "TapNavigationController.h"
#import "TapSettings.h"
#import "Tap.h"

@implementation TapNavigationController

- (id)init {
    if (self = [super init]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(IS_IPHONEX) {
        statusBarBg = [[TapView alloc] init];
        [self.view addSubview:statusBarBg];
        statusBarBg.backgroundColor = [UIColor blackColor];
        statusBarBg.clipsToBounds = NO;
        statusBarBg.userInteractionEnabled = NO;
        topLeftMask = [[TopLeftMask alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        topLeftMask.backgroundColor = [UIColor clearColor];
        [statusBarBg addSubview:topLeftMask];
        topRightMask = [[TopRightMask alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        topRightMask.backgroundColor = [UIColor clearColor];
        [statusBarBg addSubview:topRightMask];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeChanged:) name:TapViewSizeChanged object:nil];
        [self needsSetupUi];
    }
}

- (void)sizeChanged:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(needsSetupUi) withObject:nil waitUntilDone:YES];
}

- (void)needsSetupUi {
    [self setupUi:self.view.frame.size];
}

- (void)setupUi:(CGSize)size {
    if(IS_IPHONEX) {
        NSLog(@"%@", self.view);
        float safeAreaLeft = 0;
        float safeAreaRight = 0;
        float safeAreaTop = 0;
        float safeAreaBottom = 0;
        if (@available(iOS 11.0, *)) {
            safeAreaRight = self.view.safeAreaInsets.right;
            safeAreaLeft = self.view.safeAreaInsets.left;
            safeAreaTop = self.view.safeAreaInsets.top;
            safeAreaBottom = self.view.safeAreaInsets.bottom;
        }
        [self.view bringSubviewToFront:statusBarBg];
        statusBarBg.frame = CGRectMake(0, 0, size.width, safeAreaTop);
        topLeftMask.frame = CGRectMake(0, safeAreaTop, topLeftMask.frame.size.width, topLeftMask.frame.size.height);
        topRightMask.frame = CGRectMake(size.width-topRightMask.frame.size.width, safeAreaTop, topRightMask.frame.size.width, topRightMask.frame.size.height);
        statusBarBg.alpha = (size.height > size.width)?1:0;
    }
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if(animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = [[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue];
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        [self.view.layer addAnimation:transition forKey:nil];
    }
    [super pushViewController:viewController animated:NO];
}

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if(animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = [[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue];
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [self.view.layer addAnimation:transition forKey:nil];
    }
    return [super popViewControllerAnimated:NO];
}

@end

@implementation TopLeftMask

- (void)drawRect:(CGRect)rect {
    float size = rect.size.width;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, size, 0);
    CGPathAddCurveToPoint(pathRef, NULL, size*0.48, 0, 0, size*0.48, 0, size);
    CGPathAddLineToPoint(pathRef, NULL, 0, 0);
    CGPathAddLineToPoint(pathRef, NULL, size, 0);
    CGPathCloseSubpath(pathRef);
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
    CGContextAddPath(ctx, pathRef);
    CGContextFillPath(ctx);
    CGPathRelease(pathRef);
}

@end

@implementation TopRightMask

- (void)drawRect:(CGRect)rect {
    float size = rect.size.width;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, size, size);
    CGPathAddCurveToPoint(pathRef, NULL, size, size*0.48, size*0.52, 0, 0, 0);
    CGPathAddLineToPoint(pathRef, NULL, size, 0);
    CGPathAddLineToPoint(pathRef, NULL, size, size);
    CGPathCloseSubpath(pathRef);
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
    CGContextAddPath(ctx, pathRef);
    CGContextFillPath(ctx);
    CGPathRelease(pathRef);
}

@end

