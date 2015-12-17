//
//  BSDPortConnection.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BSDPortView;
@interface BSDPortConnection : NSObject

- (instancetype)initWithOwner:(BSDPortView *)portView target:(BSDPortView *)target;
+ (BSDPortConnection *)connectionWithOwner:(BSDPortView *)owner target:(BSDPortView *)target;


@property (nonatomic,strong)BSDPortView *owner;
@property (nonatomic,strong)BSDPortView *target;


- (CGPoint)origin;
- (CGPoint)destination;

@end
