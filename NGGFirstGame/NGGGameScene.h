//
//  NGGGameScene.h
//  NGGFirstGame
//

//  Copyright (c) 2014年 Rento. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    GAME_STATE_NONE,
    GAME_STATE_READY,
    GAME_STATE_PLAYING,
    GAME_STATE_PAUSED,
    GAME_STATE_DEAD,
} GAME_STATE;

@interface NGGGameScene : SKScene < SKPhysicsContactDelegate >
{
    
}

@property (nonatomic, strong) SKSpriteNode *player;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic) NSInteger score;
@property (nonatomic) GAME_STATE state;

@end
