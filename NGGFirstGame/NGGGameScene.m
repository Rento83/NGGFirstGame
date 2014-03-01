//
//  NGGGameScene.m
//  NGGFirstGame
//
//  Created by Rento Usui on 2014/02/28.
//  Copyright (c) 2014年 Rento. All rights reserved.
//

#import "NGGGameScene.h"
#import "Constants.h"
#import "NGGPoleNode.h"

@implementation NGGGameScene


//効果音はこんな感じでならせるよ！アクションのひとつだね！
#pragma mark - Sound effect
/*
- (void)playSoundEffect
{
    [self runAction:[SKAction playSoundFileNamed:@"ファイル名.caf" waitForCompletion:NO]];
}
 */

#pragma mark - score
- (void)reloadScoreLabel
{
    self.scoreLabel.text = [NSString stringWithFormat:@"すこあ %03d",self.score];
}

- (void)addScore
{
    self.score ++;
    [self reloadScoreLabel];
    NSLog(@"SCORE ADDED %d", self.score);
    
}

- (void) resetScore
{
    self.score = 0;
    [self reloadScoreLabel];
}

#pragma mark - Particle Effect

- (void) showDeadParticle
{
    //パーティクルは＜ー左ペインで右クリックしてNew File...っての押してリソースから作れるよ！
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"DeadParticle" ofType:@"sks"];
    SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    myParticle.particlePosition = CGPointMake(0, 0);
    myParticle.name = kDeadParticleName;
    //0.3秒後に消すよ！
    [myParticle runAction:[SKAction sequence:@[[SKAction waitForDuration:0.5],[SKAction removeFromParent]]]];
    [self.player addChild:myParticle];
}

#pragma mark - player control
- (void)changePlayerToNomarlTexture
{
    [self.player setTexture:[SKTexture textureWithImageNamed:@"player"]];
}

- (void)jump
{
    NSLog(@"JUMP");
    self.player.physicsBody.velocity = CGVectorMake(0, kPlayerJumpPower);
    [self.player setTexture:[SKTexture textureWithImageNamed:@"player1"]];
    [self.player runAction:[SKAction sequence:@[[SKAction waitForDuration:0.2], [SKAction performSelector:@selector(changePlayerToNomarlTexture) onTarget:self]]]];
}

- (void)changePlayerToDeadTexture
{
    [self.player setTexture:[SKTexture textureWithImageNamed:@"player2"]];
}

- (void)resetPlayer
{
    [self.player removeAllActions];
    [self changePlayerToNomarlTexture];
    self.player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self.player runAction:[SKAction rotateToAngle:DEGREES_TO_RADIANS(-10) duration:0]];
    self.player.physicsBody.velocity = CGVectorMake(0, 0);
}

#pragma mark - Timer
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    //poleの状態をチェックするよ
    [self poleCheck];
    
    //poleを作るよ
    [self genaratePoleWithCurrentTime:currentTime];
}

#pragma mark - pole control
- (void)genaratePoleWithCurrentTime:(CFTimeInterval)currentTime
{
    //一定間隔でpoleを作るよ！
    CFTimeInterval deltaTime = (currentTime - lastPoleGenerateTime);
    if (self.state == GAME_STATE_PLAYING && deltaTime > kPoleGenerateTime) {
        [self showNewPole];
        lastPoleGenerateTime = currentTime;
    }
}

- (void)poleCheck
{
    //スコアをチェック
    for (NGGPoleNode* pole in self.poles) {
        if ( NO == pole.scoreAdded && CGRectGetMaxX(pole.frame) < CGRectGetMinX(self.player.frame)) {
            [self addScore];
            pole.scoreAdded = YES;
        }
    }
    //ポールが画面外に出たら消すよ
    //self.polesをfor文で回しながら中身を消したりすると数が狂っておかしくなるから一旦コピーを作ってやるよ！
    //普通にコピーcopyするとMuable(可変可能)ではなくなるから気をつけて！mutableCopyで！
    NSMutableArray *poles = self.poles.mutableCopy;
    for (NGGPoleNode* pole in poles) {
        if (CGRectGetMaxX(pole.frame) < 0) {
            [self.poles removeObject:pole];
            [pole removeFromParent];
            
        }
    }
}

- (void)poleStartMove:(NGGPoleNode* )pole
{
    CGFloat moveXTo = 0 - pole.poleSize.width/2;
    SKAction* moveToLeftSide = [SKAction moveToX:moveXTo duration:kPoleMoveTime/2];
    [pole runAction:moveToLeftSide];
//    [pole runAction:[SKAction sequence:@[moveToLeftSide, makeNew]]];
}

- (void)stopPolesAction
{
    for (NGGPoleNode* pole in self.poles) {
        [pole removeAllActions];
    }
}

- (void) showNewPole
{
    
    CGFloat effectiveHight = kEffectiveHight;
    CGFloat centerY = arc4random() % 150;
    CGFloat groundHight =  CGRectGetHeight([self childNodeWithName:kGroundName].frame);
    CGFloat bottomPadding = 100;
    
    SKSpriteNode* topPole = [SKSpriteNode spriteNodeWithImageNamed:[self randomPoleImageName]];
    topPole.position = CGPointMake(0, groundHight + bottomPadding + centerY + effectiveHight/2 + CGRectGetHeight(topPole.frame)/2);
    topPole.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:topPole.frame.size];
    topPole.physicsBody.dynamic = NO;
    
    
    SKSpriteNode* bottomPole = [SKSpriteNode spriteNodeWithImageNamed:[self randomPoleImageName]];
    bottomPole.position = CGPointMake(0, groundHight + bottomPadding + centerY - effectiveHight/2 - CGRectGetHeight(bottomPole.frame)/2);
    bottomPole.zRotation = M_PI;
    bottomPole.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottomPole.frame.size];
    bottomPole.physicsBody.dynamic = NO;
    
    
    NGGPoleNode* pole = [NGGPoleNode node];
    
    pole.poleSize = CGSizeMake(CGRectGetWidth(topPole.frame), CGRectGetHeight(self.frame));
    pole.position = CGPointMake(CGRectGetWidth(self.frame)+pole.poleSize.width, 0);
    [self addChild:pole];
    [pole addChild:bottomPole];
    [pole addChild:topPole];
    
    [self poleStartMove:pole];
    [self.poles addObject:pole];
}

- (NSString*)randomPoleImageName
{
    NSInteger poleNumber = arc4random() % kNumberOfPoleTypes;
    NSString *poleName = [NSString stringWithFormat:@"pole%d",poleNumber];
    return poleName;
}

- (void)removeAllPoles
{
    for (NGGPoleNode* pole in self.poles) {
        [pole removeFromParent];
    }
    [self.poles removeAllObjects];
}

#pragma mark - Screen
- (void) shakeScreen
{
    NSTimeInterval time = 0.1;
    int times = (int)kGameOverTime / time;
    
    SKAction* firstMove = [SKAction moveByX:+5 y:0 duration:0];
    SKAction* moveLeft = [SKAction moveByX:-10 y:0 duration:time];
    SKAction* moveRight = [SKAction moveByX:+10 y:0 duration:time];
    SKAction* shake = [SKAction repeatAction:[SKAction sequence:@[moveLeft, moveRight]] count:times];
    SKAction* returnMove = [SKAction moveTo:self.position duration:0];
    [self runAction:[SKAction sequence:@[firstMove, shake, returnMove, [SKAction performSelector:@selector(gameOver) onTarget:self]]]];
}


#pragma mark - main game control

- (void)resume {
    self.state = GAME_STATE_PLAYING;
}

- (void) pause {
    self.state = GAME_STATE_PAUSED;
}

- (void) gameOver {
    NSLog(@"GAME OVER");
    if (self.state == GAME_STATE_DEAD) {
        self.state = GAME_STATE_GAMEOVER;
        [self showGameOverLabel];
    }
}

- (void) dead {
    if (self.state == GAME_STATE_PLAYING) {
        self.state = GAME_STATE_DEAD;
        NSLog(@"DEAD");
        [self changePlayerToDeadTexture];
        [self stopPolesAction];
        [self shakeScreen];
        
        [self showDeadParticle];
    }
}

- (void) gameStart {
    NSLog(@"GAME START");
    if (self.state == GAME_STATE_READY) {
        self.state = GAME_STATE_PLAYING;
        self.player.physicsBody.dynamic = YES;
        [self removeStartLabel];
        lastPoleGenerateTime = 0;
        [self jump];
        
    }
}

- (void)readyToStartGame {
    if (self.state == GAME_STATE_NONE || self.state == GAME_STATE_GAMEOVER) {
        self.state = GAME_STATE_READY;
        [self resetScore];
        [self removeAllPoles];
        [self removeGameOverLabel];
        [self showStartLabel];
        
        //playerを初期化
        [self resetPlayer];
    }
}

- (void) removeStartLabel
{
    SKNode *label = [self childNodeWithName:kStartLabelName];
    [label removeFromParent];
}

- (void)showStartLabel
{
    SKLabelNode* startLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    startLabel.text = @"タップでドン！";
    startLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    startLabel.name = kStartLabelName;
    [self addChild:startLabel];
}

- (void) removeGameOverLabel
{
    SKNode *label = [self childNodeWithName:kGameOverLabelName];
    [label removeFromParent];
}

- (void)showGameOverLabel
{
    SKLabelNode* gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    gameOverLabel.text = @"しぼー！タップ！";
    gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    gameOverLabel.name = kGameOverLabelName;
    [self addChild:gameOverLabel];
}

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if ([contact.bodyA.node.name isEqualToString:kPlayerName] || [contact.bodyB.node.name isEqualToString:kPlayerName]) {
        [self dead];
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    
}

#pragma mark - initialize

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        //色々初期化
        self.score = 0;
        self.state = GAME_STATE_NONE;
        self.poles = [NSMutableArray array];//@[].mutableCopy;でもできるお
        //物理空間でぶつかった時のデリゲートを自分にしたよ！
        self.physicsWorld.contactDelegate = self;
        //重力の強さだよ！単位はm/sec地球は{ 0.0, +/-9.8 }らしいよ！
        self.physicsWorld.gravity = CGVectorMake(0,-7);
        
        
        //バックグラウンドノードを作って真ん中に配置
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:background];
        
        //プレイヤーを作って真ん中に配置
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.name = kPlayerName;
        [self addChild:self.player];
        //角度つけるよ！他にやりかたが見つけられなかったからAction使うよ。ラジアンで指定っぽいよ！さっぱりだから度になおすよ！
        [self.player runAction:[SKAction rotateToAngle:DEGREES_TO_RADIANS(-10) duration:0]];
        //playerに物理挙動？をつけるよ！今回は○だからCircleの半径（Radius）を設定
        self.player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kPlayerRadius];
        //contactTestBitMaskを設定すると当たり判定がつくよ！衝突判定はcollisionBitMaskだよ！初期値はなしになてるよ
        self.player.physicsBody.contactTestBitMask = 1;
        //回転するよ！
        self.player.physicsBody.allowsRotation = YES;
        //ダイナミックをオフにして重力を無視してるよ
        self.player.physicsBody.dynamic = NO;
        //おもさを軽くしてる！基準値がよくわからない
        self.player.physicsBody.mass = 0.001;
        
        
        
        //地面を作るよ！
        SKSpriteNode *ground = [SKSpriteNode spriteNodeWithImageNamed:@"ground"];
        ground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(ground.frame));
        ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ground.frame.size];
        ground.physicsBody.dynamic = NO;
        ground.name = kGroundName;
        [self addChild:ground];
        //プレイヤーが当たったらダメだからこっちもセットするよ！
        ground.physicsBody.contactTestBitMask = 1;
        
        
        //スコアを表示するよ！
        CGFloat paddingHight = 50;
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - CGRectGetHeight(self.scoreLabel.frame) - paddingHight);
        [self addChild:self.scoreLabel];

        
        [self readyToStartGame];
        
        
    }
    return self;
}

#pragma mark - touch delegate
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
    
    if (self.state == GAME_STATE_GAMEOVER) {
        [self readyToStartGame];
    }

}



@end
