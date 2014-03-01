//
//  NGGPoleNode.m
//  NGGFirstGame
//
//  Created by Rento Usui on 2014/02/28.
//  Copyright (c) 2014年 Rento. All rights reserved.
//

#import "NGGPoleNode.h"

@implementation NGGPoleNode

+ (id) node {
    return [[self alloc] init];
    
}

- (id) init {
    if (self = [super init]) {
        self.scoreAdded = NO;
    }
    return self;
}

@end
