#import "TapView.h"
#import "TapButton.h"
#import "TapSlider.h"
#import "TapSliderWheel.h"

@interface TapVideoToolbar : TapView<TapSliderDelegate> {
    TapButton* btnPlay;
    TapButton* btnPause;
    TapSlider* playSlider;
    TapSliderWheel* rateSlider;
    UILabel* currentTimeLabel;
    UILabel* durationLabel;
    float durationInMilliseconds;
}

@end
