#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface TapData : NSObject {
    AFURLSessionManager *manager;
    NSMutableArray* files;
}

+(id)sharedInstance;
-(void)downloadFile:(NSURL*)url extension:(NSString*)extension info:(NSDictionary*)info;
-(NSArray*)files;
-(void)deleteFile:(NSURL*)url;
+(NSURL*)fileUrl:(NSDictionary*)info extension:(NSString*)extension;
+(NSURL*)dirUrl;


@end
