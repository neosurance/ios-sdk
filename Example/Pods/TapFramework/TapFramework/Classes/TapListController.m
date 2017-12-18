#import "TapListController.h"
#import "TapSettings.h"

@implementation TapListController

-(void)loadUi {
    [super loadUi];
    container = [[UIScrollView alloc] init];
    [self.view addSubview:container];
    [self setupItems];
}

-(void)setupItems {
    for(UIView* view in [container subviews]) {
        if([view isKindOfClass:[TapView class]]) {
            [view removeFromSuperview];
        }
    }
    for(NSDictionary* item in info[@"items"]) {
        TapView *listItem = [[NSClassFromString(item[@"class"]) alloc] initWithDictionary:item];
        listItem.frame = CGRectMake(0, 0, 0, [item[@"h"] intValue]);
        [container addSubview:listItem];
    }
 }

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
    int hh = [[[TapSettings sharedInstance] number:TapSettingHeaderHeight] intValue];
    container.frame = CGRectMake(0,sh,size.width,size.height-sh);
    int y = hh;
    for(TapView* view in [container subviews]) {
        if([view isKindOfClass:[TapView class]]) {
            view.frame = CGRectMake(0,y,size.width,view.frame.size.height);
            y += view.frame.size.height;
        }
    }
    container.contentSize = CGSizeMake(size.width, y);
}

-(void)setupUiAnimated {
    [super setupUiAnimated];
}

@end
