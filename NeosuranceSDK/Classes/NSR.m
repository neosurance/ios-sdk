#import "NSR.h"
#import "NSRUtils.h"
#import "NSRRequest.h"
#import "NSRDefaultSecurityDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <TapFramework/TapUtils.h>
#import <TapFramework/TapData.h>
#import <TapFramework/TapWebController.h>

@implementation NSR

@synthesize settings, user, authSettings, context, player, motionActivityManager, locationManager, stillLocationManager, demoSettings, body, securityDelegate;

+ (id)sharedInstance {
    static NSR *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
         [sharedInstance setSecurityDelegate:[[NSRDefaultSecurityDelegate alloc] init]];
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
        self.stillLocationManager = [[CLLocationManager alloc] init];
        stillLocationManager.delegate = self;
        [stillLocationManager requestAlwaysAuthorization];
        stillPositionSent = NO;
        self.motionActivityManager = [[CMMotionActivityManager alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPush:) name:@"NSRPush" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLanding:) name:@"NSRLanding" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushIncoming:) name:@"NSRPushIncoming" object:nil];
    }
    return self;
}

-(void)takePicture {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.allowsEditing = NO;
    [navigationController presentViewController:controller animated:YES completion:^{

    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    
    CGSize newSize = CGSizeMake(512.0f*image.size.width/image.size.height,512.0f);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(newImage, 1.0);
    NSString *base64String = [imageData base64EncodedStringWithOptions:kNilOptions];
    NSString *encodedString2 = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL,  (CFStringRef)base64String,    NULL,   CFSTR("!*'();:@&=+$,/?%#[]\" "),   kCFStringEncodingUTF8));
    NSString* js = [NSString stringWithFormat:@"%@('data:image/png;base64,%@')",body[@"callBack"], encodedString2];
    NSLog(@"%@", js);
    [bodyWebView evaluateJavaScript:js];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)onMessage:(TapWebView*)webView body:(NSDictionary*)_body {
    self.body = _body;
    bodyWebView = webView;
    NSLog(@"%@", body);
    if(body[@"event"] != nil && body[@"payload"] != nil) {
        [self sendEvent:body[@"event"] payload:body[@"payload"]];
    }
    if([@"close" compare:body[@"what"]] == NSOrderedSame) {
        [navigationController popViewControllerAnimated:YES];
    }
    if([@"photo" compare:body[@"what"]] == NSOrderedSame) {
        [self takePicture];
    }
    if([@"showapp" compare:body[@"what"]] == NSOrderedSame) {
        [self showAppWithParams:body[@"params"]];
    }
    if([@"code" compare:body[@"what"]] == NSOrderedSame) {
        NSString* js = [NSString stringWithFormat:@"%@('%@')",body[@"callBack"], demoSettings[@"code"]];
        NSLog(@"%@", js);
        [webView evaluateJavaScript:js];
    }
    
    
    
    if([@"user" compare:body[@"what"]] == NSOrderedSame) {
        NSString* js = [NSString stringWithFormat:@"%@('%@')",body[@"callBack"], [self.user json]];
        NSLog(@"%@", js);
        [webView evaluateJavaScript:js];
    }
    if([@"action" compare:body[@"what"]] == NSOrderedSame) {
        [self sendAction:body[@"action"] policyCode:body[@"code"] details:body[@"details"]];
    }
    
    
    
    if([@"refresh" isEqualToString:body[@"what"]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetAll" object:nil];
    }
    if([@"location" isEqualToString:body[@"what"]]) {
        NSString* js = [NSString stringWithFormat:@"%@({latitude:%f,longitude:%f})",body[@"callBack"], currentLatitude, currentLongitude];
        NSLog(@"%@", js);
        [webView evaluateJavaScript:js];
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
            NSString* js = [NSString stringWithFormat:@"%@(%@)",_body[@"callBack"], json];
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

- (void)sendAction:(NSString*)name policyCode:(NSString*)code details:(NSString*)details {
    @try {
        NSR* nsr = [NSR sharedInstance];
        [nsr token:^(NSString* token) {
            if(token != nil) {
                NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
                [payload setObject:name forKey:@"action"];
                [payload setObject:code forKey:@"code"];
                [payload setObject:details forKey:@"details"];
                [payload setObject:[[NSTimeZone localTimeZone] name] forKey:@"timezone"];
                [payload setObject:[NSNumber numberWithLong:([[NSDate date] timeIntervalSince1970]*1000)] forKey:@"action_time"];
                if(nsr.securityDelegate != nil) {
                    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
                    [headers setObject:token forKey:@"ns_token"];
                    [headers setObject:nsr.settings[@"ns_lang"] forKey:@"ns_lang"];
                    [nsr.securityDelegate secureRequest:@"trace" payload:payload headers:headers completionHandler:^(NSDictionary *responseObject, NSError *error) {
                        if (error) {
                            NSLog(@"NSR Error: %@", error);
                        } else {
                            NSLog(@"NSR Action Response: %@", responseObject);
                        }
                    }];
                }
            }
        }];
    }
    @catch (NSException * e) {
    }
}

-(void)showApp {
    [self showAppWithParams:nil];
}

- (void)showAppWithParams:(NSDictionary*)params {
    NSDictionary* settings = [[NSR sharedInstance] authSettings];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSString* url = settings[@"app_url"];
    if(params != nil) {
        for (NSString* key in params) {
            NSString* value = [NSString stringWithFormat:@"%@", [params objectForKey:key]];
            value = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            if ([url containsString:@"?"]) {
                url = [url stringByAppendingString:@"&"];
            } else {
                url = [url stringByAppendingString:@"?"];
            }
            url = [url stringByAppendingString:key];
            url = [url stringByAppendingString:@"="];
            url = [url stringByAppendingString:value];
        }
    }
    [self showWebPage:url];
}

-(void)enablePushNotifications {
     //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if(granted) {
                                  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                                  center.delegate = self;
                                  //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:43];
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
    [self showWebPage:dictionary[@"url"]];
}

-(void)showPush:(NSNotification*)notification {
    [TapUtils play:[[NSRUtils frameworkBundle] URLForResource:@"push" withExtension:@"wav"]];
    NSDictionary* push = notification.object;
    [self sendLocalNotificationWithTitle:push[@"title"] body:push[@"body"] payload:push];
}

-(void)showLanding:(NSNotification*)notification {
    NSDictionary* push = notification.object;
    [self showWebPage:push[@"url"]];
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
        [self showWebPage:userInfo[@"url"]];
       return YES;
    }
    return NO;
}

-(void)showWebPage:(NSString*)url {
    NSLog(@"--- %@", url);
    TapWebController* controller = [[TapWebController alloc] init];
    controller.delegate = self;
    controller.isFullscreen = YES;
    controller.bodyClassCheck = @"NSR";
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSURL URLWithString:url] forKey:@"url"];
    controller.info = dict;
    [navigationController pushViewController:controller animated:YES];
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
    currentLatitude = newLocation.coordinate.latitude;
    currentLongitude = newLocation.coordinate.longitude;
    [locationManager startMonitoringSignificantLocationChanges];
    int enabled = 1;
    enabled = [[NSString stringWithFormat:@"%@", self.authSettings[@"conf"][@"position"][@"enabled"]] intValue];
    if(enabled == 1) {
        NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
        [payload setObject:[NSNumber numberWithFloat:newLocation.coordinate.latitude] forKey:@"latitude"];
        [payload setObject:[NSNumber numberWithFloat:newLocation.coordinate.longitude] forKey:@"longitude"];
        [payload setObject:[NSNumber numberWithFloat:oldLocation.coordinate.latitude] forKey:@"old-latitude"];
        [payload setObject:[NSNumber numberWithFloat:oldLocation.coordinate.longitude] forKey:@"old-longitude"];
        NSRRequest* request = [[NSRRequest alloc] init];
         if(manager == stillLocationManager) {
            [stillLocationManager stopUpdatingLocation];
            stillPositionSent = YES;
            [payload setObject:[NSNumber numberWithInt:1] forKey:@"still"];
        } else {
            stillPositionSent = NO;
        }
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
                    if(!stillPositionSent && activity.stationary) {
                        [stillLocationManager startUpdatingLocation];
                     }

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
            NSLog(@"%@", [[NSR sharedInstance] securityDelegate]);
            NSLog(@"%@", self.securityDelegate);

             if(self.securityDelegate != nil) {
                 [self.securityDelegate secureRequest:@"authorize" payload:payload headers:nil completionHandler:^(NSDictionary *responseObject, NSError *error) {
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
            }
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
        NSLog(@"NSR Error: %@", url);
        [TapData requestWithURL:url completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"NSR Error: %@", responseObject);
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
            }
        }];
    } else {
        NSRUser* user = [[NSRUser alloc] init];
        user.email = demoSettings[@"email"];
        user.code = demoSettings[@"code"];
        user.firstname = demoSettings[@"firstname"];
        user.lastname = demoSettings[@"lastname"];
        [self setUser:user];
        [self authorize:^(BOOL authorized) {
            [[AFNetworkReachabilityManager sharedManager] startMonitoring];
            [locationManager startMonitoringSignificantLocationChanges];
            [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
            [self performSelector:@selector(nsrIdle) withObject:nil afterDelay:0];
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

- (void)forgetUser {
    [self clearUser];
}

- (void)clearUser {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authSettings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setUser:nil];
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
