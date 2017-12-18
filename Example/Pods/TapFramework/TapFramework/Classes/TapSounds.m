#import "TapSounds.h"
#import "TapSettings.h"

@implementation TapSounds

+ (id)sharedInstance {
    static TapSounds *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)play:(NSURL*)url {
    [self play:url volume:1];
}

- (void)play:(NSURL*)url volume:(float)volume {
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player setVolume:volume];
    [player play];
}

- (void)playSound:(TapSound)sound {
    [self playSound:sound volume:[[[TapSettings sharedInstance] number:TapSettingEffectVolume] floatValue]];
}

- (void)playSound:(TapSound)sound volume:(float)volume {
    NSURL* url = nil;
    switch(sound) {
        case TapSoundAlert1: url = [[NSBundle mainBundle] URLForResource:@"Alert1" withExtension:@"m4a"];
            break;
        case TapSoundAlert2: url = [[NSBundle mainBundle] URLForResource:@"Alert2" withExtension:@"m4a"];
            break;
        case TapSoundAlert3: url = [[NSBundle mainBundle] URLForResource:@"Alert3" withExtension:@"m4a"];
            break;
        case TapSoundAlert4: url = [[NSBundle mainBundle] URLForResource:@"Alert4" withExtension:@"m4a"];
            break;
        case TapSoundAlert5: url = [[NSBundle mainBundle] URLForResource:@"Alert1" withExtension:@"m4a"];
            break;
        case TapSoundButton1: url = [[NSBundle mainBundle] URLForResource:@"Button1" withExtension:@"m4a"];
            break;
        case TapSoundButton2: url = [[NSBundle mainBundle] URLForResource:@"Button2" withExtension:@"m4a"];
            break;
        case TapSoundButton3: url = [[NSBundle mainBundle] URLForResource:@"Button3" withExtension:@"m4a"];
            break;
        case TapSoundButton4: url = [[NSBundle mainBundle] URLForResource:@"Button4" withExtension:@"m4a"];
            break;
        case TapSoundButton5: url = [[NSBundle mainBundle] URLForResource:@"Button5" withExtension:@"m4a"];
            break;
        case TapSoundButton6: url = [[NSBundle mainBundle] URLForResource:@"Button6" withExtension:@"m4a"];
            break;
        case TapSoundButton7: url = [[NSBundle mainBundle] URLForResource:@"Button7" withExtension:@"m4a"];
            break;
        case TapSoundCancel1: url = [[NSBundle mainBundle] URLForResource:@"Cancel1" withExtension:@"m4a"];
            break;
        case TapSoundCancel2: url = [[NSBundle mainBundle] URLForResource:@"Cancel2" withExtension:@"m4a"];
            break;
        case TapSoundCollapse: url = [[NSBundle mainBundle] URLForResource:@"Collapse" withExtension:@"m4a"];
            break;
        case TapSoundExpand: url = [[NSBundle mainBundle] URLForResource:@"Expand" withExtension:@"m4a"];
            break;
        case TapSoundError1: url = [[NSBundle mainBundle] URLForResource:@"Error1" withExtension:@"m4a"];
            break;
        case TapSoundError2: url = [[NSBundle mainBundle] URLForResource:@"Error2" withExtension:@"m4a"];
            break;
        case TapSoundError3: url = [[NSBundle mainBundle] URLForResource:@"Error3" withExtension:@"m4a"];
            break;
        case TapSoundError4: url = [[NSBundle mainBundle] URLForResource:@"Error4" withExtension:@"m4a"];
            break;
        case TapSoundError5: url = [[NSBundle mainBundle] URLForResource:@"Error5" withExtension:@"m4a"];
            break;
        case TapSoundComplete1: url = [[NSBundle mainBundle] URLForResource:@"Complete1" withExtension:@"m4a"];
            break;
        case TapSoundComplete2: url = [[NSBundle mainBundle] URLForResource:@"Complete2" withExtension:@"m4a"];
            break;
        case TapSoundComplete3: url = [[NSBundle mainBundle] URLForResource:@"Complete3" withExtension:@"m4a"];
            break;
        case TapSoundSuccess1: url = [[NSBundle mainBundle] URLForResource:@"Success1" withExtension:@"m4a"];
            break;
        case TapSoundSuccess2: url = [[NSBundle mainBundle] URLForResource:@"Success2" withExtension:@"m4a"];
            break;
        case TapSoundSuccess3: url = [[NSBundle mainBundle] URLForResource:@"Success3" withExtension:@"m4a"];
            break;
        case TapSoundNotification1: url = [[NSBundle mainBundle] URLForResource:@"Notification1" withExtension:@"m4a"];
            break;
        case TapSoundNotification2: url = [[NSBundle mainBundle] URLForResource:@"Notification2" withExtension:@"m4a"];
            break;
        case TapSoundNotification3: url = [[NSBundle mainBundle] URLForResource:@"Notification3" withExtension:@"m4a"];
            break;
        case TapSoundNotification4: url = [[NSBundle mainBundle] URLForResource:@"Notification4" withExtension:@"m4a"];
            break;
        case TapSoundNotification5: url = [[NSBundle mainBundle] URLForResource:@"Notification5" withExtension:@"m4a"];
            break;
        case TapSoundNotification6: url = [[NSBundle mainBundle] URLForResource:@"Notification6" withExtension:@"m4a"];
            break;
        case TapSoundNotification7: url = [[NSBundle mainBundle] URLForResource:@"Notification7" withExtension:@"m4a"];
            break;
        case TapSoundNotification8: url = [[NSBundle mainBundle] URLForResource:@"Notification8" withExtension:@"m4a"];
            break;
        case TapSoundNotification9: url = [[NSBundle mainBundle] URLForResource:@"Notification9" withExtension:@"m4a"];
            break;
        case TapSoundTab1: url = [[NSBundle mainBundle] URLForResource:@"Tab1" withExtension:@"m4a"];
            break;
        case TapSoundTab2: url = [[NSBundle mainBundle] URLForResource:@"Tab2" withExtension:@"m4a"];
            break;
        case TapSoundTab3: url = [[NSBundle mainBundle] URLForResource:@"Tab3" withExtension:@"m4a"];
            break;
    }
    if(url != nil) {
        [self play:url volume:volume];
    }
}


@end
