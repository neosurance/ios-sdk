#import <Foundation/Foundation.h>

@interface TapRequest : NSObject

+(void)requestWithURL:(NSURL*)url completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

@end
