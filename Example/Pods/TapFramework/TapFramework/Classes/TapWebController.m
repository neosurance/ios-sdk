#import "TapWebController.h"
#import "TapSettings.h"
#import "Tap.h"
#import "TapData.h"

@implementation TapWebController

@synthesize delegate, isFullscreen, bodyClassCheck;

- (id)init {
    if (self = [super init]) {
        self.isFullscreen = NO;
    }
    return self;
}

-(void)loadUi {
    [super loadUi];
    [self waitOn];
    self.view.backgroundColor = [UIColor blackColor];
    webView = [[TapWebView alloc] initWithDictionary:info];
    [self.view addSubview:webView];
    //webView.paddingEnabled = YES;
    webView.delegate = self.delegate;
    toolbar = [[TapWebViewToolbar alloc] init];
    [self.view addSubview:toolbar];
    if(isFullscreen) {
        header.alpha = 0;
    }
    toolbar.alpha = 0;
    if([TapDataPdfExtension isEqualToString:info[TapDataExtensionKey]]) {
        [self performSelector:@selector(downloadFile) withObject:nil afterDelay:0];
    } else {
        [webView loadURL:info[TapDataUrlKey]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileError:) name:TapDataFileError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileReady:) name:TapDataFileReady object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:webView selector:@selector(shareUrl:) name:TapShare object:toolbar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewReady) name:TapWebViewReady object:webView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bodyCheck:) name:@"BodyCheck" object:webView];
}

-(void)bodyCheck:(NSNotification*)notification {
    TapWebView* webView = notification.object;
    if(self.bodyClassCheck != nil) {
        if(![webView.bodyClass isEqualToString:self.bodyClassCheck]) {
            [[self navigationController] popViewControllerAnimated:YES];
        }
     }
}

-(void)fileError:(NSNotification*)notification {
}

-(void)fileReady:(NSNotification*)notification {
    NSDictionary* file = notification.object;
    NSString* urlAsString = [NSString stringWithFormat:@"%@", info[TapDataUrlKey]];
    NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[TapDataUrlKey]];
    if([urlAsString compare:fileUrlAsString] == NSOrderedSame) {
        [webView loadURL:[NSURL URLWithString:urlAsString]];
    }
}

-(void)downloadFile {
    NSString* urlAsString = [NSString stringWithFormat:@"%@", info[TapDataUrlKey]];
    NSURL* url = [[TapData sharedInstance] localFileUrl:[NSURL URLWithString:urlAsString]];
    if(url != nil) {
        [webView loadURL:url];
    } else {
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        if(info[@"fileInfo"] != nil) {
            data = [[NSMutableDictionary alloc] initWithDictionary:info[@"fileInfo"]];
        }
        [[TapData sharedInstance] downloadFile:info[TapDataUrlKey] extension:info[TapDataExtensionKey] type:info[TapDataTypeKey] title:info[TapDataTitleKey] info:data];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    BOOL closed = YES;
    for(UIViewController* controller in [self.navigationController viewControllers]) {
        if(controller == self) {
            closed = NO;
        }
    }
    if(closed) {
        NSLog(@"CLOSED %@", self);
        webView.delegate = self.delegate = nil;
        [webView close];
    }
}

-(void)webViewReady {
    [self waitOff];
    webViewReady = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    if(header.alpha == 1) {
        if(![TapDataPdfExtension isEqualToString:info[TapDataExtensionKey]]) {
            toolbar.alpha = 1;
        }
    }
    [UIView commitAnimations];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    float safeAreaLeft = 0;
    float safeAreaRight = 0;
    float safeAreaTop = 0;
    float safeAreaBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaRight = self.view.safeAreaInsets.right;
        safeAreaLeft = self.view.safeAreaInsets.left;
        safeAreaTop = self.view.safeAreaInsets.top;
        safeAreaBottom = self.view.safeAreaInsets.bottom;
    }
    int hh = [[[TapSettings sharedInstance] number:TapSettingHeaderHeight] intValue];
    int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
    if(header.alpha == 0) {
        hh = 0;
        if(IS_IPHONEX) {
            webView.layer.cornerRadius = 20;
            webView.clipsToBounds = YES;
        }
    }
    if(![TapDataPdfExtension isEqualToString:info[TapDataExtensionKey]]) {
        webView.frame = CGRectMake(0, sh+hh, size.width, size.height-sh-hh*2-safeAreaBottom);
        toolbar.frame = CGRectMake(0, size.height-(hh+safeAreaBottom), size.width, hh+safeAreaBottom);
    } else {
        webView.frame = CGRectMake(0, sh+hh, size.width, size.height-sh-hh-safeAreaBottom);
    }
}

-(void)toggleUi {
    [super toggleUi];
    if(webViewReady && !isFullscreen) {
       toolbar.alpha = header.alpha;
    }
}

@end
