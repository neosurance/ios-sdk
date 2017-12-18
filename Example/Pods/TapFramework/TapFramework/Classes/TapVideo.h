#import "TapView.h"
#import "TapScrollView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface TapVideo : TapView<UIScrollViewDelegate> {
    TapScrollView* scrollView;
    UIView* container;
    AVPlayerLayer *playerLayer;
    AVPlayer *player;
    BOOL isPlaying;
    float rate;
    float downloadPercentage;
    NSURL* localUrl;
    NSObject* observer;
}

@property (nonatomic, copy) NSURL* localUrl;

@property BOOL isPlaying;
@property float rate;
@property float downloadPercentage;

-(void)shareVideo:(NSNotification*)notification;
-(void)playVideo;
-(void)pauseVideo;
-(void)close;
-(void)seekTo:(float)seconds;
-(float)timePercentage;
-(float)currentTimeInMillis;
-(float)durationInMillis;

@end
