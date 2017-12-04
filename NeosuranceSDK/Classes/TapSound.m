#import "TapSound.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation TapSound

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

-(void)play:(NSURL*)url {
    SystemSoundID soundID;
    CFURLRef soundURL = (__bridge CFURLRef)url;
    AudioServicesCreateSystemSoundID(soundURL, &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, nil, nil, playSoundFinished, (__bridge void*) self);
    AudioServicesPlaySystemSound(soundID);
}

void playSoundFinished (SystemSoundID soundID, void *data) {
    AudioServicesRemoveSystemSoundCompletion(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
}

@end
