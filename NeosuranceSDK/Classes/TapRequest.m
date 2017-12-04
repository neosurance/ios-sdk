#import "TapRequest.h"
#import <AFNetworking/AFNetworking.h>

@implementation TapRequest

+(void)requestWithURL:(NSURL*)url completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
}

@end
