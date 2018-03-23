#import "TapUtils.h"
#import "TapSettings.h"
#import "TapSounds.h"
#import <sys/utsname.h>
#import <CoreText/CTFontManager.h>
#import <CommonCrypto/CommonDigest.h>
#import <SAMKeychain/SAMKeychain.h>
#include <stdlib.h>

@implementation TapUtils

+(void)clear:(UIView*)view {
    if(view != nil) {
        [view removeFromSuperview];
        view = nil;
    }
}

+ (NSArray *)randomArray:(NSArray *)array numberOfItems:(int)size {
    NSMutableArray* pickedItems = [NSMutableArray new];
    int remaining = fmin(size, (int)[array count]);
    while (remaining > 0) {
        id item = array[(int)arc4random_uniform((int)array.count)];
        if (![pickedItems containsObject:item]) {
            [pickedItems addObject:item];
            remaining--;
        }
    }
    return pickedItems;
}

+(NSString *)uuid:(NSString*)appName account:(NSString*)account {
    NSString *strApplicationUUID = [SAMKeychain passwordForService:appName account:account];
    if (strApplicationUUID == nil) {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SAMKeychain setPassword:strApplicationUUID forService:appName account:account];
    }
    NSLog(@"uuid for: %@ = %@", account, strApplicationUUID);
    return strApplicationUUID;
}

+ (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)osVersion {
    return [[NSProcessInfo processInfo] operatingSystemVersionString];
}

+ (void)registerFont:(NSURL *)URL {
    NSData *inData = [NSData dataWithContentsOfURL:URL];
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(provider);
}

+ (void)play:(NSURL*)url {
    [[TapSounds sharedInstance] play:url];
}

+ (NSString *)sha256:(NSString *)string {
    if (string != nil) {
        const char *str = [string cStringUsingEncoding:NSUTF8StringEncoding];
        NSData *keyData = [NSData dataWithBytes:str length:strlen(str)];
        uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
        CC_SHA256(keyData.bytes, (int)keyData.length, digest);
        NSData *data = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
        NSMutableString *dataAsString = [NSMutableString string];
        const unsigned char *dataBuffer = [data bytes];
        for (int i=0; i<[data length]; ++i) {
            [dataAsString appendFormat:@"%02X", (unsigned int)dataBuffer[i]];
        }
        return [dataAsString lowercaseString];
    } else
        return nil;
}

+ (NSBundle*)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    NSString* mainBundlePath = [[NSBundle bundleForClass:[TapUtils class]] resourcePath];
    NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"TapFramework.bundle"];
    frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    return frameworkBundle;
}

@end

@implementation NSString (utils)

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (BOOL)isEmpty {
    return [self compare:@""] == NSOrderedSame;
}

@end

@implementation NSMutableArray (utils)

-(void)reverse {
    if ([self count] <= 1)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
}

@end

