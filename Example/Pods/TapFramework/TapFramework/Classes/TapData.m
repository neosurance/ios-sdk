#import "TapData.h"
#import "TapUtils.h"

@implementation TapData

@synthesize databases, files;

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
        requests = [[NSMutableArray alloc] init];
        self.files = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:TapDataFilesStoreKey]];
        NSMutableArray* newFiles = [[NSMutableArray alloc] init];
        for(NSDictionary* file in files) {
            NSString* state = [NSString stringWithFormat:@"%@", file[TapDataStateKey]];
            if([state compare:TapDataStateDownloading] != NSOrderedSame && file[TapDataPercentageKey] == nil && file[TapDataExtensionKey] != nil) {
                [newFiles addObject:file];
            }
        }
        NSMutableArray* newDatabases = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:TapDataDatabasesStoreKey]];
        self.files = newFiles;
        self.databases = newDatabases;
        [self performSelector:@selector(synchDatabases) withObject:nil afterDelay:0];
        [[NSUserDefaults standardUserDefaults] setObject:newFiles forKey:TapDataFilesStoreKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}

-(AFURLSessionManager *)sessionManager {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    return manager;
}

+(void)requestWithURL:(NSURL*)url completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [[[TapData sharedInstance] sessionManager] dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
}

+(void)downloadImage:(NSURL*)url completionHandler:(void (^)(NSURL *filePath))completionHandler {
    [TapData downloadResource:url extension:@"jpg" completionHandler:completionHandler];
}

+(void)downloadPdf:(NSURL*)url completionHandler:(void (^)(NSURL *filePath))completionHandler {
    [TapData downloadResource:url extension:@"pdf" completionHandler:completionHandler];
}

+(void)downloadResource:(NSURL*)url extension:(NSString*)extension completionHandler:(void (^)(NSURL *filePath))completionHandler {
    NSURL *documentsDirectoryURL = [TapData dirUrl];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [TapUtils sha256:[NSString stringWithFormat:@"%@", url]], extension]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]];
    if(fileExists) {
        completionHandler(fileURL);
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", url]]];
        NSURLSessionDownloadTask* downloadTask = [[[TapData sharedInstance] sessionManager] downloadTaskWithRequest:request progress:^(NSProgress *progress) {
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return fileURL;
        } completionHandler:^(NSURLResponse *response, NSURL *fileURL, NSError *error) {
            completionHandler(fileURL);
        }];
        [downloadTask resume];
    }
}

-(void)synchDatabases {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //NSLog(@"synch databases...");
    //for(NSDictionary* database in databases) {
        //NSLog(@"    database '%@' '%@' '%@'", database[TapDataTitleKey], database[TapDataUrlKey], database[TapDataStateKey]);
    //}
    for(NSDictionary* file in files) {
        if([[NSString stringWithFormat:@"%@", file[TapDataUrlKey]] containsString:@"md5="]) {
            [self deleteFile:[NSURL URLWithString:[NSString stringWithFormat:@"%@", file[TapDataUrlKey]]]];
        } else {
            //NSLog(@"        file '%@' '%@'", file[TapDataTitleKey], file[TapDataUrlKey]);
        }
    }
    //NSLog(@"synch databases.");
    NSMutableArray* newDatabases = [[NSMutableArray alloc] init];
    for(NSDictionary* database in databases) {
        NSMutableDictionary* newDatabase = [[NSMutableDictionary alloc] initWithDictionary:database];
        NSURL* localUrl = [self localFileUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@", newDatabase[TapDataUrlKey]]]];
        if(localUrl == nil) {
            [newDatabase setObject:TapDataStateNoData forKey:TapDataStateKey];
        }
        if([newDatabase[TapDataStateKey] isEqualToString:TapDataStateNoData]) {
            [newDatabase setObject:TapDataStateDownloading forKey:TapDataStateKey];
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", database[TapDataUrlKey]]];
            [self downloadFile:url extension:TapDataJsonExtension type:TapDataDatabaseType title:newDatabase[TapDataTitleKey] info:nil];
        }
        if([newDatabase[TapDataStateKey] isEqualToString:TapDataStateReady]) {
            NSData *jsonData = [NSData dataWithContentsOfURL:localUrl];
            if(jsonData != nil) {
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                NSString* md5 = json[@"md5"];
                //NSLog(@"%@, md5 = %@", newDatabase[TapDataTitleKey], md5);
                if(md5 != nil) {
                    NSString* urlAsString = [NSString stringWithFormat:@"%@&md5=%@", newDatabase[TapDataUrlKey], md5];
                    //NSLog(@"%@, url = %@", newDatabase[TapDataTitleKey], urlAsString);
                    [self downloadFile:[NSURL URLWithString:urlAsString] extension:TapDataJsonExtension type:TapDataDatabaseType title:newDatabase[TapDataTitleKey] info:nil];
                }
            }
        }
        [newDatabases addObject:newDatabase];
    }
    self.databases = newDatabases;
    [[NSUserDefaults standardUserDefaults] setObject:newDatabases forKey:TapDataDatabasesStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSelector:@selector(synchDatabases) withObject:nil afterDelay:30];
}

-(void)registerDatabase:(NSURL*)url title:(NSString*)title info:(NSDictionary*)info {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if(![self existsDatabase:url]) {
        NSMutableArray* newDatabases = [[NSMutableArray alloc] init];
        for(NSDictionary* database in databases) {
            NSMutableDictionary* newDatabase = [[NSMutableDictionary alloc] initWithDictionary:database];
            [newDatabases addObject:newDatabase];
        }
        NSString* urlAsString = [NSString stringWithFormat:@"%@", url];
        NSMutableDictionary* database = [[NSMutableDictionary alloc] init];
        [database setObject:urlAsString forKey:TapDataUrlKey];
        [database setObject:title forKey:TapDataTitleKey];
        [database setObject:TapDataStateNoData forKey:TapDataStateKey];
        [database setObject:[TapUtils sha256:urlAsString] forKey:TapDataTokenKey];
        if(info != nil) {
            [database setObject:info forKey:TapDataInfoKey];
        }
        [database setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:TapDataLastAccessTimeKey];
        [newDatabases addObject:database];
        self.databases = newDatabases;
        [[NSUserDefaults standardUserDefaults] setObject:newDatabases forKey:TapDataDatabasesStoreKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSString* urlAsString = [NSString stringWithFormat:@"%@", url];
        for(NSDictionary* database in databases) {
            NSString* databaseUrlAsString = [NSString stringWithFormat:@"%@", database[TapDataUrlKey]];
            if([urlAsString compare:databaseUrlAsString] == NSOrderedSame) {
                NSURL* localUrl = [self localFileUrl:url];
                if(localUrl != nil) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TapDataDatabaseReady object:database];
                }
            }
        }
    }
    [self synchDatabases];
}

-(void)removeDatabase:(NSString*)title {
    NSMutableArray* newDatabases = [[NSMutableArray alloc] init];
    for(NSDictionary* database in databases) {
        NSString* databaseTitle = [NSString stringWithFormat:@"%@", database[TapDataTitleKey]];
        if([title compare:databaseTitle] != NSOrderedSame) {
            NSMutableDictionary* newDatabase = [[NSMutableDictionary alloc] initWithDictionary:database];
            [newDatabases addObject:newDatabase];
        } else {
            [self deleteFile:[NSURL URLWithString:[NSString stringWithFormat:@"%@", database[@"url"]]]];
        }
    }
    self.databases = newDatabases;
    [[NSUserDefaults standardUserDefaults] setObject:newDatabases forKey:TapDataDatabasesStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)databaseReady:(NSDictionary*)info {
    NSString* urlAsString = [NSString stringWithFormat:@"%@", info[TapDataUrlKey]];
    NSMutableArray* newDatabases = [[NSMutableArray alloc] init];
    BOOL dataExists = NO;
    for(NSDictionary* database in databases) {
        NSMutableDictionary* newDatabase = [[NSMutableDictionary alloc] initWithDictionary:database];
        NSString* databaseUrlAsString = [NSString stringWithFormat:@"%@", database[TapDataUrlKey]];
        if([urlAsString compare:databaseUrlAsString] == NSOrderedSame) {
            [newDatabase setObject:TapDataStateReady forKey:TapDataStateKey];
            [newDatabase setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:TapDataLastAccessTimeKey];
            dataExists = YES;
        }
        [newDatabases addObject:newDatabase];
    }
    self.databases = newDatabases;
    [[NSUserDefaults standardUserDefaults] setObject:newDatabases forKey:TapDataDatabasesStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(dataExists) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TapDataDatabaseReady object:info];
    }
    if([urlAsString containsString:@"md5="]) {
        NSURL* url = [self localFileUrl:[NSURL URLWithString:urlAsString]];
        if(url != nil) {
            NSData *jsonData = [NSData dataWithContentsOfURL:url];
            NSError *error;
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            NSString* md5 = dict[@"md5"];
            if(md5 != nil && ![urlAsString containsString:md5]) {
                NSString* deprecatedDatabaseUrlAsString = [[urlAsString componentsSeparatedByString:@"&md5="] objectAtIndex:0];
                NSMutableArray* newDatabases = [[NSMutableArray alloc] init];
                for(NSDictionary* database in databases) {
                    NSMutableDictionary* newDatabase = [[NSMutableDictionary alloc] initWithDictionary:database];
                    NSString* databaseUrlAsString = [NSString stringWithFormat:@"%@", database[TapDataUrlKey]];
                    if([deprecatedDatabaseUrlAsString compare:databaseUrlAsString] == NSOrderedSame) {
                        [newDatabase setObject:TapDataStateReady forKey:TapDataStateKey];
                        [newDatabase setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:TapDataLastAccessTimeKey];
                        NSURL* localUrl = [self localFileUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@", database[TapDataUrlKey]]]];
                        [jsonData writeToFile:[localUrl path] atomically:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:TapDataDatabaseChanged object:newDatabase];
                    }
                    [newDatabases addObject:newDatabase];
                }
                self.databases = newDatabases;
                [[NSUserDefaults standardUserDefaults] setObject:newDatabases forKey:TapDataDatabasesStoreKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        [self deleteFile:[NSURL URLWithString:urlAsString]];
    }
}

-(void)databaseError:(NSDictionary*)info {
    [[NSNotificationCenter defaultCenter] postNotificationName:TapDataDatabaseError object:info];
}

-(BOOL)existsDatabase:(NSURL*)url {
    NSString* urlAsString = [NSString stringWithFormat:@"%@", url];
    for(NSDictionary* database in databases) {
        NSString* databaseUrlAsString = [NSString stringWithFormat:@"%@", database[TapDataUrlKey]];
        if([urlAsString compare:databaseUrlAsString] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

-(NSDictionary*)data:(NSString*)title {
    for(NSDictionary* database in databases) {
        NSString* databaseTitle = [NSString stringWithFormat:@"%@", database[TapDataTitleKey]];
        if([title compare:databaseTitle] == NSOrderedSame) {
            NSURL* url = [self localFileUrl:[NSURL URLWithString:database[TapDataUrlKey]]];
            if(url != nil) {
                NSData *jsonData = [NSData dataWithContentsOfURL:url];
                NSError *error;
                return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            }
        }
    }
    return nil;
}

-(NSString*)dataAsJsonString:(NSString*)title {
    for(NSDictionary* database in databases) {
        NSString* databaseTitle = [NSString stringWithFormat:@"%@", database[TapDataTitleKey]];
        if([title compare:databaseTitle] == NSOrderedSame) {
            NSURL* url = [self localFileUrl:[NSURL URLWithString:database[TapDataUrlKey]]];
            if(url != nil) {
                NSData *jsonData = [NSData dataWithContentsOfURL:url];
                return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
    }
    return nil;
}

-(NSString*)filesAsJsonString {
    NSError *error;
    NSMutableArray* array = [[NSMutableArray alloc] initWithArray:files];
    [array reverse];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(void)deleteFile:(NSURL*)url {
    NSMutableArray* leftRequests = [[NSMutableArray alloc] init];
    for(NSURLSessionDownloadTask* task in requests) {
        NSString* taskUrl = [NSString stringWithFormat:@"%@", [task originalRequest].URL];
        if([taskUrl isEqualToString:[NSString stringWithFormat:@"%@", url]]) {
            [task cancel];
        } else {
            [leftRequests addObject:task];
        }
    }
    requests = leftRequests;
    NSMutableArray* newFiles = [[NSMutableArray alloc] init];
    NSString* urlAsString = [NSString stringWithFormat:@"%@", url];
    for(NSDictionary* file in files) {
        NSMutableDictionary* newFile = [[NSMutableDictionary alloc] initWithDictionary:file];
        NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[TapDataUrlKey]];
        if([urlAsString isEqualToString:fileUrlAsString]) {
            NSURL* fileUrl = [self fileUrl:file];
            [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:TapDataFileDeleted object:file];
        } else {
            [newFiles addObject:newFile];
        }
    }
    self.files = newFiles;
    [[NSUserDefaults standardUserDefaults] setObject:newFiles forKey:TapDataFilesStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)downloadFile:(NSURL*)url extension:(NSString*)extension type:(NSString*)type title:(NSString*)title info:(NSDictionary*)info {
    NSMutableArray* newFiles = [[NSMutableArray alloc] init];
    NSString* urlAsString = [NSString stringWithFormat:@"%@", url];
    NSLog(@"%@", url);
    BOOL dataExists = NO;
    NSMutableDictionary* theFile;
    for(NSDictionary* file in files) {
        NSMutableDictionary* newFile = [[NSMutableDictionary alloc] initWithDictionary:file];
        NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[TapDataUrlKey]];
        if([urlAsString isEqualToString:fileUrlAsString]) {
            [newFile setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:TapDataLastAccessTimeKey];
            theFile = newFile;
            dataExists = YES;
        }
        [newFiles addObject:newFile];
    }
    if(!dataExists) {
        NSMutableDictionary* newFile = [[NSMutableDictionary alloc] init];
        [newFile setObject:urlAsString forKey:TapDataUrlKey];
        [newFile setObject:extension forKey:TapDataExtensionKey];
        [newFile setObject:type forKey:TapDataTypeKey];
        [newFile setObject:title forKey:TapDataTitleKey];
        [newFile setObject:[TapUtils sha256:urlAsString] forKey:TapDataTokenKey];
        if(info != nil) {
            [newFile setObject:info forKey:TapDataInfoKey];
        }
        [newFile setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:TapDataLastAccessTimeKey];
        [newFiles addObject:newFile];
        theFile = newFile;
    }
    NSURL *fileUrl = [self fileUrl:theFile];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]];
    if(dataExists && fileExists) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TapDataFileReady object:theFile];
    } else {
        if(!dataExists) {
            [theFile setObject:TapDataStateDownloading forKey:TapDataStateKey];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", url]]];
            NSURLSessionDownloadTask* downloadTask = [[self sessionManager] downloadTaskWithRequest:request progress:^(NSProgress *progress) {
                [theFile setObject:[NSNumber numberWithFloat:(float)[progress completedUnitCount]/[progress totalUnitCount]] forKey:TapDataPercentageKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:TapDataFileChanged object:theFile];
            } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return fileUrl;
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                NSMutableDictionary* theFile;
                NSMutableArray* newFiles = [[NSMutableArray alloc] init];
                NSString* urlAsString = [NSString stringWithFormat:@"%@", url];
                for(NSDictionary* file in files) {
                    NSMutableDictionary* newFile = [[NSMutableDictionary alloc] initWithDictionary:file];
                    NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[TapDataUrlKey]];
                    if([urlAsString isEqualToString:fileUrlAsString]) {
                        if(!error) {
                            [newFile removeObjectForKey:TapDataPercentageKey];
                            [newFile setObject:TapDataStateReady forKey:TapDataStateKey];
                            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[fileUrl path] error:nil] fileSize];
                            [newFile setObject:[NSNumber numberWithLong:fileSize] forKey:TapDataFileSizeKey];
                            [newFile setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:TapDataLastAccessTimeKey];
                        } else {
                            [newFile setObject:[NSString stringWithFormat:@"%@", error.description] forKey:TapDataErrorKey];
                            [[NSNotificationCenter defaultCenter] postNotificationName:TapDataFileError object:newFile];
                        }
                        theFile = newFile;
                    }
                    [newFiles addObject:newFile];
                }
                self.files = newFiles;
                [[NSUserDefaults standardUserDefaults] setObject:newFiles forKey:TapDataFilesStoreKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if(!error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TapDataFileReady object:theFile];
                    if([TapDataJsonExtension isEqualToString:theFile[TapDataExtensionKey]]) {
                        [self databaseReady:theFile];
                    }
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TapDataFileError object:theFile];
                    if([TapDataJsonExtension isEqualToString:theFile[TapDataExtensionKey]]) {
                        [self databaseError:theFile];
                    }
                }
            }];
            [requests addObject:downloadTask];
            [downloadTask resume];
            NSMutableArray* leftRequests = [[NSMutableArray alloc] init];
            for(NSURLSessionDownloadTask* task in requests) {
                if([task state] != NSURLSessionTaskStateCompleted) {
                    [leftRequests addObject:task];
                }
            }
            requests = leftRequests;
         }
    }
    self.files = newFiles;
    [[NSUserDefaults standardUserDefaults] setObject:newFiles forKey:TapDataFilesStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSURL*)localFileUrl:(NSURL*)url {
    NSString* urlAsString = [NSString stringWithFormat:@"%@", url];
    for(NSDictionary* file in files) {
        NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[TapDataUrlKey]];
        if([urlAsString compare:fileUrlAsString] == NSOrderedSame) {
            NSString* state = [NSString stringWithFormat:@"%@", file[TapDataStateKey]];
            if([state compare:TapDataStateReady] == NSOrderedSame) {
                NSURL *fileUrl = [self fileUrl:file];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]];
                if(fileExists) {
                    return fileUrl;
                }
            }
        }
    }
    return nil;
}

-(NSURL*)fileUrl:(NSDictionary*)info {
    NSURL *documentsDirectoryURL = [TapData dirUrl];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", info[TapDataTokenKey], info[TapDataExtensionKey]]];
    return fileURL;
}

+(NSURL*)dirUrl {
    return [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];;
}

@end
