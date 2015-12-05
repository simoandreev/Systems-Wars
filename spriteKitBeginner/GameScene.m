//
//  GameScene.m
//  spriteKitBeginner
//
//  Created by Simeon Andreev on 10/28/15.
//  Copyright (c) 2015 Simeon Andreev. All rights reserved.
//

#import "GameScene.h"
#import "GameViewController.h"
#import "GameOverScene.h"
#import "KAZ_JoystickNode.h"

@interface GameScene () {

    SKNode *control;
    SKSpriteNode *monster;
    SKSpriteNode *monster2;
    UITouch *joystickTouch;
    CGPoint touchPoint;
    CGSize move;
    
    KAZ_JoystickNode *moveJoystick;
    KAZ_JoystickNode *shootJoystick;
    CFTimeInterval lastUpdate;
    
    SKTexture* android1;
    SKAction* android;
    
    SKTexture* windows1;
    SKAction* windows;
    
    SKTexture* player1;
    SKAction* rotate1;
    
    SKLabelNode *score;
    int scorePoint;
}
@end

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t monster2Category        =  0x1 << 2;


//static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
//    return CGPointMake(a.x + b.x, a.y + b.y);
//}

//static inline CGPoint rwSub(CGPoint a, CGPoint b) {
//    return CGPointMake(a.x - b.x, a.y - b.y);
//}

//static inline CGPoint rwMult(CGPoint a, float b) {
//    return CGPointMake(a.x * b, a.y * b);
//}

//static inline float rwLength(CGPoint a) {
//    return sqrtf(a.x * a.x + a.y * a.y);
//}

// Makes a vector have a length of 1
//static inline CGPoint rwNormalize(CGPoint a) {
//    float length = rwLength(a);
//    return CGPointMake(a.x / length, a.y / length);
//}

@implementation GameScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        [self textures];
        
        SKSpriteNode *sn = [SKSpriteNode spriteNodeWithImageNamed:@"iPad-Retina-Wallpaper.png"];
        sn.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        sn.name = @"BACKGROUND";
        [sn setScale:0.5];
        [self addChild:sn];
        
        score = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        score.text =  [NSString stringWithFormat:@"Score :%d",scorePoint];
        score.fontSize = 20;
        score.fontColor = [SKColor greenColor];
        score.position = CGPointMake(60,self.frame.size.height-30);
        [self addChild:score];

        // 3
        self.backgroundColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];
        
        // 4
        self.player = [SKSpriteNode spriteNodeWithTexture:player1];
        //[self.player setScale:0.6];
        
        
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        [self addChild:self.player];
        [self.player runAction:rotate1];
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        //GameViewController.delegate=self;
        
        moveJoystick = [[KAZ_JoystickNode alloc] init];
        [moveJoystick setOuterControl:@"outer" withAlpha:0.25];
        [moveJoystick setInnerControl:@"inner" withAlpha:0.5];
        moveJoystick.movePoints = 8;
        [self addChild:moveJoystick];
        
        shootJoystick = [[KAZ_JoystickNode alloc] init];
        [shootJoystick setOuterControl:@"outer" withAlpha:0.25];
        [shootJoystick setInnerControl:@"inner" withAlpha:0.5];
        shootJoystick.defaultAngle = 0; // Default angle to report straight up for firing towards top
        [self addChild:shootJoystick];
        
    }
    return self;
}

- (void)addMonster {
    
    // Create sprite
    monster = [SKSpriteNode spriteNodeWithTexture:android1];
    //[self.monster setScale:0.6];
    [monster runAction:android];
   
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size]; // 1
    monster.physicsBody.dynamic = YES; // 2
    monster.physicsBody.categoryBitMask = monsterCategory; // 3
    monster.physicsBody.contactTestBitMask = projectileCategory; // 4
    monster.physicsBody.collisionBitMask = 0; // 5
    // Determine where to spawn the monster along the Y axis
    int minY = monster.size.height / 2;
    int maxY = self.frame.size.height - monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 4.0;
    int maxDuration = 8.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition: reveal];
        scorePoint = 0;
    }];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
    
}

- (void)addMonster2 {
    
    // Create sprite
    monster2 = [SKSpriteNode spriteNodeWithTexture:windows1];
    //[self.monster2 setScale:0.6];
    [monster2 runAction:windows];
    
    monster2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster2.size]; // 1
    monster2.physicsBody.dynamic = YES; // 2
    monster2.physicsBody.categoryBitMask = monster2Category; // 3
    monster2.physicsBody.contactTestBitMask = projectileCategory; // 4
    monster2.physicsBody.collisionBitMask = 0; // 5
    // Determine where to spawn the monster along the Y axis
    int minX = monster2.size.width / 2;
    int maxX = self.frame.size.width - monster2.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster2.position = CGPointMake(actualX,self.frame.size.height + monster2.size.height/2);
    [self addChild:monster2];
    
    // Determine speed of the monster
    int minDuration = 4.0;
    int maxDuration = 8.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, -monster2.size.height/2) duration:actualDuration];
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition: reveal];
        scorePoint = 0;
    }];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [monster2 runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
    
}
-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */

}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 2) {
        if (self.lastSpawnTimeInterval > 1) {
            self.lastSpawnTimeInterval = 0;
            [self addMonster];
        }
        self.lastSpawnTimeInterval = 0;
        [self addMonster2];
    }

}

-(void)update:(CFTimeInterval)currentTime {
        //NSLog(@"%f", currentTime);
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
//    int randNumber = (arc4random() % 50);
//    if(randNumber == 10){
//        [self addMonster];
//    }
//
//Joypad
    // Shoot bullets every half second
    if ( currentTime - lastUpdate >= 0.2 ){
        [self shootBullet];
        lastUpdate = currentTime;
    }
    
    if ( moveJoystick.isMoving ){
        CGPoint adjustedSpritePosition = CGPointMake(self.player.position.x + moveJoystick.moveSize.width, self.player.position.y + moveJoystick.moveSize.height);
        if ( adjustedSpritePosition.x < 0 ){
            adjustedSpritePosition.x = 0;
        } else if ( adjustedSpritePosition.x > self.size.width ){
            adjustedSpritePosition.x = self.size.width;
        }
        if ( adjustedSpritePosition.y < 0 ){
            adjustedSpritePosition.y = 0;
        } else if ( adjustedSpritePosition.y > self.size.height ){
            adjustedSpritePosition.y = self.size.height;
        }
        
        self.player.position = adjustedSpritePosition;
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
//    // 1 - Choose one of the touches to work with
//    UITouch * touch = [touches anyObject];
//    CGPoint location = [touch locationInNode:self];
//    
//    // 2 - Set up initial location of projectile
//    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
//    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
//    projectile.physicsBody.dynamic = YES;
//    projectile.physicsBody.categoryBitMask = projectileCategory;
//    projectile.physicsBody.contactTestBitMask = monsterCategory;
//    projectile.physicsBody.collisionBitMask = 0;
//    projectile.physicsBody.usesPreciseCollisionDetection = YES;
//
//    projectile.position = self.player.position;
//    
//    // 3- Determine offset of location to projectile
//    CGPoint offset = rwSub(location, projectile.position);
//    
//    // 4 - Bail out if you are shooting down or backwards
//    //if (offset.x <= 0) return;
//    
//    // 5 - OK to add now - we've double checked position
//    [self addChild:projectile];
//    
//    // 6 - Get the direction of where to shoot
//    CGPoint direction = rwNormalize(offset);
//    
//    // 7 - Make it shoot far enough to be guaranteed off screen
//    CGPoint shootAmount = rwMult(direction, 1000);
//    
//    // 8 - Add the shoot amount to the current position
//    CGPoint realDest = rwAdd(shootAmount, projectile.position);
//    
//    // 9 - Create the actions
//    float velocity = 900.0;
//    float realMoveDuration = self.size.width / velocity;
//    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
//    SKAction * actionMoveDone = [SKAction removeFromParent];
//    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    //Joypad
    for (UITouch *touch in touches) {
        if ( touch == moveJoystick.startTouch){
            [moveJoystick endControl];
        } else if ( touch == shootJoystick.startTouch){
            [shootJoystick endControl];
        }
    }
    
}

- (void)bullets:(SKSpriteNode *)bullet didCollideWithMonster:(SKSpriteNode *)monsters {
    [self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    self.monstersDestroyed++;
    if (self.monstersDestroyed >= 60) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES];
        [self.view presentScene:gameOverScene transition: reveal];
    }
    scorePoint++;
    score.text =  [NSString stringWithFormat:@"Score :%d",scorePoint];
    NSLog(@"Hit");
    [bullet removeFromParent];
    [monsters removeFromParent];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        ((secondBody.categoryBitMask & monsterCategory) | monster2Category) != 0)
    {
        [self bullets:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
}

////Joypad
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        // If the user touches the left side of the screen, use the move joystick
        if ( location.x < self.size.width / 2 ){
            [moveJoystick startControlFromTouch:touch andLocation:location];
        } else {
            [shootJoystick startControlFromTouch:touch andLocation:location];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    for (UITouch *touch in touches) {
        if ( touch == moveJoystick.startTouch){
            [moveJoystick moveControlToLocation:touch andLocation:[touch locationInNode:self]];
        } else if ( touch == shootJoystick.startTouch){
            [shootJoystick moveControlToLocation:touch andLocation:[touch locationInNode:self]];
        }
    }
}

-(CGPoint)destPointForAngle:(float)angle{
    float angleInRadians = angle * M_PI / 180;
    // Just makes for an easy calculation
    float distanceToOffScreen = 1000;
    // Calculate Y Movement
    float moveY = distanceToOffScreen * sinf(angleInRadians);
    // Calculate X Movement
    float moveX = sqrtf(( distanceToOffScreen * distanceToOffScreen ) - ( moveY * moveY ) );
    BOOL isLeft = ABS(shootJoystick.angle) > 90;
    if ( isLeft ){
        moveX *= -1;
    }
    return CGPointMake(moveX, moveY);
}

//-(void)adjustForBounds:(CGPoint)point{
//    if ( point.x < 0 ){
//        point.x = 0;
//    } else if ( point.x > self.size.width ){
//        point.x = self.size.width;
//    }
//    if ( point.y < 0 ){
//        point.y = 0;
//    } else if ( point.y > self.size.height ){
//        point.y = self.size.height;
//    }
//}

-(void)shootBullet{
    SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    bullet.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bullet.size.width/2];
    [bullet setScale:1.5];
    bullet.physicsBody.dynamic = YES;
    bullet.physicsBody.categoryBitMask = projectileCategory;
    bullet.physicsBody.contactTestBitMask = monsterCategory;
    bullet.physicsBody.contactTestBitMask = monster2Category;
    bullet.physicsBody.collisionBitMask = 0;
    bullet.physicsBody.usesPreciseCollisionDetection = YES;
    bullet.position = self.player.position;
    [self addChild:bullet];
    
    CGPoint movePoint = [self destPointForAngle:shootJoystick.angle];
    CGPoint adjustedPoint = CGPointMake(self.player.position.x + movePoint.x, self.player.position.y + movePoint.y);
    
    SKAction *moveAction = [SKAction moveTo:adjustedPoint duration:0.5];
    SKAction *removeAction = [SKAction removeFromParent];
    [bullet runAction:[SKAction sequence:@[moveAction, removeAction]]];
}

-(void)textures {
    //monster1 texture
    android1 = [SKTexture textureWithImageNamed:@"1.png"];
    
    SKTexture *f1 = [SKTexture textureWithImageNamed:@"1.png"];
    SKTexture *f2 = [SKTexture textureWithImageNamed:@"2.png"];
    SKTexture *f3 = [SKTexture textureWithImageNamed:@"3.png"];
    SKTexture *f4 = [SKTexture textureWithImageNamed:@"4.png"];
    SKTexture *f5 = [SKTexture textureWithImageNamed:@"5.png"];
    SKTexture *f6 = [SKTexture textureWithImageNamed:@"6.png"];
    SKTexture *f7 = [SKTexture textureWithImageNamed:@"7.png"];
    SKTexture *f8 = [SKTexture textureWithImageNamed:@"8.png"];
    SKTexture *f9 = [SKTexture textureWithImageNamed:@"9.png"];
    SKTexture *f10 = [SKTexture textureWithImageNamed:@"10.png"];
    SKTexture *f11 = [SKTexture textureWithImageNamed:@"11.png"];
    SKTexture *f12 = [SKTexture textureWithImageNamed:@"12.png"];
    SKTexture *f13 = [SKTexture textureWithImageNamed:@"13.png"];
    SKTexture *f14 = [SKTexture textureWithImageNamed:@"14.png"];
    SKTexture *f15 = [SKTexture textureWithImageNamed:@"15.png"];
    SKTexture *f16 = [SKTexture textureWithImageNamed:@"16.png"];
    SKTexture *f17 = [SKTexture textureWithImageNamed:@"17.png"];
    SKTexture *f18 = [SKTexture textureWithImageNamed:@"18.png"];
    SKTexture *f19 = [SKTexture textureWithImageNamed:@"19.png"];
    SKTexture *f20 = [SKTexture textureWithImageNamed:@"20.png"];
    SKTexture *f21 = [SKTexture textureWithImageNamed:@"21.png"];
    SKTexture *f22 = [SKTexture textureWithImageNamed:@"22.png"];
    SKTexture *f23 = [SKTexture textureWithImageNamed:@"23.png"];
    SKTexture *f24 = [SKTexture textureWithImageNamed:@"24.png"];
    SKTexture *f25 = [SKTexture textureWithImageNamed:@"25.png"];
    SKTexture *f26 = [SKTexture textureWithImageNamed:@"26.png"];
    SKTexture *f27 = [SKTexture textureWithImageNamed:@"27.png"];
    SKTexture *f28 = [SKTexture textureWithImageNamed:@"28.png"];
    SKTexture *f29 = [SKTexture textureWithImageNamed:@"29.png"];
    SKTexture *f30 = [SKTexture textureWithImageNamed:@"30.png"];
    
    android = [SKAction repeatActionForever:[SKAction animateWithTextures:@[f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16,f17,f18,f19,f20,f21,f22,f23,f24,f25,f26,f27,f28,f29,f30] timePerFrame:0.04]];
    //monster2 textures
    
    windows1 = [SKTexture textureWithImageNamed:@"win1.png"];
    
    SKTexture *win1 = [SKTexture textureWithImageNamed:@"win1.png"];
    SKTexture *win2 = [SKTexture textureWithImageNamed:@"win2.png"];
    SKTexture *win3 = [SKTexture textureWithImageNamed:@"win3.png"];
    SKTexture *win4 = [SKTexture textureWithImageNamed:@"win4.png"];
    SKTexture *win5 = [SKTexture textureWithImageNamed:@"win5.png"];
    SKTexture *win6 = [SKTexture textureWithImageNamed:@"win6.png"];
    SKTexture *win7 = [SKTexture textureWithImageNamed:@"win7.png"];
    SKTexture *win8 = [SKTexture textureWithImageNamed:@"win8.png"];
    SKTexture *win9 = [SKTexture textureWithImageNamed:@"win9.png"];
    SKTexture *win10 = [SKTexture textureWithImageNamed:@"win10.png"];
    SKTexture *win11 = [SKTexture textureWithImageNamed:@"win11.png"];
    SKTexture *win12 = [SKTexture textureWithImageNamed:@"win12.png"];
    SKTexture *win13 = [SKTexture textureWithImageNamed:@"win13.png"];
    SKTexture *win14 = [SKTexture textureWithImageNamed:@"win14.png"];
    SKTexture *win15 = [SKTexture textureWithImageNamed:@"win15.png"];
    SKTexture *win16 = [SKTexture textureWithImageNamed:@"win16.png"];
    SKTexture *win17 = [SKTexture textureWithImageNamed:@"win17.png"];
    SKTexture *win18 = [SKTexture textureWithImageNamed:@"win18.png"];
    SKTexture *win19 = [SKTexture textureWithImageNamed:@"win19.png"];
    SKTexture *win20 = [SKTexture textureWithImageNamed:@"win20.png"];
    
    windows = [SKAction repeatActionForever:[SKAction animateWithTextures:@[win1,win2,win3,win4,win5,win6,win7,win8,win9,win10,win11,win12,win13,win14,win15,win16,win17,win18,win19,win20] timePerFrame:0.04]];
    
    
    //player texture
    player1 = [SKTexture textureWithImageNamed:@"apple1.png"];
    
    SKTexture *p1 = [SKTexture textureWithImageNamed:@"apple1.png"];
    SKTexture *p2 = [SKTexture textureWithImageNamed:@"apple2.png"];
    SKTexture *p3 = [SKTexture textureWithImageNamed:@"apple3.png"];
    SKTexture *p4 = [SKTexture textureWithImageNamed:@"apple4.png"];
    SKTexture *p5 = [SKTexture textureWithImageNamed:@"apple5.png"];
    SKTexture *p6 = [SKTexture textureWithImageNamed:@"apple6.png"];
    SKTexture *p7 = [SKTexture textureWithImageNamed:@"apple7.png"];
    SKTexture *p8 = [SKTexture textureWithImageNamed:@"apple8.png"];
    SKTexture *p9 = [SKTexture textureWithImageNamed:@"apple9.png"];
    SKTexture *p10 = [SKTexture textureWithImageNamed:@"apple10.png"];
    SKTexture *p11 = [SKTexture textureWithImageNamed:@"apple11.png"];
    SKTexture *p12 = [SKTexture textureWithImageNamed:@"apple12.png"];
    SKTexture *p13 = [SKTexture textureWithImageNamed:@"apple13.png"];
    SKTexture *p14 = [SKTexture textureWithImageNamed:@"apple14.png"];
    SKTexture *p15 = [SKTexture textureWithImageNamed:@"apple15.png"];
    SKTexture *p16 = [SKTexture textureWithImageNamed:@"apple16.png"];
    SKTexture *p17 = [SKTexture textureWithImageNamed:@"apple17.png"];
    SKTexture *p18 = [SKTexture textureWithImageNamed:@"apple18.png"];
    SKTexture *p19 = [SKTexture textureWithImageNamed:@"apple19.png"];
    SKTexture *p20 = [SKTexture textureWithImageNamed:@"apple20.png"];
    SKTexture *p21 = [SKTexture textureWithImageNamed:@"apple21.png"];
    SKTexture *p22 = [SKTexture textureWithImageNamed:@"apple22.png"];
    SKTexture *p23 = [SKTexture textureWithImageNamed:@"apple23.png"];
    SKTexture *p24 = [SKTexture textureWithImageNamed:@"apple24.png"];
    SKTexture *p25 = [SKTexture textureWithImageNamed:@"apple25.png"];
    SKTexture *p26 = [SKTexture textureWithImageNamed:@"apple26.png"];
    SKTexture *p27 = [SKTexture textureWithImageNamed:@"apple27.png"];
    SKTexture *p28 = [SKTexture textureWithImageNamed:@"apple28.png"];
    SKTexture *p29 = [SKTexture textureWithImageNamed:@"apple29.png"];
    SKTexture *p30 = [SKTexture textureWithImageNamed:@"apple30.png"];
    
    rotate1 = [SKAction repeatActionForever:[SKAction animateWithTextures:@[p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30] timePerFrame:0.04]];
}
@end
