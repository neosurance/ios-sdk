#import "TapData.h"
#import "TapUtils.h"

@implementation TapData

#define kTapDataFiles @"TapDataFiles"

+ (id)sharedInstance {
    static TapData *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSMutableArray* pendingFiles = [[NSMutableArray alloc] init];
        NSArray* storedArray = [[NSUserDefaults standardUserDefaults] objectForKey:kTapDataFiles];
        files = [[NSMutableArray alloc] initWithArray:storedArray];
        for(NSDictionary* aFile in files) {
            NSString* state = [NSString stringWithFormat:@"%@", aFile[@"state"]];
            if([state compare:@"downloading"] == NSOrderedSame || aFile[@"percentage"] != nil || aFile[@"extension"] == nil) {
                [pendingFiles addObject:aFile];
            }
        }
        [files removeObjectsInArray:pendingFiles];
    }
    return self;
}

-(void)downloadFile:(NSURL*)url extension:(NSString*)extension info:(NSDictionary*)info {
    NSString* urlAsString = [NSString stringWithFormat:@"%@", url];
    NSMutableDictionary* theFile;
    BOOL dataExists = NO;
    @synchronized(self) {
        theFile = [self pop:urlAsString];
        if(theFile == nil) {
            theFile = [[NSMutableDictionary alloc] init];
            [theFile setObject:urlAsString forKey:@"url"];
            [theFile setObject:extension forKey:@"extension"];
            [theFile setObject:[TapUtils sha256:urlAsString] forKey:@"token"];
            if(info != nil) {
                [theFile setObject:info forKey:@"info"];
            }
        } else {
            dataExists = YES;
        }
        [theFile setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"lastAccessTime"];
        [self push:urlAsString file:theFile];
    }
    NSURL *fileURL = [TapData fileUrl:theFile extension:extension];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]];
    if(dataExists && fileExists) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TapDataFileReady" object:theFile];
    } else {
        if(!dataExists) {
            @synchronized(self) {
                theFile = [self pop:urlAsString];
                [theFile setObject:@"downloading" forKey:@"state"];
                [self push:urlAsString file:theFile];
            }
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSURLSessionDownloadTask* downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *progress) {
                @synchronized(self) {
                    NSMutableDictionary* theFile = [self pop:urlAsString];
                    [theFile setObject:[NSNumber numberWithFloat:(float)[progress completedUnitCount]/[progress totalUnitCount]] forKey:@"percentage"];
                    [self push:urlAsString file:theFile];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"TapDataFileChanged" object:theFile];
                }
            } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return fileURL;
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                @synchronized(self) {
                    NSMutableDictionary* theFile = [self pop:urlAsString];
                    if(!error) {
                        [theFile removeObjectForKey:@"percentage"];
                        [theFile setObject:@"ready" forKey:@"state"];
                        [self push:urlAsString file:theFile];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"TapDataFileReady" object:theFile];
                    } else {
                        [theFile setObject:error forKey:@"error"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"TapDataFileError" object:theFile];
                    }
                }
            }];
            [downloadTask resume];
        }
    }
}

-(NSMutableDictionary*)pop:(NSString*)urlAsString {
    @synchronized(self) {
        NSDictionary* theFile = nil;
        for(NSDictionary* aFile in files) {
            NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", aFile[@"url"]];
            if([urlAsString compare:fileUrlAsString] == NSOrderedSame) {
                theFile = aFile;
                break;
            }
        }
        if(theFile != nil) {
            [files removeObject:theFile];
            [[NSUserDefaults standardUserDefaults] setObject:files forKey:kTapDataFiles];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return [[NSMutableDictionary alloc] initWithDictionary:theFile];
        }
        return nil;
    }
}

-(void)push:(NSString*)urlAsString file:(NSDictionary*)theFile {
    @synchronized(self) {
        [files insertObject:theFile atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:files forKey:kTapDataFiles];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(NSURL*)fileUrl:(NSDictionary*)info extension:(NSString*)extension {
    NSURL *documentsDirectoryURL = [TapData dirUrl];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", info[@"token"], extension]];
    return fileURL;
}

+(NSURL*)dirUrl {
    return [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];;
}

-(NSArray*)files {
    return [[NSArray alloc] initWithArray:files];
}

-(void)deleteFile:(NSURL*)url {
    NSDictionary* dictionary = [self pop:[NSString stringWithFormat:@"%@", url]];
    if(dictionary != nil) {
        NSURL* fileUrl = [TapData fileUrl:dictionary extension:dictionary[@"extension"]];
        NSLog(@"%@", fileUrl);
        [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
        [self performSelector:@selector(emitDataChanged:) withObject:dictionary afterDelay:0];
    }
}

-(void)emitDataChanged:(NSDictionary*)dictionary {
    //[TapUtils play:[[NSBundle mainBundle] URLForResource:@"Error2" withExtension:@"m4a"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TapDataFileDeleted" object:dictionary];
}

@end
