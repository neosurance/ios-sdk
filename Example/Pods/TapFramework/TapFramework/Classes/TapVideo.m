#import "TapVideo.h"
#import "TapVideoToolbar.h"
#import "TapVideoController.h"
#import "Tap.h"
#import "TapData.h"
#import "TapSettings.h"

@implementation TapVideo

@synthesize isPlaying, rate, localUrl, downloadPercentage;

-(void)loadUi {
    [super loadUi];
    scrollView = [[TapScrollView alloc] init];
    scrollView.delegate = self;
    [self addSubview:scrollView];
    scrollView.maximumZoomScale = 4;
    container = [[UIView alloc] init];
    [scrollView addSubview:container];
    localUrl = nil;
    downloadPercentage = 0;
    NSURL* url  = [[TapData sharedInstance] localFileUrl:info[@"url"]];
    if(url != nil) {
        self.localUrl = url;
        player = [AVPlayer playerWithURL:self.localUrl];
    } else {
        player = [AVPlayer playerWithURL:info[@"url"]];
    }
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [container.layer addSublayer:playerLayer];
    container.alpha = 0.001;
    [player addObserver:self forKeyPath:@"status" options:0 context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideo) name:TapVideoPlay object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVideo) name:TapVideoPause object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fastForward) name:TapVideoFastForward object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fastBackward) name:TapVideoFastBackward object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFile) name:TapVideoDownload object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileError:) name:TapDataFileError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileReady:) name:TapDataFileReady object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileChanged:) name:TapDataFileChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seekFromSlider:) name:TapVideoPlaySliderChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rateFromSlider:) name:TapVideoRateSliderChanged object:nil];
    isPlaying = NO;
    rate = 1.0f;
}

-(void)close {
    [player removeTimeObserver:observer];
}

-(void)downloadFile {
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    if(info[@"tags"] != nil) {
        [data setObject:info[@"tags"] forKey:@"tags"];
    }
    [[TapData sharedInstance] downloadFile:info[TapDataUrlKey] extension:info[TapDataExtensionKey] type:info[TapDataTypeKey] title:info[TapDataTitleKey] info:data];
}

-(void)fileError:(NSNotification*)notification {
}

-(void)fileChanged:(NSNotification*)notification {
    NSDictionary* file = notification.object;
    NSString* urlAsString = [NSString stringWithFormat:@"%@", info[TapDataUrlKey]];
    NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[TapDataUrlKey]];
    if([urlAsString compare:fileUrlAsString] == NSOrderedSame) {
        float percentage = [file[TapDataPercentageKey] floatValue];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:percentage] waitUntilDone:YES];
    }
}

-(void)fileReady:(NSNotification*)notification {
    NSDictionary* file = notification.object;
    NSString* urlAsString = [NSString stringWithFormat:@"%@", info[TapDataUrlKey]];
    NSString* fileUrlAsString = [NSString stringWithFormat:@"%@", file[TapDataUrlKey]];
    if([urlAsString compare:fileUrlAsString] == NSOrderedSame) {
        downloadPercentage = 0;
        NSURL* url = [[TapData sharedInstance] localFileUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@", info[@"url"]]]];
        if(url != nil) {
            [[Tap sharedInstance] pop:NO];
            TapVideoController* controller = [[TapVideoController alloc] init];
            controller.info = info;
            [[Tap sharedInstance] push:controller animated:NO];
        }
    }
}

-(void)updateProgress:(NSNumber*)percentage {
    downloadPercentage = [percentage floatValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoChanged object:self];
}

-(float)timePercentage {
    CMTime time = [player currentTime];
    CMTime duration = player.currentItem.duration;
    float milliseconds = (1000*time.value/time.timescale);
    float durationInMilliseconds = (1000*duration.value/duration.timescale);
    return milliseconds/durationInMilliseconds;
}

-(float)currentTimeInMillis {
    CMTime time = [player currentTime];
    float milliseconds = (1000*time.value/time.timescale);
    return milliseconds;
}

-(float)durationInMillis {
    CMTime duration = player.currentItem.duration;
    float durationInMilliseconds = (1000*duration.value/duration.timescale);
    return durationInMilliseconds;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == player && [keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay) {
            [self performSelector:@selector(checkReadyToPlay) withObject:nil afterDelay:0];
        } else if (player.status == AVPlayerStatusFailed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoFailed object:self];
        }
    }
}

-(void)checkReadyToPlay {
    NSLog(@"---- checkReadyToPlay");
    if([self durationInMillis] > 0) {
        [player prerollAtRate:1 completionHandler:^(BOOL finished) {
            [self performSelector:@selector(showVideo) withObject:nil afterDelay:0];
       }];
     } else {
        [self performSelector:@selector(checkReadyToPlay) withObject:nil afterDelay:0.1f];
    }
}

-(void)showVideo {
    [self playVideo];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    container.alpha = 1;
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoReady object:self];
    double interval = .1f;
    observer = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime _time) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoTimeChanged object:[NSValue valueWithCMTime:_time]];
    }];
}

-(void)fastForward {
    rate += 0.5f;
    if(rate > 2) {
        rate = 0.5f;
    }
    if(rate != 0) {
        [player play];
        isPlaying = YES;
    } else {
        [player pause];
        isPlaying = NO;
    }
    player.rate = rate;
    [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoChanged object:self];
}

-(void)fastBackward {
    rate -= 0.5f;
    if(rate < -2) {
        rate = -0.5f;
    }
    if(rate != 0) {
        [player play];
        isPlaying = YES;
    } else {
        [player pause];
        isPlaying = NO;
    }
    player.rate = rate;
    [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoChanged object:self];
}

-(void)playVideo {
    rate = 1.0f;
    [player playImmediatelyAtRate:1];
    isPlaying = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoChanged object:self];
}

-(void)seekTo:(float)seconds {
    CMTime duration = player.currentItem.duration;
    [player.currentItem seekToTime:CMTimeMake(seconds*duration.timescale, duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)seekFromSlider:(NSNotification*)notification {
    TapSlider* slider = notification.object;
    [self seekToPercentage:slider.value];
}

-(void)rateFromSlider:(NSNotification*)notification {
    TapSlider* slider = notification.object;
    float value = (1+(slider.value-0.5));
    if(value < 1) {
        value = (1-value)*-4;
    }
    if(value > 1) {
        value *= 1.5;
        value = value*2/2.25;
    }
    player.rate = value;
    NSLog(@"%f", value);
}

-(void)seekToPercentage:(float)percentage {
    CMTime duration = player.currentItem.duration;
    [player.currentItem seekToTime:CMTimeMake(percentage*duration.value, duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)pauseVideo {
    rate = 1.0f;
    player.rate = rate;
    [player pause];
    isPlaying = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:TapVideoChanged object:self];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return container;
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    container.frame = CGRectMake(0,0,size.width,size.height);
    scrollView.frame = CGRectMake(0,0,size.width,size.height);
    scrollView.zoomScale = 1;
    [playerLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
}

-(void)shareVideo:(NSNotification*)notification {
//    TapVideoToolbar* toolbar = notification.object;
//    if([toolbar isKindOfClass:[TapVideoToolbar class]]) {
//        [[Tap sharedInstance] share:@[ localUrl] sender:toolbar.btnShare];
//    }
}

@end
