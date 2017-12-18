#import "TapController.h"
#import "TapScrollView.h"
#import "TapImageToolbar.h"

@interface TapGalleryController : TapController<UIScrollViewDelegate> {
    TapScrollView* container;
    int pageNumber;
    TapImageToolbar* toolbar;
}

@end
