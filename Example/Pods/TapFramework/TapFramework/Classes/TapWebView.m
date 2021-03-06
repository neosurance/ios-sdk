#import "TapWebController.h"
#import "TapWebView.h"
#import "TapWebViewToolbar.h"
#import "TapData.h"
#import "TapSettings.h"

@implementation TapWebView

@synthesize url, delegate, title, web, paddingEnabled,bodyClass;

- (id)init {
    if (self = [super init]) {
        paddingEnabled = NO;
        closed = NO;
    }
    return self;
}

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
    if (@available(iOS 11.0, *)) {
        web.scrollView.insetsLayoutMarginsFromSafeArea = NO;
        web.scrollView.contentInsetAdjustmentBehavior= UIScrollViewContentInsetAdjustmentNever;
    }
}

-(void)dealloc {
    NSLog(@"DEALLOC %@", self.url);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSString* url = [NSString stringWithFormat:@"%@", navigationAction.request.URL];
        if([url hasSuffix:@".pdf"]) {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:NULL];
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

-(void)shareUrl:(NSNotification*)notification {
    TapWebViewToolbar* toolbar = notification.object;
    if([toolbar isKindOfClass:[TapWebViewToolbar class]]) {
        [[Tap sharedInstance] share:@[ self.url ] sender:toolbar.btnShare];
    }
}

-(void)close {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [webConfiguration.userContentController removeScriptMessageHandlerForName:@"app"];
    closed = YES;
}

-(void)checkBody {
    [self.web evaluateJavaScript:@"document.body.className" completionHandler:^(id result, NSError *error) {
        self.bodyClass = result;
      [[NSNotificationCenter defaultCenter] postNotificationName:@"BodyCheck" object:self userInfo:nil];
    }];
    if(!closed) {
        [self performSelector:@selector(checkBody) withObject:nil afterDelay:5];
    }
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    web.frame = CGRectMake(0, 0, size.width, size.height);
    if(paddingEnabled) {
        //int hh = [[[TapSettings sharedInstance] number:TapSettingHeaderHeight] intValue];
        //int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
        float safeAreaLeft = 0;
        float safeAreaRight = 0;
        float safeAreaTop = 0;
        float safeAreaBottom = 0;
        if (@available(iOS 11.0, *)) {
            safeAreaRight = [self superview].safeAreaInsets.right;
            safeAreaLeft = [self superview].safeAreaInsets.left;
            safeAreaTop = [self superview].safeAreaInsets.top;
            safeAreaBottom = [self superview].safeAreaInsets.bottom;
        }
        web.scrollView.contentInset = UIEdgeInsetsMake(0,0,0,0);
        //web.scrollView.contentInset = UIEdgeInsetsMake(0,0,safeAreaBottom,0);
    }
}

-(void)evaluateJavaScript:(NSString*)javascript {
    //NSLog(@"%@", javascript);
    [self performSelectorOnMainThread:@selector(eval:) withObject:javascript waitUntilDone:YES];
}

-(void)eval:(NSString*)javascript {
    [web evaluateJavaScript:javascript completionHandler:^(id result, NSError *error) {
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *body = (NSDictionary*)message.body;
    if([self.delegate respondsToSelector:@selector(onMessage:body:)]) {
        [self.delegate onMessage:self body:body];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if(paddingEnabled) {
        int hh = [[[TapSettings sharedInstance] number:TapSettingHeaderHeight] intValue];
        webView.scrollView.contentOffset = CGPointMake(0, -hh);
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    webView.alpha = 1;
    [UIView commitAnimations];
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error) {
        if(!error) {
            self.title = [NSString stringWithFormat:@"%@", result];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:TapWebViewReady object:self];
    }];
    if([self.delegate respondsToSelector:@selector(onLoad:)]) {
        [self.delegate onLoad:self];
    }
    [self performSelector:@selector(checkBody) withObject:nil afterDelay:5];
    [[NSNotificationCenter defaultCenter] postNotificationName:TapWebViewDidFinishNavigation object:self];
}

-(void)loadURL:(NSURL*)aUrl {
    self.url = aUrl;
    [self performSelector:@selector(loadURL) withObject:nil afterDelay:0];
}

-(void)loadURL {
    if([url isFileURL]) {
        [web loadFileURL:url allowingReadAccessToURL:[TapData dirUrl]];
    } else {
        [web loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

@end
