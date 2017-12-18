#import "TapVideoToolbar.h"
#import "TapSettings.h"
#import "Tap.h"
#import "TapVideo.h"

@implementation TapVideoToolbar

//@synthesize btnShare;

-(void)loadUi {
    [super loadUi];
    UIColor* bgcolor = [[TapSettings sharedInstance] color:TapSettingHeaderBackgroundColor];
    bgcolor = [bgcolor colorWithAlphaComponent:[[[TapSettings sharedInstance] number:TapSettingHeaderOpacity] floatValue]];
    self.backgroundColor = bgcolor;
    if([[[TapSettings sharedInstance] number:TapSettingBlurred] boolValue]) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[[[TapSettings sharedInstance] number:TapSettingBlurEffectStyle] intValue]];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:blurEffectView];
    }
    btnPlay = [[TapButton alloc] initWithIcon:TapButtonIconPlay];
    [self addSubview:btnPlay];
    [btnPlay addTarget:self action:@selector(btnPlay) forControlEvents:UIControlEventTouchUpInside];
    btnPause = [[TapButton alloc] initWithIcon:TapButtonIconPause];
    [self addSubview:btnPause];
    [btnPause addTarget:self action:@selector(btnPause) forControlEvents:UIControlEventTouchUpInside];
    playSlider = [[TapSlider alloc] init];
    playSlider.delegate = self;
    [self addSubview:playSlider];
    rateSlider = [[TapSliderWheel alloc] init];
    rateSlider.delegate = self;
    [self addSubview:rateSlider];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReady:) name:TapVideoReady object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupButtons:) name:TapVideoChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTime:) name:TapVideoTimeChanged object:nil];
    durationLabel = [[UILabel alloc] init];
    durationLabel.font = [UIFont boldSystemFontOfSize:10];
    durationLabel.textAlignment = NSTextAlignmentCenter;
    durationLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self addSubview:durationLabel];
    currentTimeLabel = [[UILabel alloc] init];
    currentTimeLabel.font = [UIFont boldSystemFontOfSize:10];
    currentTimeLabel.textAlignment = NSTextAlignmentLeft;
    currentTimeLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self addSubview:currentTimeLabel];
    btnPause.alpha = btnPlay.alpha = 0;
}

- (void)onTapMove:(TapSlider*)slider {
    if(slider == playSlider) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoPlaySliderChanged object:slider];
        [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoPause object:slider];
    }
    if(slider == rateSlider) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoRateSliderChanged object:slider];
   }
}

- (void)onTapDown:(TapSlider*)slider {
    if(slider == rateSlider) {
    }
}

- (void)onTapUp:(TapSlider*)slider {
    if(slider == rateSlider) {
        rateSlider.value = 0.5;
        [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoRateSliderChanged object:slider];
        [rateSlider setupUiAnimated];
   }
}

-(void)shareVideo {
    [[NSNotificationCenter defaultCenter] postNotificationName:TapShare object:self];
}

-(void)btnPlay {
    [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoPlay object:self];
}

-(void)btnPause {
    [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoPause object:self];
}

-(void)btnForward {
    [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoFastForward object:self];
}

-(void)btnBackward {
    [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoFastBackward object:self];
}

-(void)setupButtons:(NSNotification*)notification {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    TapVideo* video = notification.object;
    if(video.isPlaying) {
        btnPause.alpha = 1;
        btnPlay.alpha = 0;
    } else {
        btnPause.alpha = 0;
        btnPlay.alpha = 1;
    }
    [UIView commitAnimations];
}

-(void)setupTime:(NSNotification*)notification {
    if(durationInMilliseconds != 0) {
        CMTime time = [notification.object CMTimeValue];
        float milliseconds = (1000*time.value/time.timescale);
        [playSlider setValue:milliseconds/durationInMilliseconds];
        [playSlider needsSetupUi];
        NSString* timeAsString = [NSString stringWithFormat:@"%01d:%02d:%02d", ((int)(milliseconds/(60000*60)))%60,((int)(milliseconds/(60000)))%60,((int)(milliseconds/1000))%60];
        currentTimeLabel.text = timeAsString;
        [self needsSetupUi];
    }
}

-(void)videoReady:(NSNotification*)notification {
    TapVideo* video = notification.object;
    float milliseconds = durationInMilliseconds = [video durationInMillis];
    NSString* timeAsString = [NSString stringWithFormat:@"%01d:%02d:%02d", ((int)(milliseconds/(60000*60)))%60,((int)(milliseconds/(60000)))%60,((int)(milliseconds/1000))%60];
    durationLabel.text = timeAsString;
    currentTimeLabel.text = @"0:00:00";
    [self needsSetupUi];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    float safeAreaLeft = 0;
    float safeAreaRight = 0;
    float safeAreaTop = 0;
    float safeAreaBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaRight = [self superview].safeAreaInsets.right;
        safeAreaLeft = [self superview].safeAreaInsets.left;
        safeAreaTop = [self superview].safeAreaInsets.top;
        safeAreaBottom = [self superview].safeAreaInsets.bottom;
    }
    int hh = [[[TapSettings sharedInstance] number:TapSettingHeaderHeight] intValue];
    int bw = [[[TapSettings sharedInstance] number:TapSettingButtonWidth] intValue];
    btnPlay.center = CGPointMake(safeAreaRight+btnPlay.frame.size.width/2+16, btnPlay.center.y);
    btnPause.center = CGPointMake(safeAreaRight+btnPause.frame.size.width/2+16, btnPause.center.y);
    playSlider.frame = CGRectMake(safeAreaRight+btnPlay.frame.size.width+16,0,size.width-safeAreaRight-safeAreaLeft-btnPlay.frame.size.width*2-32,bw);
    rateSlider.frame = CGRectMake(safeAreaRight+btnPlay.frame.size.width+16,hh,size.width-safeAreaRight-safeAreaLeft-btnPlay.frame.size.width*2-32,bw);
    durationLabel.frame = CGRectMake(size.width-btnPlay.frame.size.width-safeAreaRight-32,0,btnPlay.frame.size.width+32,bw);
    if([playSlider value] < 0.5) {
        currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        currentTimeLabel.frame = CGRectMake(playSlider.frame.origin.x+20+[playSlider value]*playSlider.frame.size.width,0,btnPlay.frame.size.width+32,bw);
    } else {
        currentTimeLabel.textAlignment = NSTextAlignmentRight;
        currentTimeLabel.frame = CGRectMake(playSlider.frame.origin.x-20+[playSlider value]*playSlider.frame.size.width-(btnPlay.frame.size.width+32),0,btnPlay.frame.size.width+32,bw);
    }
}

@end
