#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TapUtils : NSObject

+ (void)clear:(UIView*)view;
+ (NSString *)uuid:(NSString*)appName account:(NSString*)account;
+ (NSString *)deviceModel;
+ (NSString *)osVersion;
+ (void)registerFont:(NSURL *)URL;
+ (void)play:(NSURL*)url;
+ (NSString *)sha256:(NSString *)string;
+ (NSArray *)randomArray:(NSArray *)array numberOfItems:(int)size;

@end

@interface NSString (utils)

- (NSString *)urlencode;
- (BOOL)isEmpty;

@end

@interface NSMutableArray (utils)

- (void)reverse;

@end
