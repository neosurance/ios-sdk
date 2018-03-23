#import "TapSounds.h"
#import "TapUtils.h"
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
        case TapSoundAlert1: url = [[TapUtils frameworkBundle] URLForResource:@"Alert1" withExtension:@"m4a"];
            break;
        case TapSoundAlert2: url = [[TapUtils frameworkBundle] URLForResource:@"Alert2" withExtension:@"m4a"];
            break;
        case TapSoundAlert3: url = [[TapUtils frameworkBundle] URLForResource:@"Alert3" withExtension:@"m4a"];
            break;
        case TapSoundAlert4: url = [[TapUtils frameworkBundle] URLForResource:@"Alert4" withExtension:@"m4a"];
            break;
        case TapSoundAlert5: url = [[TapUtils frameworkBundle] URLForResource:@"Alert1" withExtension:@"m4a"];
            break;
        case TapSoundButton1: url = [[TapUtils frameworkBundle] URLForResource:@"Button1" withExtension:@"m4a"];
            break;
        case TapSoundButton2: url = [[TapUtils frameworkBundle] URLForResource:@"Button2" withExtension:@"m4a"];
            break;
        case TapSoundButton3: url = [[TapUtils frameworkBundle] URLForResource:@"Button3" withExtension:@"m4a"];
            break;
        case TapSoundButton4: url = [[TapUtils frameworkBundle] URLForResource:@"Button4" withExtension:@"m4a"];
            break;
        case TapSoundButton5: url = [[TapUtils frameworkBundle] URLForResource:@"Button5" withExtension:@"m4a"];
            break;
        case TapSoundButton6: url = [[TapUtils frameworkBundle] URLForResource:@"Button6" withExtension:@"m4a"];
            break;
        case TapSoundButton7: url = [[TapUtils frameworkBundle] URLForResource:@"Button7" withExtension:@"m4a"];
            break;
        case TapSoundCancel1: url = [[TapUtils frameworkBundle] URLForResource:@"Cancel1" withExtension:@"m4a"];
            break;
        case TapSoundCancel2: url = [[TapUtils frameworkBundle] URLForResource:@"Cancel2" withExtension:@"m4a"];
            break;
        case TapSoundCollapse: url = [[TapUtils frameworkBundle] URLForResource:@"Collapse" withExtension:@"m4a"];
            break;
        case TapSoundExpand: url = [[TapUtils frameworkBundle] URLForResource:@"Expand" withExtension:@"m4a"];
            break;
        case TapSoundError1: url = [[TapUtils frameworkBundle] URLForResource:@"Error1" withExtension:@"m4a"];
            break;
        case TapSoundError2: url = [[TapUtils frameworkBundle] URLForResource:@"Error2" withExtension:@"m4a"];
            break;
        case TapSoundError3: url = [[TapUtils frameworkBundle] URLForResource:@"Error3" withExtension:@"m4a"];
            break;
        case TapSoundError4: url = [[TapUtils frameworkBundle] URLForResource:@"Error4" withExtension:@"m4a"];
            break;
        case TapSoundError5: url = [[TapUtils frameworkBundle] URLForResource:@"Error5" withExtension:@"m4a"];
            break;
        case TapSoundComplete1: url = [[TapUtils frameworkBundle] URLForResource:@"Complete1" withExtension:@"m4a"];
            break;
        case TapSoundComplete2: url = [[TapUtils frameworkBundle] URLForResource:@"Complete2" withExtension:@"m4a"];
            break;
        case TapSoundComplete3: url = [[TapUtils frameworkBundle] URLForResource:@"Complete3" withExtension:@"m4a"];
            break;
        case TapSoundSuccess1: url = [[TapUtils frameworkBundle] URLForResource:@"Success1" withExtension:@"m4a"];
            break;
        case TapSoundSuccess2: url = [[TapUtils frameworkBundle] URLForResource:@"Success2" withExtension:@"m4a"];
            break;
        case TapSoundSuccess3: url = [[TapUtils frameworkBundle] URLForResource:@"Success3" withExtension:@"m4a"];
            break;
        case TapSoundNotification1: url = [[TapUtils frameworkBundle] URLForResource:@"Notification1" withExtension:@"m4a"];
            break;
        case TapSoundNotification2: url = [[TapUtils frameworkBundle] URLForResource:@"Notification2" withExtension:@"m4a"];
            break;
        case TapSoundNotification3: url = [[TapUtils frameworkBundle] URLForResource:@"Notification3" withExtension:@"m4a"];
            break;
        case TapSoundNotification4: url = [[TapUtils frameworkBundle] URLForResource:@"Notification4" withExtension:@"m4a"];
            break;
        case TapSoundNotification5: url = [[TapUtils frameworkBundle] URLForResource:@"Notification5" withExtension:@"m4a"];
            break;
        case TapSoundNotification6: url = [[TapUtils frameworkBundle] URLForResource:@"Notification6" withExtension:@"m4a"];
            break;
        case TapSoundNotification7: url = [[TapUtils frameworkBundle] URLForResource:@"Notification7" withExtension:@"m4a"];
            break;
        case TapSoundNotification8: url = [[TapUtils frameworkBundle] URLForResource:@"Notification8" withExtension:@"m4a"];
            break;
        case TapSoundNotification9: url = [[TapUtils frameworkBundle] URLForResource:@"Notification9" withExtension:@"m4a"];
            break;
        case TapSoundTab1: url = [[TapUtils frameworkBundle] URLForResource:@"Tab1" withExtension:@"m4a"];
            break;
        case TapSoundTab2: url = [[TapUtils frameworkBundle] URLForResource:@"Tab2" withExtension:@"m4a"];
            break;
        case TapSoundTab3: url = [[TapUtils frameworkBundle] URLForResource:@"Tab3" withExtension:@"m4a"];
            break;
    }
    if(url != nil) {
        [self play:url volume:volume];
    }
}


@end
