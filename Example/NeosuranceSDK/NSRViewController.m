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

    btnSetup = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSetup addTarget:self  action:@selector(setupNSR) forControlEvents:UIControlEventTouchUpInside];
    [btnSetup setTitle:@"Setup" forState:UIControlStateNormal];
    [self.view addSubview:btnSetup];
}
-(void)showApp {
    [[NeosuranceSDK sharedInstance] showApp];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    btnSetup.frame = btnSendEvent.frame = btnPolicies.frame = btnRegisterUser.frame = CGRectMake(0, 0, 160.0, 40.0);
    btnRegisterUser.center = CGPointMake(size.width/2, size.height/2-40.0);
    btnPolicies.center = CGPointMake(size.width/2, size.height/2);
    btnSendEvent.center = CGPointMake(size.width/2, size.height/2+40.0);
    btnSetup.center = CGPointMake(size.width/2, size.height/2+80.0);
}


-(void)registerUser {
    NSRUser* user = [[NSRUser alloc] init];
    user.email = @"gigio@c.com";
    user.code = @"gigio@c.com";
    user.firstname = @"giggio";
    user.lastname = @"giggio";
    [[NeosuranceSDK sharedInstance] registerUser:user];
}

-(void)setupNSR{
    NSMutableDictionary* settings = [[NSMutableDictionary alloc] init];
    [settings setObject:@"https://sandbox.neosurancecloud.net/sdk/api/v1.0/" forKey:@"base_url"];
    [settings setObject:@"ispTest" forKey:@"code"];
    [settings setObject:@"ozvj6iQQUVYVilVL7E" forKey:@"secret_key"];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"dev_mode"];
    [[NeosuranceSDK sharedInstance] setupWithDictionary:settings];
}

-(void)sendCustomEvent {
    NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
    [payload setObject:@"custom" forKey:@"type"];
    [[NeosuranceSDK sharedInstance] sendEvent:@"custom" payload:payload];
}

@end
