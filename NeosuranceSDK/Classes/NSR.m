#import "NSR.h"
#import "NSRUtils.h"
#import "NSRRequest.h"
#import <AFNetworking/AFNetworking.h>
#import <TapFramework/TapUtils.h>
#import <TapFramework/TapData.h>
#import <TapFramework/TapWebController.h>

@implementation NSR

@synthesize settings, user, authSettings, context, player, motionActivityManager, locationManager, demoSettings;

+ (id)sharedInstance {
    static NSR *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventNetworkReachabilityFromNotification:) name:@"NSREventNetworkReachability" object:nil];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NSREventNetworkReachability" object:[NSNumber numberWithInt:status]];
        }];
        context = [[NSMutableDictionary alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager requestAlwaysAuthorization];
        self.motionActivityManager = [[CMMotionActivityManager alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPush:) name:@"NSRPush" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushIncoming:) name:@"NSRPushIncoming" object:nil];
    }
    return self;
}

- (void)onMessage:(TapWebView*)webView body:(NSDictionary*)body {
    if([@"close" compare:body[@"what"]] == NSOrderedSame) {
        [navigationController popViewControllerAnimated:YES];
    }
    if([@"init" compare:body[@"what"]] == NSOrderedSame) {
        [[NSR sharedInstance] token:^(NSString *token) {
            NSLog(@"%@", token);
            NSDictionary* settings = [[NSR sharedInstance] settings];
            NSMutableDictionary* message = [[NSMutableDictionary alloc] init];
            [message setObject:settings[@"base_url"] forKey:@"api"];
            [message setObject:token forKey:@"token"];
            [message setObject:@"it" forKey:@"lang"];
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message options:0 error:&error];
            NSString* json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString* js = [NSString stringWithFormat:@"%@(%@)",body[@"callBack"], json];
            NSLog(@"%@", js);
            [webView evaluateJavaScript:js];
        }];
    }
}

-(void)sendEvent:(NSString*)name payload:(NSDictionary*)payload {
    NSRRequest* request = [[NSRRequest alloc] init];
    request.event = [NSRUtils makeEvent:name payload:payload];
    [request send];
}


-(void)showApp {
    NSDictionary* settings = [[NSR sharedInstance] authSettings];
    TapWebController* controller = [[TapWebController alloc] init];
    controller.delegate = self;
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSURL URLWithString:settings[@"app_url"]] forKey:@"url"];
    controller.info = dict;
    [navigationController pushViewController:controller animated:YES];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NSRPushIncoming" object:response.notification.request.content.userInfo];
}

-(void)pushIncoming:(NSNotification*)notification {
    NSDictionary* dictionary = notification.object;
   TapWebController* controller = [[TapWebController alloc] init];
    controller.delegate = self;
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSURL URLWithString:dictionary[@"url"]] forKey:@"url"];
    controller.info = dict;
    [navigationController pushViewController:controller animated:YES];
}

-(void)showPush:(NSNotification*)notification {
    [TapUtils play:[[NSRUtils frameworkBundle] URLForResource:@"push" withExtension:@"wav"]];
    NSDictionary* push = notification.object;
    [self sendLocalNotificationWithTitle:push[@"title"] body:push[@"body"] payload:push];
}

- (void)sendLocalNotificationWithTitle:(NSString*)title body:(NSString*)body payload:(NSDictionary*)payload {
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    [content setTitle:title];
    [content setBody:body];
    NSMutableDictionary* nsrPayload = [[NSMutableDictionary alloc] initWithDictionary:payload];
    [nsrPayload setObject:@"NSR" forKey:@"provider"];
    [content setUserInfo:nsrPayload];
    //NSURL *attachmentUrl  = [[NSBundle mainBundle] URLForResource:@"attachment" withExtension:@"png"];
    //UNNotificationAttachment* attachment = [UNNotificationAttachment attachmentWithIdentifier:@"attachment" URL:attachmentUrl options:nil error:nil];
    //[content setAttachments:[NSArray arrayWithObjects:attachment, nil]];
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%@", [NSDate date]] content:content trigger:trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
}

- (BOOL)forwardNotification:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary* userInfo = response.notification.request.content.userInfo;
    if(userInfo != nil && [@"NSR" isEqualToString:userInfo[@"provider"]]) {
        TapWebController* controller = [[TapWebController alloc] init];
        controller.delegate = self;
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSURL URLWithString:userInfo[@"url"]] forKey:@"url"];
        controller.info = dict;
        [navigationController pushViewController:controller animated:YES];
       return YES;
    }
    return NO;
}


-(void)eventNetworkReachabilityFromNotification:(NSNotification*)notification {
    [self eventNetworkReachability:(AFNetworkReachabilityStatus)[notification.object intValue]];
}

-(void)eventNetworkReachability:(AFNetworkReachabilityStatus) status {
    int enabled = 1;
    enabled = [[NSString stringWithFormat:@"%@", self.authSettings[@"conf"][@"connection"][@"enabled"]] intValue];
    if(enabled == 1) {
        NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
        if(status == AFNetworkReachabilityStatusUnknown) {
            [payload setObject:@"unknown" forKey:@"type"];
        } else if (status == AFNetworkReachabilityStatusNotReachable) {
            [payload setObject:@"not-reachable" forKey:@"type"];
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [payload setObject:@"wi-fi" forKey:@"type"];
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            [payload setObject:@"mobile" forKey:@"type"];
        }
        if([payload[@"type"] compare:context[@"connectionType"]] != NSOrderedSame) {
            [context setObject:payload[@"type"] forKey:@"connection-type"];
            NSRRequest* request = [[NSRRequest alloc] init];
            request.event = [NSRUtils makeEvent:@"connection" payload:payload];
            [request send];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    int enabled = 1;
    enabled = [[NSString stringWithFormat:@"%@", self.authSettings[@"conf"][@"position"][@"enabled"]] intValue];
    if(enabled == 1) {
        NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
        [payload setObject:[NSNumber numberWithFloat:newLocation.coordinate.latitude] forKey:@"latitude"];
        [payload setObject:[NSNumber numberWithFloat:newLocation.coordinate.longitude] forKey:@"longitude"];
        [payload setObject:[NSNumber numberWithFloat:oldLocation.coordinate.latitude] forKey:@"old-latitude"];
        [payload setObject:[NSNumber numberWithFloat:oldLocation.coordinate.longitude] forKey:@"old-longitude"];
        NSRRequest* request = [[NSRRequest alloc] init];
        request.event = [NSRUtils makeEvent:@"position" payload:payload];
        [request send];
    }
}

-(void)nsrIdle {
    NSLog(@"%@", context);
    int enabled = 1;
    enabled = [[NSString stringWithFormat:@"%@", self.authSettings[@"conf"][@"power"][@"enabled"]] intValue];
    if(enabled == 1)
    {
        UIDeviceBatteryState batteryState = [[UIDevice currentDevice] batteryState];
        int batteryLevel = (int)([[UIDevice currentDevice] batteryLevel]*100);
        NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
        [payload setObject:[NSString stringWithFormat:@"%d", batteryLevel] forKey:@"level"];
        if(batteryState == UIDeviceBatteryStateUnplugged) {
            [payload setObject:@"unplugged" forKey:@"type"];
        } else {
            [payload setObject:@"plugged" forKey:@"type"];
        }
        if([payload[@"type"] compare:context[@"battery-state"]] != NSOrderedSame) {
            [context setObject:payload[@"type"] forKey:@"battery-state"];
            NSRRequest* request = [[NSRRequest alloc] init];
            request.event = [NSRUtils makeEvent:@"power" payload:payload];
            [request send];
        }
    }
    enabled = 1;
    enabled = [[NSString stringWithFormat:@"%@", self.authSettings[@"conf"][@"activity"][@"enabled"]] intValue];
    if(enabled == 1)
    {
        [self.motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
            NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
            if(activity.walking)  {
                [payload setObject:@"walk" forKey:@"type"];
            } else if(activity.stationary)  {
                [payload setObject:@"still" forKey:@"type"];
            } else if(activity.automotive)  {
                [payload setObject:@"car" forKey:@"type"];
            } else if(activity.running)  {
                [payload setObject:@"run" forKey:@"type"];
            } else if(activity.cycling)  {
                [payload setObject:@"bicycle" forKey:@"type"];
            } else  {
                [payload setObject:@"unknown" forKey:@"type"];
            }
            if(activity.confidence == CMMotionActivityConfidenceLow) {
                [payload setObject:@"25" forKey:@"confidence"];
            } else if(activity.confidence == CMMotionActivityConfidenceMedium) {
                [payload setObject:@"50" forKey:@"confidence"];
            } else if(activity.confidence == CMMotionActivityConfidenceHigh) {
                [payload setObject:@"100" forKey:@"confidence"];
            }
            int confidence = [payload[@"confidence"] intValue];
            int minConfidence = [[NSString stringWithFormat:@"%@", self.authSettings[@"conf"][@"activity"][@"confidence"]] intValue];
            if(confidence >= minConfidence) {
                if([payload[@"type"] compare:context[@"activity-type"]] != NSOrderedSame && [payload[@"type"] compare:@"unknown"] != NSOrderedSame) {
                    [context setObject:payload[@"type"] forKey:@"activity-type"];
                    NSRRequest* request = [[NSRRequest alloc] init];
                    request.event = [NSRUtils makeEvent:@"activity" payload:payload];
                    [request send];
                }
            }
        }];
    }
    int delayInSeconds = 300;
    delayInSeconds = [[NSString stringWithFormat:@"%@", self.authSettings[@"conf"][@"time"]] intValue];
    NSLog(@"delay in seconds: %d", delayInSeconds);
    [self performSelector:@selector(nsrIdle) withObject:nil afterDelay:delayInSeconds];
}

- (void)token:(void (^)(NSString* token))completionHandler {
    [self authorize:^(BOOL authorized) {
        if(authorized) {
            completionHandler(self.authSettings[@"auth"][@"token"]);
        } else {
            completionHandler(nil);
        }
    }];
}

-(void)authorize:(void (^)(BOOL authorized))completionHandler {
    NSR* nsr = self;
    self.authSettings = [[NSDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"authSettings"]];
    int remainingSeconds = [NSRUtils tokenRemainingSeconds:self.authSettings];
    if(remainingSeconds > 0) {
        if(completionHandler != nil) {
            completionHandler(YES);
        }
    } else {
        @try {
            NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
            [payload setObject:nsr.user.code forKey:@"user_code"];
            [payload setObject:nsr.settings[@"code"] forKey:@"code"];
            [payload setObject:nsr.settings[@"secret_key"] forKey:@"secret_key"];
            NSMutableDictionary* sdkPayload = [[NSMutableDictionary alloc] init];
            [sdkPayload setObject:[nsr version] forKey:@"version"];
            [sdkPayload setObject:nsr.settings[@"dev_mode"] forKey:@"dev"];
            [sdkPayload setObject:[nsr os] forKey:@"os"];
            [payload setObject:sdkPayload forKey:@"sdk"];
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
            NSString* json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", json);
           json = [json stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
             NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@authorize?payload=%@", nsr.settings[@"base_url"], json]];
            NSLog(@"%@", url);
            [TapData requestWithURL:url completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"NSR Error: %@", error);
                } else {
                    NSLog(@"NSR Response: %@", responseObject);
                    self.authSettings = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
                    [[NSUserDefaults standardUserDefaults] setObject:self.authSettings forKey:@"authSettings"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    int remainingSeconds = [NSRUtils tokenRemainingSeconds:self.authSettings];
                    completionHandler(remainingSeconds > 0);
                }
            }];
        } @catch (NSException *e) {
            completionHandler(NO);
        }
    }
}

- (void)setupWithDictionary:(NSDictionary*)settings navigationController:(UINavigationController*)_navigationController {
    navigationController = _navigationController;
    NSMutableDictionary* mutableSettings = [[NSMutableDictionary alloc] initWithDictionary:settings];
    NSLog(@"%@", mutableSettings);
    if(mutableSettings[@"ns_lang"] == nil) {
        NSString * language = [[NSLocale preferredLanguages] firstObject];
        NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
        [mutableSettings setObject:languageDic[NSLocaleLanguageCode] forKey:@"ns_lang"];
    }
    if(mutableSettings[@"dev_mode"]  == nil) {
        [mutableSettings setObject:[NSNumber numberWithInt:0] forKey:@"dev_mode"];
    }
   self.settings = mutableSettings;
    if(settings[@"base_demo_url"] != nil) {
        NSString* demoCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"demo_code"];
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:settings[@"base_demo_url"], demoCode]];
        [TapData requestWithURL:url completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"NSR Error: %@", error);
            } else {
                self.demoSettings = responseObject;
                NSLog(@"NSR demoSettings: %@", demoSettings);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NSRIncomingDemoSettings" object:nil];
                [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"code"] forKey:@"demo_code"];
                [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"demo_settings"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSMutableDictionary* appSettings = [[NSMutableDictionary alloc] init];
                [appSettings setObject:settings[@"base_url"] forKey:@"base_url"];
                [appSettings setObject:responseObject[@"secretKey"] forKey:@"secret_key"];
                [appSettings setObject:responseObject[@"communityCode"] forKey:@"code"];
                [appSettings setObject:responseObject[@"devMode"] forKey:@"dev_mode"];
                [self setupWithDictionary:appSettings navigationController:navigationController];
                NSRUser* user = [[NSRUser alloc] init];
                user.email = responseObject[@"email"];
                user.code = responseObject[@"code"];
                user.firstname = responseObject[@"firstname"];
                user.lastname = responseObject[@"lastname"];
                [self setUser:user];
                [self authorize:^(BOOL authorized) {
                    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
                    [locationManager startMonitoringSignificantLocationChanges];
                    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
                    [self performSelector:@selector(nsrIdle) withObject:nil afterDelay:0];
                }];
            }
        }];
    }
}

- (void)registerUser:(NSRUser*) user {
    [self setUser:user];
    [self authorize:^(BOOL authorized) {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [locationManager startMonitoringSignificantLocationChanges];
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        [self performSelector:@selector(nsrIdle) withObject:nil afterDelay:0];
    }];
}
//
//- (void)setupWithURL:(NSURL*)settingsURL {
//    NSDictionary* settings = [[NSDictionary alloc] initWithContentsOfURL:settingsURL];
//    [self setupWithDictionary:settings];
//}

- (void)clearUser {
    
}

- (NSString*)version {
    return @"1.0";
}

- (NSString*)os {
    return @"iOS";
}

- (void)stayInBackground {
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&sessionError];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[[NSRUtils frameworkBundle] URLForResource:@"silence" withExtension:@"mp3"]];
    NSLog(@"%@", [NSRUtils frameworkBundle]);
    [self setPlayer:[[AVPlayer alloc] initWithPlayerItem:item]];
    [[self player] setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [[self player] play];
}

-(void)speak:(NSString *)message {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    for (AVSpeechSynthesisVoice *voice in [AVSpeechSynthesisVoice speechVoices]) {
        if ([[voice language] containsString:@"en"]) {
            AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:message];
            utterance.voice = voice;
            [synthesizer speakUtterance:utterance];
            break;
        }
    }
}

@end
