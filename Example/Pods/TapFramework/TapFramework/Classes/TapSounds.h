#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger, TapSound) {
    TapSoundAlert1 = 1,
    TapSoundAlert2,
    TapSoundAlert3,
    TapSoundAlert4,
    TapSoundAlert5,
    TapSoundButton1,
    TapSoundButton2,
    TapSoundButton3,
    TapSoundButton4,
    TapSoundButton5,
    TapSoundButton6,
    TapSoundButton7,
    TapSoundCancel1,
    TapSoundCancel2,
    TapSoundCollapse,
    TapSoundExpand,
    TapSoundError1,
    TapSoundError2,
    TapSoundError3,
    TapSoundError4,
    TapSoundError5,
    TapSoundComplete1,
    TapSoundComplete2,
    TapSoundComplete3,
    TapSoundSuccess1,
    TapSoundSuccess2,
    TapSoundSuccess3,
    TapSoundNotification1,
    TapSoundNotification2,
    TapSoundNotification3,
    TapSoundNotification4,
    TapSoundNotification5,
    TapSoundNotification6,
    TapSoundNotification7,
    TapSoundNotification8,
    TapSoundNotification9,
    TapSoundTab1,
    TapSoundTab2,
    TapSoundTab3,
};

@interface TapSounds : NSObject {
    AVAudioPlayer* player;
}

+ (id)sharedInstance;
- (void)play:(NSURL*)url;
- (void)play:(NSURL*)url volume:(float)volume;
- (void)playSound:(TapSound)sound;
- (void)playSound:(TapSound)sound volume:(float)volume;

@end
