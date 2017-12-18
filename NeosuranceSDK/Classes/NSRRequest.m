#import "NSRRequest.h"
#import "NSR.h"
#import "NSRUtils.h"
#import "TapUtils.h"
#import "TapData.h"

@implementation NSRRequest

@synthesize event;

-(void)send {
    @try {
        NSR* nsr = [NSR sharedInstance];
        [nsr token:^(NSString* token) {
            if(token != nil) {
                NSRUser* user = [nsr user];
                NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
                NSMutableDictionary* userPayload = [[NSMutableDictionary alloc] init];
                [userPayload setObject:user.firstname forKey:@"firstname"];
                [userPayload setObject:user.lastname forKey:@"lastname"];
                [userPayload setObject:user.email forKey:@"email"];
                [userPayload setObject:user.code forKey:@"code"];
                NSMutableDictionary* devicePayLoad = [[NSMutableDictionary alloc] init];
                [devicePayLoad setObject:[TapUtils uuid:@"nsr" account:@"sdk"] forKey:@"uid"];
                [devicePayLoad setObject:[nsr os] forKey:@"os"];
                [devicePayLoad setObject:[TapUtils osVersion] forKey:@"version"];
                [devicePayLoad setObject:[TapUtils deviceModel] forKey:@"model"];
                [payload setObject:event forKey:@"event"];
                [payload setObject:userPayload forKey:@"user"];
                [payload setObject:devicePayLoad forKey:@"device"];
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
                NSString* json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                json = [json urlencode];
                token = [token urlencode];
                NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@event?payload=%@&ns_token=%@&ns_lang=%@", nsr.settings[@"base_url"], json, token, nsr.settings[@"ns_lang"]]];
                [TapData requestWithURL:url completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                    if (error) {
                        NSLog(@"NSR Error: %@", error);
                    } else {
                        NSArray* pushes = responseObject[@"pushes"];
                        for(NSDictionary* push in pushes) {
                            NSLog(@"%@", push);
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"NSRPush" object:push userInfo:nil];
                        }
                    }
                }];
                //                if(event[@"payload"][@"type"] == nil) {
                //                    [[NSR sharedInstance] speak:[NSString stringWithFormat:@"%@", event[@"event"]]];
                //               } else {
                //                    [[NSR sharedInstance] speak:[NSString stringWithFormat:@"%@ of type %@", event[@"event"], event[@"payload"][@"type"]]];
                //                }
            }
        }];
    }
    @catch (NSException * e) {
    }
}

@end
