#import "TapUtils.h"
#import "TapSettings.h"
#import <sys/utsname.h>
#import <CoreText/CTFontManager.h>
#import <CommonCrypto/CommonDigest.h>

@implementation TapUtils

+ (NSString *)uuid {
    NSString *uuid = nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_uuid"] != nil) {
        uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_uuid"];
    } else {
        uuid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"device_uuid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return uuid;
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
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(provider);
}

+ (void)play:(NSURL*)url {
    [[TapSettings sharedInstance] play:url];
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

