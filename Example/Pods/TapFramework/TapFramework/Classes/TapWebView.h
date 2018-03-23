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
    NSString* bodyClass;
    __weak id <TapWebViewDelegate> delegate;
    BOOL paddingEnabled;
    BOOL closed;
}

@property (nonatomic, weak) id <TapWebViewDelegate> delegate;
@property (nonatomic, copy) NSURL* url;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* bodyClass;
@property (nonatomic, readonly) WKWebView* web;
@property BOOL paddingEnabled;
@property BOOL closed;

-(void)loadURL:(NSURL*)url;
-(void)evaluateJavaScript:(NSString*)javascript;
-(void)close;
-(void)shareUrl:(NSNotification*)notification;

@end
