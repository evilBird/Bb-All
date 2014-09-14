//
//  BSDPortConnectionDescription.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSDInlet.h"
#import "BSDPortView.h"

@interface BSDPortConnectionDescription : NSObject

@property (nonatomic,strong)NSString *senderParentId;
@property (nonatomic,strong)NSString *senderPortName;
@property (nonatomic,strong)NSString *receiverParentId;
@property (nonatomic,strong)NSString *receiverPortName;
@property (nonatomic,strong)BSDPortView *receiverPortView;

@end
