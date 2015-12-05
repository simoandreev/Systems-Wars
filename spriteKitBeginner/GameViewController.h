//
//  GameViewController.h
//  spriteKitBeginner
//

//  Copyright (c) 2015 Simeon Andreev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
@import AVFoundation;

@interface GameViewController : UIViewController
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@end
