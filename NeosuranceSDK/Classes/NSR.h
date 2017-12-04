#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NSRUser.h"
#import "TapWeb.h"
#import <MapKit/MapKit.h>
#import <CoreMotion/CoreMotion.h>
#import <UserNotifications/UserNotifications.h>

@interface NSR : NSObject<CLLocationManagerDelegate,TapWebDelegate> {
    NSDictionary* settings;
    NSDictionary* authSettings;
    NSDictionary* demoSettings;
    NSRUser* user;
    NSMutableDictionary* context;
    AVPlayer *player;
    CLLocationManager *locationManager;
    CMMotionActivityManager *motionActivityManager;
    UINavigationController* navigationController;
}

@property(nonatomic, copy) NSMutableDictionary* context;
@property(nonatomic, copy) NSDictionary* settings;
@property(nonatomic, copy) NSDictionary* authSettings;
@property(nonatomic, copy) NSDictionary* demoSettings;
@property(nonatomic, copy) NSRUser* user;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@property (nonatomic, strong) CLLocationManager *locationManager;

+ (id)sharedInstance;
- (void)setupWithDictionary:(NSDictionary*)settings navigationController:(UINavigationController*)navigationController;
- (void)setupWithURL:(NSURL*)settingsURL;
- (void)clearUser;
- (NSString*)version;
- (NSString*)os;
- (void)token:(void (^)(NSString* token))completionHandler;
- (void)authorize:(void (^)(BOOL authorized))completionHandler;
- (void)stayInBackground;
- (void)speak:(NSString *)message;
- (void)registerUser:(NSRUser*) user;
- (BOOL)forwardNotification:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler;
- (void)showApp;

@end
