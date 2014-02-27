//
//  NGGGameScene.m
//  NGGFirstGame
//
//  Created by Rento Usui on 2014/02/28.
//  Copyright (c) 2014年 Rento. All rights reserved.
//

#import "NGGGameScene.h"
#import "Constants.h"

@implementation NGGGameScene


- (void)addScore
{
    self.score ++;
    self.scoreLabel.text = [NSString stringWithFormat:@"%03d!",self.score];
}

- (void)jump
{
    NSLog(@"JUMP");
    self.player.physicsBody.velocity = CGVectorMake(0, kPlayerJumpPower);
}

- (void)resume {
    self.state = GAME_STATE_PLAYING;
}

- (void) pause {
    self.state = GAME_STATE_PAUSED;
}

- (void) gameOver {
    NSLog(@"GAME OVER");
    self.state = GAME_STATE_DEAD;
}

- (void) gameStart {
    NSLog(@"GAME START");
    self.state = GAME_STATE_PLAYING;
    self.player.physicsBody.dynamic = YES;
    [self removeStartLabel];
    [self jump];
}

- (void) removeStartLabel
{
    [[self childNodeWithName:kStartLabelName] removeFromParent];
}

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"HIT a%@ b%@",contact.bodyA.node.name,contact.bodyB.node.name);
    if ([contact.bodyA.node.name isEqualToString:kPlayerName] || [contact.bodyB.node.name isEqualToString:kPlayerName]) {
        [self gameOver];
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    
}


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.state = GAME_STATE_NONE;
        
        self.physicsWorld.contactDelegate = self;
        self.score = 0;
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:background];
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:self.player];
        self.player.name = kPlayerName;
        self.player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kPlayerRadius];
        self.player.physicsBody.contactTestBitMask = 1;
        self.player.physicsBody.allowsRotation = YES;
        self.player.physicsBody.dynamic = NO;
        self.player.physicsBody.mass = 0.001;
        
        SKSpriteNode *ground = [SKSpriteNode spriteNodeWithImageNamed:@"ground"];
        ground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(ground.frame));
        ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ground.frame.size];
        ground.physicsBody.dynamic = NO;
        ground.name = kGroundName;
        [self addChild:ground];
        ground.physicsBody.contactTestBitMask = 1;
        
        CGFloat paddingHight = 20;
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        self.scoreLabel.text = [NSString stringWithFormat:@"%03d!",self.score];
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - CGRectGetHeight(self.scoreLabel.frame) - paddingHight);
        [self addChild:self.scoreLabel];
        
        SKLabelNode* startLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        startLabel.text = @"タップでドン！";
        startLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        startLabel.name = kStartLabelName;
        [self addChild:startLabel];
        
        
        self.state = GAME_STATE_READY;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.state == GAME_STATE_READY) {
        [self gameStart];
    }
    if (self.state == GAME_STATE_PLAYING) {
        [self jump];
    }
    
    if (self.state == GAME_STATE_PAUSED) {
        [self resume];
    }
    
    if (self.state == GAME_STATE_DEAD) {
        [self jump];
    }

}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
