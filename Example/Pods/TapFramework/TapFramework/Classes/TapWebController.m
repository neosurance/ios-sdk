#import "TapWebController.h"
#import "TapSettings.h"
#import "Tap.h"
#import "TapData.h"

@implementation TapWebController

-(void)loadUi {
    [super loadUi];
    [self waitOn];
    self.view.backgroundColor = [UIColor blackColor];
    webView = [[TapWebView alloc] initWithDictionary:info];
    [self.view addSubview:webView];
    webView.paddingEnabled = YES;
    toolbar = [[TapWebViewToolbar alloc] init];
    [self.view addSubview:toolbar];
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

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [webView close];
}

-(void)webViewReady {
    [self waitOff];
    webViewReady = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    if(header.alpha == 1) {
        toolbar.alpha = 1;
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
    webView.frame = CGRectMake(0, 0, size.width, size.height);
    toolbar.frame = CGRectMake(0, size.height-(hh+sh+safeAreaBottom), size.width, hh+sh+safeAreaBottom);
}

-(void)toggleUi {
    [super toggleUi];
    if(webViewReady) {
        toolbar.alpha = header.alpha;
    }
}

@end
