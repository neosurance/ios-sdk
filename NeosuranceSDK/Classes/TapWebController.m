#import "TapWebController.h"
#import "TapSettings.h"
#import "TapData.h"
#import "TapUtils.h"

@implementation TapWebController

@synthesize url, extension, webDelegate, needsFileLocally, controllerView;

- (id)init {
    if (self = [super init]) {
        self.needsFileLocally = NO;
    }
    return self;
}

-(void)loadUi {
    [self waitOn];
    [super loadUi];
    controllerView = [[TapWebControllerView alloc] init];
    controllerView.url = self.url;
    controllerView.extension = self.extension;
    controllerView.webDelegate = self.webDelegate;
    controllerView.needsFileLocally = self.needsFileLocally;
    [self.view addSubview:controllerView];
    if(showHeader) {
        int hh = [[TapSettings sharedInstance] number:TapSettingHeaderHeight];
        controllerView.marginTop = hh;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTitle:) name:@"TapWebReady" object:controllerView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileChanged:) name:@"TapDataFileChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileReady:) name:@"TapDataFileReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelDownload) name:@"TapProgressCancelDownload" object:progressView];
}

-(void)cancelDownload {
    [self pop];
}

-(void)fileChanged:(NSNotification*)notification {
    NSDictionary* file = notification.object;
    NSString* urlAsString = [NSString stringWithFormat:@"%@", self.url];
    NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[@"url"]];
    if([urlAsString compare:fileUrlAsString] == NSOrderedSame) {
        progressView.value = [file[@"percentage"] floatValue];
        [progressView performSelectorOnMainThread:@selector(setupUiAnimated) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setupUiAnimated) withObject:nil waitUntilDone:NO];
    }
}

-(void)fileReady:(NSNotification*)notification {
    [self waitOff];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    controllerView.frame = CGRectMake(0, 0, size.width, size.height);
}

-(void)setTitle:(NSNotification*)notification {
    if(controllerView.web.title != nil && ![controllerView.web.title isEmpty]) {
        [headerView setTitle:controllerView.web.title];
    }
    [self waitOff];
}

@end

@implementation TapWebControllerView

@synthesize url, extension, webDelegate, needsFileLocally, web, marginTop;

- (id)init {
    if (self = [super init]) {
        self.needsFileLocally = NO;
        marginTop = 0;
    }
    return self;
}

-(void)dealloc {
    [web close];
}


-(void)loadUi {
    web = [[TapWeb alloc] init];
    web.delegate = self.webDelegate;
    [self addSubview:web];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupButtons) name:@"TapWebDidFinishNavigation" object:web];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewReady) name:@"TapWebReady" object:web];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileReady:) name:@"TapDataFileReady" object:nil];
    [super loadUi];
}


-(void)goBack {
    [web.web goBack];
}

-(void)goForward {
    [web.web goForward];
}

-(void)reloadFromOrigin {
    [web loadURL:self.url];
}

-(void)setupButtons {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
}

-(void)shareUrl {
}

-(void)didLoadUi {
    [super didLoadUi];
    if(!needsFileLocally) {
        [web loadURL:self.url];
    } else {
        [[TapData sharedInstance] downloadFile:self.url extension:extension info:nil];
    }
}

-(void)fileReady:(NSNotification*)notification {
    NSDictionary* file = notification.object;
    NSString* urlAsString = [NSString stringWithFormat:@"%@", self.url];
    NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[@"url"]];
    if([urlAsString compare:fileUrlAsString] == NSOrderedSame) {
        self.url = [TapData fileUrl:file extension:extension];
        [web loadURL:self.url];
    }
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    web.frame = CGRectMake(0,marginTop,size.width,size.height-marginTop);
 }

-(void)webViewReady {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TapWebReady" object:self];
}

@end
