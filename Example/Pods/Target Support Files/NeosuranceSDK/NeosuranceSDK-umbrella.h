#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NeosuranceSDK.h"
#import "NSR.h"
#import "NSRDefaultSecurityDelegate.h"
#import "NSRRequest.h"
#import "NSRUser.h"
#import "NSRUtils.h"

FOUNDATION_EXPORT double NeosuranceSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char NeosuranceSDKVersionString[];

