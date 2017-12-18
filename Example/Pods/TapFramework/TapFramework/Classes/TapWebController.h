#import "TapController.h"
#import "TapWebView.h"
#import "TapWebViewToolbar.h"

@interface TapWebController : TapController {
    TapWebView* webView;
    TapWebViewToolbar* toolbar;
    BOOL webViewReady;
}

@end


