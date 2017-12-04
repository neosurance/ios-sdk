#import "NSRUtils.h"

@implementation NSRUtils

+(int)tokenRemainingSeconds:(NSDictionary*)authSettings {
    if(authSettings[@"auth"] == nil) {
        return -1;
    }
    long expire = [authSettings[@"auth"][@"expire"] longValue]/1000;
    long now = [[NSDate date] timeIntervalSince1970];
    return (int)(expire-now);
}

+(NSDictionary *)makeEvent:(NSString*)name payload:(NSDictionary*)payload {
    NSMutableDictionary* event = [[NSMutableDictionary alloc] init];
    [event setObject:name forKey:@"event"];
    [event setObject:[[NSTimeZone localTimeZone] name] forKey:@"timezone"];
    [event setObject:[NSNumber numberWithLong:([[NSDate date] timeIntervalSince1970]*1000)] forKey:@"event_time"];
    [event setObject:payload forKey:@"payload"];
    return event;
}

+ (NSBundle*)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    NSString* mainBundlePath = [[NSBundle bundleForClass:[NSRUtils class]] resourcePath];
    NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"NeosuranceSDK.bundle"];
    frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    return frameworkBundle;
}
@end
