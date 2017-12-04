#import "TapView.h"
#import <WebKit/WebKit.h>


@class TapWeb;

@protocol TapWebDelegate <NSObject>
@optional
- (void)onMessage:(TapWeb*)webView body:(NSDictionary*)body;
- (void)onLoad:(TapWeb*)webView;
@end

@interface TapWeb : TapView<WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate> {
    WKWebViewConfiguration *webConfiguration;
    WKWebView* web;
    NSURL* url;
    NSString* title;
    NSString* javascript;
    __weak id <TapWebDelegate> delegate;
}

@property (nonatomic, weak) id <TapWebDelegate> delegate;
@property (nonatomic, copy) NSURL* url;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* javascript;
@property (nonatomic, readonly) WKWebView* web;

-(void)loadURL:(NSURL*)url;
-(void)evaluateJavaScript:(NSString*)javascript;
-(void)close;

@end
