//
//  Constants.h
//  OurFirstGameIn755
//
//  Created by Rento Usui on 2014/02/28.
//  Copyright (c) 2014年 Rento. All rights reserved.
//

#ifndef OurFirstGameIn755_Constants_h
#define OurFirstGameIn755_Constants_h

//1秒間を60フレームで割った秒数でタイマーを呼び続けるよ
#define kMainTimerInterval (1 / 60)

//あたり判定用。球の半径だよ！あたり判定に使うから実際と違ってもいいよ！
#define kPlayerRadius 33.0f
#define kPlayerJumpPower 500.0

#define kPlayerName @"player"
#define kGroundName @"ground"
#define kPoleName @"pole"
#define kStartLabelName @"startlabel"

//4インチスクリーンと3.5インチスクリーンの差をだしてるよ
//ジャンプした時に3.5インチスクリーン以上とべなくするよ
#define kiPhone4inchScreenHight 568
#define kiPhone3hScreenHight 480
#define kiPhone5ScreenHightDelta (kiPhone4inchScreenHight -  kiPhone3hScreenHight)




#endif
