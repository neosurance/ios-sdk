#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "Tap.h"

@interface TapData : NSObject {
    NSArray* files;
    NSArray* databases;
    NSMutableArray* requests;
}

@property (nonatomic, copy) NSArray* databases;
@property (nonatomic, copy) NSArray* files;

+(id)sharedInstance;

-(NSDictionary*)data:(NSString*)title;
-(NSString*)dataAsJsonString:(NSString*)title;
-(NSString*)filesAsJsonString;

-(void)registerDatabase:(NSURL*)url title:(NSString*)title  info:(NSDictionary*)info;
-(void)removeDatabase:(NSString*)title;
-(void)downloadFile:(NSURL*)url extension:(NSString*)extension type:(NSString*)type title:(NSString*)title info:(NSDictionary*)info;
-(NSURL*)localFileUrl:(NSURL*)url;
-(void)deleteFile:(NSURL*)url;
+(NSURL*)dirUrl;
+(void)requestWithURL:(NSURL*)url completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;
+(void)downloadImage:(NSURL*)url completionHandler:(void (^)(NSURL *filePath))completionHandler;
+(void)downloadPdf:(NSURL*)url completionHandler:(void (^)(NSURL *filePath))completionHandler;
+(void)downloadResource:(NSURL*)url extension:(NSString*)extension completionHandler:(void (^)(NSURL *filePath))completionHandler;

@end
