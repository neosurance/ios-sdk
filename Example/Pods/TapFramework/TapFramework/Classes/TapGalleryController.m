#import "TapGalleryController.h"
#import "Tap.h"
#import "TapSettings.h"
#import "TapGalleryPage.h"

@implementation TapGalleryController

- (id)init {
    if (self = [super init]) {
        pageNumber = 1;
    }
    return self;
}

-(void)loadUi {
    [super loadUi];
    container = [[TapScrollView alloc] init];
    container.backgroundColor = [UIColor blackColor];
    [self.view addSubview:container];
    container.pagingEnabled = YES;
    toolbar = [[TapImageToolbar alloc] init];
    [self.view addSubview:toolbar];
    int n = 1;
    for(NSDictionary* image in info[@"images"]) {
        TapGalleryPage* galleryPage = [[TapGalleryPage alloc] initWithDictionary:image];
        [[NSNotificationCenter defaultCenter] addObserver:galleryPage selector:@selector(shareImage:) name:TapShare object:toolbar];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReady) name:TapImageReady object:galleryPage];
        galleryPage.tag = n;
        [container addSubview:galleryPage];
        n++;
    }
     [self.view bringSubviewToFront:header];
}

-(void)imageReady {
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    container.delegate = nil;
    int x = 0;
    for(TapGalleryPage* galleryPage in [container subviews]) {
        if([galleryPage isKindOfClass:[TapGalleryPage class]]) {
            galleryPage.frame = CGRectMake(x, 0, size.width, size.height);
            x += size.width;
        }
    }
    container.contentSize = CGSizeMake([info[@"images"] count]*size.width, size.height);
    container.contentOffset = CGPointMake((pageNumber-1)*size.width, 0);
    container.frame = CGRectMake(0, 0, size.width, size.height);
    container.delegate = self;
    [self setupPages];
    int hh = [[[TapSettings sharedInstance] number:TapSettingHeaderHeight] intValue];
    int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
    toolbar.frame = CGRectMake(0, size.height-(hh+sh), size.width, hh+sh);
}

-(void)toggleUi {
    [super toggleUi];
    toolbar.alpha = header.alpha;
}

-(void)safeSetupPages {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(setupPages) withObject:nil afterDelay:0.25];
}

-(void)setupPages {
    for(TapGalleryPage* galleryPage in [container subviews]) {
        if([galleryPage isKindOfClass:[TapGalleryPage class]]) {
            if(abs((int)galleryPage.tag-(int)pageNumber) < 2) {
                [galleryPage pageOn:(galleryPage.tag == pageNumber)];
            } else {
                [galleryPage pageOff];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGSize size = scrollView.frame.size;
    int n = (scrollView.contentOffset.x+(size.width)/2)/size.width+1;
    if(n != pageNumber) {
        pageNumber = n;
    }
    [self safeSetupPages];
}

@end

