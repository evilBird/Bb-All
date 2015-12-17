//
//  BbMessage.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"

@protocol BbObjectDisplayDelegate <NSObject>

- (void)object:(id)sender didUpdate:(NSString *)updateToDisplay;

@end

@interface BbMessage : BbObject

@property (nonatomic) NSString  *messageBuffer;
@property (nonatomic,weak) id <BbObjectDisplayDelegate> displayDelegate;

- (void)setMessageBufferWithArgs:(id)args;
- (void)addCommaToMessageBuffer;
- (void)add2MessageBufferWithArgs:(id)args;


@end
