//
//  BbObject2.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TargetAction)

- (void)addTarget:(id)target action:(SEL)action;

@end


@interface BbPort2 : NSObject

@property (nonatomic)    id      value;
@property (nonatomic)    BOOL    hot;

- (void)connectToPort:(BbPort2 *)port;
- (void)disconnectFromPort:(BbPort2 *)port;

@end

typedef void (^BbCalculateOutputBlock)(BbPort2 *hotInlet, BbPort2 *coldInlet, BbPort2 *mainOutlet);

@interface BbObject2 : NSObject

@property (nonatomic,strong)BbPort2 *hotInlet;
@property (nonatomic,strong)BbPort2 *coldInlet;
@property (nonatomic,strong)BbPort2 *mainOutlet;
@property (nonatomic,strong)BbCalculateOutputBlock calculateOutputBlock;

@end
