#import "TapImageController.h"
#import "Tap.h"
#import "TapSettings.h"

@implementation TapImageController

-(void)loadUi {
    [super loadUi];
    self.view.backgroundColor = [UIColor blackColor];
    image = [[TapImage alloc] initWithDictionary:info];
    [self.view addSubview:image];
    toolbar = [[TapImageToolbar alloc] init];
    [self.view addSubview:toolbar];
    toolbar.alpha = 0;
    [[NSNotificationCenter defaultCenter] addObserver:image selector:@selector(shareImage:) name:TapShare object:toolbar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReady) name:TapImageReady object:image];
}

-(void)imageReady {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    toolbar.alpha = 1;
    [UIView commitAnimations];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    int hh = [[[TapSettings sharedInstance] number:TapSettingHeaderHeight] intValue];
    int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
    image.frame = CGRectMake(0, 0, size.width, size.height);
    toolbar.frame = CGRectMake(0, size.height-(hh+sh), size.width, hh+sh);
}

-(void)toggleUi {
    [super toggleUi];
    toolbar.alpha = header.alpha;
}

@end
