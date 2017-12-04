#import "TapWeb.h"
#import "TapSettings.h"
#import "TapData.h"
#import "TapWebController.h"

@implementation TapWeb

@synthesize url, delegate, javascript, title, web;

-(void)loadUi {
    [super loadUi];
    webConfiguration = [[WKWebViewConfiguration alloc] init];
    [webConfiguration.userContentController addScriptMessageHandler:self name:@"app"];
    web = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfiguration];
    [self addSubview:web];
    web.navigationDelegate = self;
    web.alpha = 0;
    web.scrollView.showsVerticalScrollIndicator = NO;
    web.scrollView.showsHorizontalScrollIndicator = NO;
    web.scrollView.bounces = NO;
}

-(void)close {
    [webConfiguration.userContentController removeScriptMessageHandlerForName:@"app"];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    web.frame = CGRectMake(0, 0, size.width, size.height);
}

-(void)evaluateJavaScript:(NSString*)javascript {
    self.javascript = javascript;
    [self performSelectorOnMainThread:@selector(eval) withObject:nil waitUntilDone:YES];
}
-(void)eval {
    [web evaluateJavaScript:self.javascript completionHandler:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *body = (NSDictionary*)message.body;
    if([self.delegate respondsToSelector:@selector(onMessage:body:)]) {
        [self.delegate onMessage:self body:body];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSString* url = [NSString stringWithFormat:@"%@", navigationAction.request.URL];
        if([url hasSuffix:@".pdf"]) {
            TapWebController* controller = [[TapWebController alloc] init];
            controller.info = info;
            controller.url =  navigationAction.request.URL;
            controller.extension = @"pdf";
            controller.needsFileLocally = YES;
            //[[TapApp sharedInstance] push:controller animated:YES];
            //        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:[[NSDictionary alloc]init] completionHandler:nil];
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
        //
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
 }

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    webView.alpha = 1;
    [UIView commitAnimations];
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error) {
        if(!error) {
            self.title = [NSString stringWithFormat:@"%@", result];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TapWebReady" object:self];
    }];
    if([self.delegate respondsToSelector:@selector(onLoad:)]) {
        [self.delegate onLoad:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TapWebDidFinishNavigation" object:self];
}

-(void)loadURL:(NSURL*)theUrl {
    self.url = theUrl;
    [self performSelector:@selector(loadURL) withObject:nil afterDelay:0];
}

-(void)loadURL {
    if([url isFileURL]) {
        //[web loadFileURL:url allowingReadAccessToURL:[TapData dirUrl]];
    } else {
        [web loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

@end
