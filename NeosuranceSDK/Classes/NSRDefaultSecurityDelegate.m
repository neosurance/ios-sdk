#import "NSRDefaultSecurityDelegate.h"
#import "TapFramework/TapData.h"
#import "TapFramework/TapUtils.h"

@implementation NSRDefaultSecurityDelegate

-(void)secureRequest:(NSString*)endpoint payload:(NSDictionary*)payload headers:(NSDictionary*)headers completionHandler:(void (^)(NSDictionary* responseObject, NSError *error))completionHandler {
    NSString* json = nil;
    NSURL *url = nil;
    NSString* urlAsString = [[NSR sharedInstance] settings][@"base_url"];
    if(payload != nil) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", json);
        urlAsString = [urlAsString stringByAppendingFormat:@"%@?payload=%@", endpoint, [json urlencode]];
    } else {
        urlAsString = [urlAsString stringByAppendingFormat:@"%@", endpoint];
    }
    if(headers != nil) {
        int i=0;
        for(NSString* key in [headers keyEnumerator]) {
            NSString* value = [headers objectForKey:key];
            if(i > 0 || payload != nil) {
                urlAsString = [urlAsString stringByAppendingFormat:@"&%@=%@", key, [value urlencode]];
            } else {
                urlAsString = [urlAsString stringByAppendingFormat:@"?%@=%@", key, [value urlencode]];
            }
        }
    }
    NSLog(@"%@", urlAsString);
    url =  [NSURL URLWithString:urlAsString];
    [TapData requestWithURL:url completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        completionHandler(responseObject, error);
    }];
}

@end
