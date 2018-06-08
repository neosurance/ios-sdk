#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NSRUser.h"
#import <MapKit/MapKit.h>
#import <CoreMotion/CoreMotion.h>
#import <UserNotifications/UserNotifications.h>
#import <TapFramework/TapWebView.h>

@protocol NSRSecurityDelegate <NSObject>
-(void)secureRequest:(NSString* _Nullable)endpoint payload:(NSDictionary* _Nullable)payload headers:(NSDictionary* _Nullable)headers completionHandler:(void (^)(NSDictionary* responseObject, NSError *error))completionHandler;
@end

@interface NSR : NSObject<CLLocationManagerDelegate,TapWebViewDelegate, UNUserNotificationCenterDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    NSDictionary* settings;
    NSDictionary* authSettings;
    NSDictionary* demoSettings;
    NSDictionary* body;
    TapWebView* bodyWebView;
    NSRUser* user;
    NSMutableDictionary* context;
    AVPlayer *player;
    CLLocationManager *locationManager;
    CLLocationManager *significantLocationManager;
    CLLocationManager *stillLocationManager;
    CMMotionActivityManager *motionActivityManager;
    BOOL stillPositionSent;
    BOOL setupped;
    float currentLatitude;
    float currentLongitude;
    id <NSRSecurityDelegate> securityDelegate;
}

@property (nonatomic, strong) id <NSRSecurityDelegate> securityDelegate;
@property(nonatomic, copy) NSMutableDictionary* context;
@property(nonatomic, copy) NSDictionary* body;
@property(nonatomic, copy) NSDictionary* settings;
@property(nonatomic, copy) NSDictionary* authSettings;
@property(nonatomic, copy) NSDictionary* demoSettings;
@property(nonatomic, copy) NSRUser* user;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocationManager *significantLocationManager;
@property (nonatomic, strong) CLLocationManager *stillLocationManager;

+ (id)sharedInstance;
- (void)setupWithDictionary:(NSDictionary*)settings;
- (void)setupWithURL:(NSURL*)settingsURL;
- (void)clearUser;
- (NSString*)version;
- (NSString*)os;
- (void)token:(void (^)(NSString* token))completionHandler;
- (void)authorize:(void (^)(BOOL authorized))completionHandler;
- (void)stayInBackground;
- (void)speak:(NSString *)message;
- (void)registerUser:(NSRUser*) user;
- (void)forgetUser;
- (BOOL)forwardNotification:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler;
- (void)showApp;
- (void)showAppWithParams:(NSDictionary*)params;
- (void)sendEvent:(NSString*)name payload:(NSDictionary*)payload;
- (void)sendAction:(NSString*)name policyCode:(NSString*)code details:(NSString*)details;
- (void)enablePushNotifications;
- (void)showWebPage:(NSString*)ur;
- (void)idle;
+ (NSString*)uuid;

@end
