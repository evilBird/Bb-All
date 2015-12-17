//
//  NSMutableArray+MessageQueue.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MessageQueue)

- (BOOL)isEmpty;
- (NSArray *)placeholderIndices;
- (void)sendMessagesWithBlock:(void(^)(id message))block;

@end
