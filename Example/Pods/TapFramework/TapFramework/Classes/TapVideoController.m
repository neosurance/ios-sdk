#import "TapVideoController.h"
#import "Tap.h"
#import "TapSettings.h"
#import <UIColor_Utilities/UIColor+Expanded.h>

@implementation TapVideoController

-(void)loadUi {
    [super loadUi];
    self.view.backgroundColor = [UIColor blackColor];
    video = [[TapVideo alloc] initWithDictionary:info];
    [self.view addSubview:video];
    toolbar = [[TapVideoToolbar alloc] init];
    [self.view addSubview:toolbar];
    toolbar.alpha = 0;
    tagsButton = [[TapButton alloc] initWithIcon:TapButtonIconFaTags];
    [tagsButton addTarget:self action:@selector(toggleTags) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tagsButton];
    tagsButton.alpha = 0;
    videoReady = NO;
    tagsView = [[UIScrollView alloc] init];
    [self.view addSubview:tagsView];
    if(info[@"fileInfo"][@"tags"] != nil) {
        for(NSDictionary* tag in info[@"fileInfo"][@"tags"][@"items"]) {
            TapView* view = [[TapView alloc] init];
            float r = [tag[@"color"][@"r"] floatValue];
            float g = [tag[@"color"][@"g"] floatValue];
            float b = [tag[@"color"][@"b"] floatValue];
            view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:0.8];
            UILabel* label1 = [[UILabel alloc] init];
            label1.font = [UIFont boldSystemFontOfSize:[[[TapSettings sharedInstance] number:TapSettingFontSize] intValue]];
            label1.textAlignment = NSTextAlignmentLeft;
            label1.textColor = [[TapSettings sharedInstance] color:TapSettingHeaderForegroundColor];
            label1.adjustsFontSizeToFitWidth = YES;
            label1.lineBreakMode = NSLineBreakByTruncatingTail;
            label1.frame = CGRectMake(10, 4, 166, 24);
            [view addSubview:label1];
            UILabel* label2 = [[UILabel alloc] init];
            label2.font = [UIFont systemFontOfSize:[[[TapSettings sharedInstance] number:TapSettingFontSize] intValue]];
            label2.textAlignment = NSTextAlignmentLeft;
            label2.textColor = [[TapSettings sharedInstance] color:TapSettingHeaderForegroundColor];
            label2.adjustsFontSizeToFitWidth = YES;
            label2.lineBreakMode = NSLineBreakByTruncatingTail;
            label2.frame = CGRectMake(10, 24-4, 166, 24);
            [view addSubview:label2];
            label1.text = tag[@"code"];
            label2.text = tag[@"text"];
            UIButton* btn = [[UIButton alloc] init];
            btn.frame = CGRectMake(0, 0, 186, 48);
            btn.tag = [tag[@"start"] floatValue]*100;
            [btn addTarget:self action:@selector(seekTo:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn];
           [tagsView addSubview:view];
            tagsVisible = NO;
            tagsView.alpha = 0;
        }
    }
    [self waitOn];
    [[NSNotificationCenter defaultCenter] addObserver:video selector:@selector(shareVideo:) name:TapShare object:toolbar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReady) name:TapVideoReady object:video];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [video close];
}

-(void)seekTo:(UIButton*)btn {
    [video seekTo:((float)btn.tag)/100];
    tagsVisible = NO;
    [self setupUiAnimated];
}

-(void)toggleTags {
    tagsVisible = !tagsVisible;
    [self setupUiAnimated];
}

-(void)videoReady {
    [self waitOff];
    videoReady = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    if(header.alpha == 1) {
        toolbar.alpha = 1;
        if(info[@"fileInfo"][@"tags"] != nil) {
            tagsButton.alpha = 1;
        }
        tagsView.alpha = tagsVisible;
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
    video.frame = CGRectMake(0, 0, size.width, size.height);
    toolbar.frame = CGRectMake(0, size.height-(hh*2+sh+safeAreaBottom), size.width, hh*2+sh+safeAreaBottom);
    tagsView.frame = CGRectMake(size.width-186-safeAreaRight, (hh+sh)+safeAreaTop, fmin(size.width/2, 186+safeAreaRight), size.height-safeAreaBottom-((hh+sh)+safeAreaTop)-hh*2);
    int bw = [[[TapSettings sharedInstance] number:TapSettingButtonWidth] intValue];
    int bh = [[[TapSettings sharedInstance] number:TapSettingButtonHeight] intValue];
    tagsButton.center = CGPointMake(size.width-bw/2-safeAreaRight, sh+bh/2+safeAreaTop);
    int y = 0;
    for(TapView* view in [tagsView subviews]) {
        if([view isKindOfClass:[TapView class]]) {
            view.frame = CGRectMake(0,y,tagsView.frame.size.width, 48);
            y+=48;
        }
    }
    tagsView.contentSize = CGSizeMake(tagsView.frame.size.width, y);
    tagsView.alpha = tagsVisible;
}

- (void)didSetupUi {
    [super didSetupUi];
    [self.view bringSubviewToFront:tagsButton];
}

-(void)toggleUi {
    [super toggleUi];
    if(videoReady) {
        toolbar.alpha = header.alpha;
        if(info[@"fileInfo"][@"tags"] != nil) {
            tagsButton.alpha = header.alpha;
        }
        if(tagsVisible) {
            tagsView.alpha = header.alpha;
        }
    }
}

@end

