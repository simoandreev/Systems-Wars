//
//  GameScene.h
//  spriteKitBeginner
//

//  Copyright (c) 2015 Simeon Andreev. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene<SKPhysicsContactDelegate>

@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int monstersDestroyed;
//@property (strong, nonatomic)SKSpriteNode *monster;

@end
