#import "TapAppController.h"
#import "TapWebController.h"
#import "TapVideoController.h"
#import "TapData.h"
#import "TapSettings.h"
#import "TapListController.h"
#import <ZipArchive/ZipArchive.h>

@implementation TapAppController

@synthesize uiView, menuEnabled;

- (id)init {
    if (self = [super init]) {
        toggleUiEnabled = NO;
        menuEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    statusBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)dealloc {
    [uiView close];
    [menuView close];
}

-(void)loadUi {
    [super loadUi];
    menuOpened = NO;
    app = [[TapApp alloc] init];
    app.info = self.info;
    app.appKey = self.info[@"key"];
    app.appName = self.info[@"title"];
    app.delegate = self;
    uiView = [[TapWebView alloc] init];
    [self.view addSubview:uiView];
    uiView.delegate = self;
    if(menuEnabled) {
        menuView = [[TapWebView alloc] init];
        [self.view addSubview:menuView];
        menuView.delegate = self;
        menuView.web.alpha = uiView.web.alpha = 0;
        menuOpenedOverView = [[UIButton alloc] init];
        menuOpenedOverView.backgroundColor = [UIColor blackColor];
        [menuOpenedOverView addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:menuOpenedOverView];
        menuBtn = [[TapButton alloc] initWithIcon:TapButtonIconMenu];
        [[self view] addSubview:menuBtn];
        menuBtnOn = [[TapButton alloc] initWithIcon:TapButtonIconMenu];
        [[self view] addSubview:menuBtnOn];
        menuBtn.alpha = menuBtnOn.alpha = 0;
        [menuBtn addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
        [menuBtnOn addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
        {
            UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenuWithSwipe)];
            swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
            UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openMenuWithSwipe)];
            swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
            [uiView.web.scrollView addGestureRecognizer:swipeLeft];
            [uiView.web.scrollView addGestureRecognizer:swipeRight];
            [self.view addGestureRecognizer:swipeLeft];
            [self.view addGestureRecognizer:swipeRight];
        }
        {
            UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenuWithSwipe)];
            swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
            UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openMenuWithSwipe)];
            swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
            [menuView.web.scrollView addGestureRecognizer:swipeLeft];
            [menuView.web.scrollView addGestureRecognizer:swipeRight];
        }
        {
            UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenuWithSwipe)];
            swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
            [menuOpenedOverView addGestureRecognizer:swipeLeft];
        }
    }
    [self waitOn];
    header.title = @"";
    header.alpha = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseReady:) name:TapDataDatabaseReady object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseChanged:) name:TapDataDatabaseChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderUi) name:@"DataChanged" object:nil];
}

-(void)renderUi {
    [self initWebapp:uiView];
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
    [uiView evaluateJavaScript:[NSString stringWithFormat:@"uiSafeArea(%f,%f,%f,%f)", safeAreaLeft, safeAreaTop, safeAreaRight, safeAreaBottom]];
    [menuView evaluateJavaScript:[NSString stringWithFormat:@"uiSafeArea(%f,%f,%f,%f)", safeAreaLeft, safeAreaTop, safeAreaRight, safeAreaBottom]];
    if(menuEnabled) {
        float safeAreaTop = 0;
        if (@available(iOS 11.0, *)) {
            safeAreaTop = self.view.safeAreaInsets.top;
        }
        menuView.frame = CGRectMake(menuOpened?0:-280,0,280,size.height);
        menuBtn.frame = menuBtnOn.frame = CGRectMake((menuOpened?280:0)+safeAreaLeft,safeAreaTop,48,48);
        menuOpenedOverView.frame = CGRectMake(menuOpened?280:0,0,size.width,size.height);
        menuOpenedOverView.alpha = menuOpened*0.5;
    }
    uiView.frame = CGRectMake(menuOpened?280:0,0,size.width,size.height);
    [self performSelector:@selector(setupBtns) withObject:nil afterDelay:0];
}

-(void)setupBtns {
    if(menuEnabled) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        if([app authenticated]) {
            if(menuOpened) {
                menuBtn.alpha = 0;
                menuBtnOn.alpha = 1;
            } else {
                menuBtn.alpha = 1;
                menuBtnOn.alpha = 0;
            }
        } else {
            menuBtn.alpha = 0;
            menuBtnOn.alpha = 0;
        }
        [UIView commitAnimations];
    }
}


- (void)openMenuWithSwipe {
    [self openMenu];
}

- (void)closeMenuWithSwipe {
    [self closeMenu];
}

- (void)toggleMenu {
    if([[[Tap sharedInstance] navigationController] visibleViewController] == self) {
        if (menuOpened) {
            [self closeMenu];
        } else {
            [self openMenu];
        }
    }
}

- (void)openMenu {
    if([app authenticated]) {
        if([[[Tap sharedInstance] navigationController] visibleViewController] == self) {
            menuOpened = YES;
            [self setupUiAnimated];
        }
    }
}

- (void)closeMenu {
    if([app authenticated]) {
        if([[[Tap sharedInstance] navigationController] visibleViewController] == self) {
            menuOpened = NO;
            [self setupUiAnimated];
        }
    }
}

-(void)databaseReady:(NSNotification*)notification {
    NSDictionary* databaseInfo = notification.object;
    if([@"UserData" isEqualToString:databaseInfo[TapDataTitleKey]]) {
        NSDictionary* userData = [[TapData sharedInstance] data:@"UserData"];
        if(userData[@"username"] != nil) {
            NSString* token = [app uuid];
            [app signIn:userData[@"username"] token:token];
            NSString* urlAsString = [NSString stringWithFormat:@"%@contentData.json?username=%@&password=%@&token=%@", info[TapDataUrlKey], userData[@"username"], userData[@"password"], token];
            NSURL* url = [NSURL URLWithString:urlAsString];
            [[TapData sharedInstance] removeDatabase:@"ContentData"];
            [[TapData sharedInstance] registerDatabase:url title:@"ContentData" info:nil];
            Tap* tap = [Tap sharedInstance];
            if([tap.delegate respondsToSelector:@selector(onLogin)]) {
                [tap.delegate onLogin];
            }
        } else {
            [[TapData sharedInstance] removeDatabase:@"UserData"];
            [self what:@"login-error" value:nil];
            [self waitOff];
        }
    }
    if([@"ContentData" isEqualToString:databaseInfo[TapDataTitleKey]]) {
        [self loadChannel:@"home"];
        [self waitOff];
    }
}

-(void)databaseChanged:(NSNotification*)notification {
    NSLog(@"databaseChanged");
    NSDictionary* databaseInfo = notification.object;
    if([@"UserData" isEqualToString:databaseInfo[TapDataTitleKey]] || [@"ContentData" isEqualToString:databaseInfo[TapDataTitleKey]]) {
        [self initWebapp:uiView];
    }
}

- (void)onLoad:(TapWebView *)webView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppReady" object:nil];
    [self setupUiAnimated];
}

-(void)initWebapp:(TapWebView*)webView {
    Tap* tap = [Tap sharedInstance];
    if([app authenticated]) {
        [webView evaluateJavaScript:[NSString stringWithFormat:@"setUserData(%@)", [[TapData sharedInstance] dataAsJsonString:@"UserData"]]];
        if([tap.delegate respondsToSelector:@selector(onContentData:)]) {
            NSDictionary* contentData = [tap.delegate onContentData:[[TapData sharedInstance] data:@"ContentData"]];
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contentData options:0 error:&error];
            [webView evaluateJavaScript:[NSString stringWithFormat:@"setContentData(%@)", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]]];
        } else {
            [webView evaluateJavaScript:[NSString stringWithFormat:@"setContentData(%@)", [[TapData sharedInstance] dataAsJsonString:@"ContentData"]]];
        }
        if([tap.delegate respondsToSelector:@selector(onWebInit:)]) {
            [tap.delegate onWebInit:webView];
        }
        [webView evaluateJavaScript:[NSString stringWithFormat:@"setFilesData(%@)", [[TapData sharedInstance] filesAsJsonString]]];
    }
    [webView evaluateJavaScript:[NSString stringWithFormat:@"renderUi()"]];
    [webView evaluateJavaScript:[NSString stringWithFormat:@"setVersion('%@')", [app versionNumber]]];
    
}

- (void)signOut {
    [app signOut];
}

- (void)onMessage:(TapWebView*)webView body:(NSDictionary*)body {
    Tap* tap = [Tap sharedInstance];
    BOOL skip = NO;
    if([tap.delegate respondsToSelector:@selector(onWebMessage:body:)]) {
        skip = [tap.delegate onWebMessage:webView body:body];
    }
    if(skip) {
        return;
    }
    NSLog(@"%@", body);
    if([@"init" compare:body[@"what"]] == NSOrderedSame) {
        [self initWebapp:webView];
        [self waitOff];
    }
    if([@"login" compare:body[@"what"]] == NSOrderedSame) {
        [self waitOn];
        NSString* urlAsString = [NSString stringWithFormat:@"%@userData.json?%@&token=%@", info[TapDataUrlKey], body[@"form"], [app uuid]];
        NSURL* url = [NSURL URLWithString:urlAsString];
        [[TapData sharedInstance] removeDatabase:@"UserData"];
        [[TapData sharedInstance] registerDatabase:url title:@"UserData" info:nil];
    }
    if([@"logout" compare:body[@"what"]] == NSOrderedSame) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sign Out" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self closeMenu];
        }];
        [alert addAction:cancelAction];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            [self closeMenu];
            [self signOut];
            [self loadChannel:@"login"];
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    if([@"changeChannel" compare:body[@"what"]] == NSOrderedSame) {
        if([@"documents" isEqualToString:body[@"channel"]]) {
            TapListController *controller = [[TapListController alloc] init];
            NSMutableDictionary* info = [[NSMutableDictionary alloc] initWithDictionary:self.info];
            NSMutableArray* items = [[NSMutableArray alloc] init];
            for(NSDictionary* file in [[TapData sharedInstance] files]) {
                if([@"ready" isEqualToString:file[@"state"]] && ([@"pdf" isEqualToString:file[@"extension"]] || [@"mp4" isEqualToString:file[@"extension"]])) {
                    NSMutableDictionary* item = [[NSMutableDictionary alloc] initWithDictionary:file];
                    [item setObject:@"AppDocListItem" forKey:@"class"];
                    [item setObject:@"64" forKey:@"h"];
                    [items addObject:item];
                }
            }
            [info setObject:items forKey:@"items"];
            controller.info = info;
            [self closeMenu];
            [[Tap sharedInstance] push:controller animated:YES];
        } else {
            [Tap sound:TapSoundTab2];
            [self loadChannel:body[@"channel"]];
        }
        [self closeMenu];
    }
    if([@"pdf" compare:body[@"what"]] == NSOrderedSame) {
        TapWebController* controller = [[TapWebController alloc] init];
        NSMutableDictionary* item = [[NSMutableDictionary alloc] init];
        [item setObject:[NSURL URLWithString:body[@"value"]] forKey:@"url"];
        [item setObject:@"web" forKey:@"type"];
        [item setObject:@"pdf" forKey:@"extension"];
        [item setObject:body[@"title"] forKey:@"title"];
        controller.info = item;
        [[Tap sharedInstance] push:controller animated:YES];
    }
    if([@"video" compare:body[@"what"]] == NSOrderedSame) {
        TapVideoController* controller = [[TapVideoController alloc] init];
        NSMutableDictionary* item = [[NSMutableDictionary alloc] init];
        [item setObject:[NSURL URLWithString:body[@"value"]] forKey:@"url"];
        [item setObject:@"video" forKey:@"type"];
        [item setObject:@"mp4" forKey:@"extension"];
        [item setObject:body[@"title"] forKey:@"title"];
        if(body[@"tags"] != nil) {
            [item setObject:body[@"tags"] forKey:@"tags"];
        }
        controller.info = item;
        [[Tap sharedInstance] push:controller animated:YES];
    }
}

- (void)onUiReady:(TapApp *)app {
    if([app authenticated]) {
        [self loadChannel:@"home"];
    } else {
        [self loadChannel:@"login"];
    }
}

-(void)loadChannel:(NSString*)channel {
    uiView.web.alpha = 0;
    NSURL* appUrl = [[TapData dirUrl] URLByAppendingPathComponent:@"app.html"];
    NSURL* fileURLWithParams = [NSURL URLWithString:[NSString stringWithFormat:@"%@?channel=%@&device=%@", appUrl, channel, IDIOM == IDIOM_IPAD?@"ipad":@"iphone"]];
    [uiView loadURL:fileURLWithParams];
    if(menuEnabled) {
        if(menuOpened) {
            [menuView evaluateJavaScript:[NSString stringWithFormat:@"setSelectedChannel('%@')", channel]];
        } else {
            menuView.web.alpha = 0;
            NSURL* fileURLWithParams = [NSURL URLWithString:[NSString stringWithFormat:@"%@?channel=menu&selectedChannel=%@&device=%@", appUrl, channel, IDIOM == IDIOM_IPAD?@"ipad":@"iphone"]];
            [menuView loadURL:fileURLWithParams];
        }
    }
}

+(void)message:(TapWebView*)webView what:(NSString*)what value:(NSString*)value {
    NSError *error;
    NSMutableDictionary* dictionary  = [[NSMutableDictionary alloc] init];
    [dictionary setObject:what forKey:@"what"];
    if(value != nil) {
        [dictionary setObject:value forKey:@"value"];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    [webView evaluateJavaScript:[NSString stringWithFormat:@"appMessage(%@)", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]]];
}

-(void)what:(NSString*)what value:(NSString*)value {
    [TapAppController message:uiView what:what value:value];
}

@end
