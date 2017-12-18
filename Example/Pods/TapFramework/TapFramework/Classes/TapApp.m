#import "TapApp.h"
#import "TapData.h"
#import "TapUtils.h"
#import <ZipArchive/ZipArchive.h>

@implementation TapApp

@synthesize appKey, appName, delegate, info;

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileReady:) name:TapDataFileReady object:nil];
        [self performSelector:@selector(downloadUi) withObject:nil afterDelay:0];
    }
    return self;
}

-(void)downloadUi {
    NSString* versionUrlAsString = [NSString stringWithFormat:@"%@version.json", info[TapDataUrlKey]];
    NSURL* versionUrl = [NSURL URLWithString:versionUrlAsString];
    NSLog(@"   app: %@", versionUrl);
    [TapData requestWithURL:versionUrl completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        BOOL needsUpdateUi = NO;
        NSString* version = [self version];
        int build = [self build];
        NSString* serverVersion = nil;
        int serverBuild = 0;
        NSLog(@"   app: %@.%d", version, build);
        if (error) {
        } else {
            serverVersion =  [NSString stringWithFormat:@"%@", responseObject[@"version"]];
            serverBuild = [[NSString stringWithFormat:@"%@", responseObject[@"build"]] intValue];
            NSLog(@"server: %@.%d", serverVersion, serverBuild);
            if([version isEqualToString:serverVersion] && build != serverBuild) {
                needsUpdateUi = YES;
            }
        }
        NSString* uiUrlAsString = [NSString stringWithFormat:@"%@ui.app", info[TapDataUrlKey]];
        NSURL* uiUrl = [[TapData sharedInstance] localFileUrl:[NSURL URLWithString:uiUrlAsString]];
        if(needsUpdateUi) {
            [[TapData sharedInstance] deleteFile:[NSURL URLWithString:uiUrlAsString]];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:serverBuild] forKey:[self key:@"build"]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if(uiUrl == nil && [version isEqualToString:serverVersion]) {
            needsUpdateUi = YES;
        }
        if(needsUpdateUi) {
            NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
            [[TapData sharedInstance] downloadFile:[NSURL URLWithString:uiUrlAsString] extension:TapDataZipExtension type:TapDataZipExtension title:info[TapDataTitleKey] info:data];
        } else {
            [self unzipUi:uiUrl];
        }
    }];
}

-(void)fileReady:(NSNotification*)notification {
    NSDictionary* file = notification.object;
    //NSLog(@"  file: %@", file[TapDataUrlKey]);
    {
        NSString* uiUrlAsString = [NSString stringWithFormat:@"%@ui.app", info[TapDataUrlKey]];
        NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[TapDataUrlKey]];
        if([uiUrlAsString compare:fileUrlAsString] == NSOrderedSame) {
            NSURL* uiUrl = [[TapData sharedInstance] localFileUrl:[NSURL URLWithString:uiUrlAsString]];
            [self unzipUi:uiUrl];
        }
    }
}

-(void)unzipUi:(NSURL*)uiUrl {
    //NSLog(@"    ui: OK");
    NSURL* appUrl = [[TapData dirUrl] URLByAppendingPathComponent:@"app.html"];
    [[NSFileManager defaultManager] removeItemAtURL:appUrl error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:[[TapData dirUrl] URLByAppendingPathComponent:@"ui"] error:nil];
    ZipArchive* zipArchive = [[ZipArchive alloc] initWithFileManager:[NSFileManager defaultManager]];
    [zipArchive UnzipOpenFile:[uiUrl path]];
    [zipArchive UnzipFileTo:[[TapData dirUrl] path] overWrite:YES];
    if([self.delegate respondsToSelector:@selector(onUiReady:)]) {
        [self.delegate onUiReady:self];
    }
}

-(BOOL)authenticated {
    return [self username] != nil;
}

-(NSString*)username {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self key:@"username"]];
}

-(NSString*)version {
    return [NSString stringWithFormat:@"%@", info[@"version"]];
}

-(NSString*)uuid {
    return [TapUtils uuid:appName account:appKey];
}

-(int)build {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[self key:@"build"]] intValue];
}

-(NSString*)key:(NSString*)name {
    return [NSString stringWithFormat:@"%@_%@", appKey, name];
}

-(NSString*)versionNumber {
    return [NSString stringWithFormat:@"%@.%d", [self version], [self build]];
}

-(void)signIn:(NSString*)username token:(NSString*)token {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:[self key:@"username"]];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:[self key:@"token"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)signOut {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self key:@"username"]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self key:@"token"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
