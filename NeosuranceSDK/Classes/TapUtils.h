#import <Foundation/Foundation.h>

@interface TapUtils : NSObject

+ (NSString *)uuid;
+ (NSString *)deviceModel;
+ (NSString *)osVersion;
+ (void)registerFont:(NSURL *)URL;
+ (void)play:(NSURL*)url;
+ (NSString *)sha256:(NSString *)string;

@end

@interface NSString (utils)

- (NSString *)urlencode;
- (BOOL)isEmpty;

@end

