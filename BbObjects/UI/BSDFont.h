//
//  BSDFont.h
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import "BSDNumberInlet.h"
#import "BSDStringInlet.h"

@interface BSDFont : BSDObject

@property (nonatomic,strong)BSDNumberInlet *fontSizeInlet;
@property (nonatomic,strong)BSDStringInlet *fontNameInlet;

@end
