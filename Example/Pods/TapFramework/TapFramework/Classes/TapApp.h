#import <Foundation/Foundation.h>

@class TapApp;

@protocol TapAppDelegate <NSObject>
@optional
- (void)onUiReady:(TapApp*)app;
- (void)onDataReady:(TapApp*)app;
- (void)onLoginError:(TapApp*)app;
@end

@interface TapApp : NSObject {
    NSString* appKey;
    NSString* appName;
    NSDictionary* info;
    __weak id <TapAppDelegate> delegate;
}

@property (nonatomic, weak) id <TapAppDelegate> delegate;
@property (nonatomic, copy) NSString* appKey;
@property (nonatomic, copy) NSString* appName;
@property (nonatomic, copy) NSDictionary* info;

-(NSString*)version;
-(int)build;
-(NSString*)versionNumber;

-(BOOL)authenticated;
-(NSString*)username;
-(NSString*)uuid;
-(void)signIn:(NSString*)username token:(NSString*)token;
-(void)signOut;


@end
