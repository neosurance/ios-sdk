#import "TapView.h"
#import <WebKit/WebKit.h>

@class TapWebView;

@protocol TapWebViewDelegate <NSObject>
@optional
- (void)onMessage:(TapWebView*)webView body:(NSDictionary*)body;
- (void)onLoad:(TapWebView*)webView;
@end

@interface TapWebView : TapView<WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate> {
    WKWebViewConfiguration *webConfiguration;
    WKWebView* web;
    NSURL* url;
    NSString* title;
    __weak id <TapWebViewDelegate> delegate;
    BOOL paddingEnabled;
}

@property (nonatomic, weak) id <TapWebViewDelegate> delegate;
@property (nonatomic, copy) NSURL* url;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, readonly) WKWebView* web;
@property BOOL paddingEnabled;

-(void)loadURL:(NSURL*)url;
-(void)evaluateJavaScript:(NSString*)javascript;
-(void)close;
-(void)shareUrl:(NSNotification*)notification;

@end
