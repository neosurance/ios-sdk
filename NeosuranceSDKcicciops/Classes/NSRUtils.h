#import <Foundation/Foundation.h>

@interface NSRUtils : NSObject

+(int)tokenRemainingSeconds:(NSDictionary*)authSettings;
+(NSDictionary *)makeEvent:(NSString*)name payload:(NSDictionary*)payload;
+ (NSBundle*)frameworkBundle;

@end
