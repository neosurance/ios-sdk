#import "TapController.h"
#import "TapWebView.h"
#import "TapApp.h"

@interface TapAppController : TapController<TapWebViewDelegate, TapAppDelegate> {
    TapWebView* uiView;
    TapWebView* menuView;
    TapApp* app;
    BOOL menuOpened;
    BOOL menuEnabled;
    UIButton* menuOpenedOverView;
    TapButton* menuBtn;
    TapButton* menuBtnOn;
}

@property (nonatomic, readonly) TapWebView* uiView;
@property BOOL menuEnabled;

+ (void)message:(TapWebView*)webView what:(NSString*)what value:(NSString*)value;
- (void)openMenu;
- (void)closeMenu;
- (void)loadChannel:(NSString*)channel;
- (void)signOut;

@end
