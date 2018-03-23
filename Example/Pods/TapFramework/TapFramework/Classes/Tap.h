#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TapNavigationController.h"
#import "TapSounds.h"
#import "TapWebView.h"

#define IDIOM                          UI_USER_INTERFACE_IDIOM()
#define IDIOM_IPAD                     UIUserInterfaceIdiomPad
#define IDIOM_IPHONE                   UIUserInterfaceIdiomPhone
#define IS_IPAD                        (IDIOM == IDIOM_IPAD)
#define IS_IPHONE                      (IDIOM == IDIOM_IPHONE)
#define IS_IPHONEX                     (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 812.0f || [[UIScreen mainScreen] bounds].size.width ==  12.0f))

#define TapViewSizeChanged             @"TapViewSizeChanged"
#define TapDataFileReady               @"TapDataFileReady"
#define TapDataFileChanged             @"TapDataFileChanged"
#define TapDataFileError               @"TapDataFileError"
#define TapDataFileDeleted             @"TapDataFileDeleted"
#define TapDataFilesStoreKey           @"TapDataFiles"
#define TapDataDatabasesStoreKey       @"TapDataDatabases"
#define TapDataStateDownloading        @"downloading"
#define TapDataStateNoData             @"noData"
#define TapDataStateReady              @"ready"
#define TapDataStateKey                @"state"
#define TapDataPercentageKey           @"percentage"
#define TapDataExtensionKey            @"extension"
#define TapDataInfoKey                 @"info"
#define TapDataUrlKey                  @"url"
#define TapDataTokenKey                @"token"
#define TapDataLastAccessTimeKey       @"lastAccessTime"
#define TapDataFileSizeKey             @"fileSize"
#define TapDataJsonExtension           @"json"
#define TapDataErrorKey                @"error"
#define TapScrollViewTap               @"TapScrollViewTap"
#define TapScrollViewDoubleTap         @"TapScrollViewDoubleTap"
#define TapDataTitleKey                @"title"
#define TapDataTypeKey                 @"type"
#define TapResizeFull                  @"TapResizeFull"
#define TapResizeSmall                 @"TapResizeSmall"
#define TapShare                       @"TapShare"
#define TapImageReady                  @"TapImageReady"
#define TapHeaderBackTouchUpInside     @"TapHeaderBackTouchUpInside"
#define TapDeletableTouchesMoved       @"TapDeletableTouchesMoved"
#define TapVideoReady                  @"TapVideoReady"
#define TapVideoFailed                 @"TapVideoFailed"
#define TapVideoChanged                @"TapVideoChanged"
#define TapVideoPlaySliderChanged      @"TapVideoPlaySliderChanged"
#define TapVideoRateSliderChanged      @"TapVideoRateSliderChanged"
#define TapVideoTimeChanged            @"TapVideoTimeChanged"
#define TapVideoPlay                   @"TapVideoPlay"
#define TapVideoPause                  @"TapVideoPause"
#define TapVideoFastBackward           @"TapVideoFastBackward"
#define TapVideoFastForward            @"TapVideoFastForward"
#define TapVideoDownload               @"TapVideoDownload"
#define TapDataDatabaseType            @"database"
#define TapDataDatabaseChanged         @"TapDataDatabaseChanged"
#define TapDataDatabaseReady           @"TapDataDatabaseReady"
#define TapDataDatabaseError           @"TapDataDatabaseError"
#define TapDataImageType               @"image"
#define TapDataVideoType               @"video"
#define TapDataPdfType                 @"pdf"
#define TapDataWebType                 @"web"
#define TapDataPdfExtension            @"pdf"
#define TapDataZipExtension            @"zip"
#define TapWebViewDidFinishNavigation  @"TapWebViewDidFinishNavigation"
#define TapWebViewReady                @"TapWebViewReady"


@class Tap;

@protocol TapDelegate <NSObject>
@optional
- (BOOL)onWebMessage:(TapWebView*)webView body:(NSDictionary*)body;
- (void)onWebInit:(TapWebView*)webView;
- (NSDictionary*)onContentData:(NSDictionary*)contentData;
- (void)onLogin;
@end


@interface Tap : NSObject {
    BOOL resizeFull;
    __weak id <TapDelegate> delegate;
}

@property (nonatomic, weak) id <TapDelegate> delegate;

@property (strong, nonatomic) UINavigationController *navigationController;
@property BOOL resizeFull;

+ (id)sharedInstance;
+ (void)sound:(TapSound)sound;
- (UIWindow*)setApp:(UIViewController*)controller;
- (void)share:(NSArray *)array sender:(UIView *)sender;
- (void)lightImpact;
- (void)mediumImpact;
- (void)heavyImpact;
- (void)pop:(BOOL)animated;
- (void)push:(UIViewController*)controller animated:(BOOL)animated;
- (float)safeHorizontalPadding;

@end
