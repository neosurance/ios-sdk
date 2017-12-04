#import "NSRViewController.h"
#import <NeosuranceSDK/NeosuranceSDK.h>

@implementation NSRViewController

-(void)loadUi {
    [super loadUi];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self  action:@selector(showApp) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"Policies" forState:UIControlStateNormal];
    btn.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [self.view addSubview:btn];}

-(void)showApp {
    [[NeosuranceSDK sharedInstance] showApp];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    btn.center = CGPointMake(size.width/2, size.height/2);
}

@end
