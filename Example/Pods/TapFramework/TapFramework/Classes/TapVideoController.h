#import "TapController.h"
#import "TapVideo.h"
#import "TapVideoToolbar.h"

@interface TapVideoController : TapController {
    TapVideo* video;
    TapVideoToolbar* toolbar;
    TapButton* tagsButton;
    BOOL videoReady;
    UIScrollView* tagsView;
    BOOL tagsVisible;
}

@end

