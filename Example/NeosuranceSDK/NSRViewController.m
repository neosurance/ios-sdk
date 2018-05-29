#import "NSRViewController.h"
#import <NeosuranceSDK/NeosuranceSDK.h>

@implementation NSRViewController

-(void)loadUi {
    [super loadUi];
    header.alpha = 0;
    btnPolicies = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPolicies addTarget:self  action:@selector(showApp) forControlEvents:UIControlEventTouchUpInside];
    [btnPolicies setTitle:@"Policies" forState:UIControlStateNormal];
    [self.view addSubview:btnPolicies];
    btnRegisterUser = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRegisterUser addTarget:self  action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    [btnRegisterUser setTitle:@"Register User" forState:UIControlStateNormal];
    [self.view addSubview:btnRegisterUser];
    btnSendEvent = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSendEvent addTarget:self  action:@selector(sendCustomEvent) forControlEvents:UIControlEventTouchUpInside];
    [btnSendEvent setTitle:@"Send Event" forState:UIControlStateNormal];
    [self.view addSubview:btnSendEvent];
}
-(void)showApp {
    [[NeosuranceSDK sharedInstance] showApp];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    btnSendEvent.frame = btnPolicies.frame = btnRegisterUser.frame = CGRectMake(0, 0, 160.0, 40.0);
    btnRegisterUser.center = CGPointMake(size.width/2, size.height/2-40.0);
    btnPolicies.center = CGPointMake(size.width/2, size.height/2);
    btnSendEvent.center = CGPointMake(size.width/2, size.height/2+40.0);
}


-(void)registerUser {
    NSRUser* user = [[NSRUser alloc] init];
    user.email = @"gigio@c.com";
    user.code = @"gigio@c.com";
    user.firstname = @"giggio";
    user.lastname = @"giggio";
    [[NeosuranceSDK sharedInstance] registerUser:user];
}

-(void)sendCustomEvent {
    NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
    [payload setObject:@"custom" forKey:@"type"];
    [[NeosuranceSDK sharedInstance] sendEvent:@"custom" payload:payload];
}

@end
