#import "TapController.h"
#import "TapWebView.h"
#import "TapWebViewToolbar.h"

@interface TapWebController : TapController {
    TapWebView* webView;
    TapWebViewToolbar* toolbar;
    BOOL webViewReady;
    BOOL isFullscreen;
    __weak id <TapWebViewDelegate> delegate;
    NSString* bodyClassCheck;
}

@property (nonatomic, weak) id <TapWebViewDelegate> delegate;
@property BOOL isFullscreen;
@property (nonatomic, copy) NSString* bodyClassCheck;

@end


