#import "NSRRequest.h"
#import "NSR.h"
#import "NSRUtils.h"
#import "TapUtils.h"
#import "TapData.h"

@implementation NSRRequest

@synthesize event;

-(void)send {
    @try {
        NSLog(@"NSRRequest send");
        NSR* nsr = [NSR sharedInstance];
        [nsr token:^(NSString* token) {
            if(token != nil) {
                NSRUser* user = [nsr user];
                NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
                NSMutableDictionary* devicePayLoad = [[NSMutableDictionary alloc] init];
                [devicePayLoad setObject:[NSR uuid] forKey:@"uid"];
                [devicePayLoad setObject:[nsr os] forKey:@"os"];
                [devicePayLoad setObject:[TapUtils osVersion] forKey:@"version"];
                [devicePayLoad setObject:[TapUtils deviceModel] forKey:@"model"];
                [payload setObject:event forKey:@"event"];
                [payload setObject:user.dictionary forKey:@"user"];
                [payload setObject:devicePayLoad forKey:@"device"];
                if(nsr.securityDelegate != nil) {
                    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
                    [headers setObject:token forKey:@"ns_token"];
                    [headers setObject:nsr.settings[@"ns_lang"] forKey:@"ns_lang"];
                    [nsr.securityDelegate secureRequest:@"event" payload:payload headers:headers completionHandler:^(NSDictionary *responseObject, NSError *error) {
                        if (error) {
                            NSLog(@"NSRRequest Error: %@", error);
                        } else {
                            BOOL skipPush = NO;
                            if(responseObject[@"skipPush"] != nil && [responseObject[@"skipPush"] intValue] == 1) {
                                skipPush = YES;
                            }
                            NSArray* pushes = responseObject[@"pushes"];
                            if(!skipPush) {
                                for(NSDictionary* push in pushes) {
                                    NSLog(@"NSRRequest: %@", push);
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NSRPush" object:push userInfo:nil];
                                }
                            } else {
                                for(NSDictionary* push in pushes) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NSRLanding" object:push userInfo:nil];
                                    break;
                                }
                            }
                        }
                    }];
                 }
              }
        }];
    }
    @catch (NSException * e) {
    }
}

@end
