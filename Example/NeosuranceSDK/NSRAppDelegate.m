#import "NSRAppDelegate.h"
#import "NSRViewController.h"
#import <NeosuranceSDK/NeosuranceSDK.h>
#import <NeosuranceSDK/NSRRequest.h>
#import <NeosuranceSDK/NSRUtils.h>

@implementation NSRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSRViewController *controller = [[NSRViewController alloc] init];
    controller.view.backgroundColor = [UIColor darkGrayColor];
    UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBarHidden = YES;
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
    self.window = window;
    
    [self enablePushNotifications];

    NSMutableDictionary* settings = [[NSMutableDictionary alloc] init];
    [settings setObject:@"https://sandbox.neosurancecloud.net/sdk/api/v1.0/" forKey:@"base_url"];
    [settings setObject:@"com01" forKey:@"code"];
    [settings setObject:@"pass" forKey:@"secret_key"];
    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"dev_mode"];
    [[NeosuranceSDK sharedInstance] setupWithDictionary:settings];
   // [[NeosuranceSDK sharedInstance] stayInBackground];
    
    //[self sampleRegisterUser];
    //[self sampleSendCustomEvent];

    return YES;
}

-(void)enablePushNotifications {
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if(granted) {
                                  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                                  center.delegate = self;
                              }
                          }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler  {
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler  {
    if(![[NeosuranceSDK sharedInstance] forwardNotification:response withCompletionHandler:(void(^)(void))completionHandler]) {
        //TODO: handle your notification
    }
    completionHandler();
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
