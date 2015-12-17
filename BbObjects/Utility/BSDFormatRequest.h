//
//  BSDFormatRequest.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/29/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDFormatRequest : BSDObject

@property (nonatomic,strong)BSDInlet *baseURLInlet;
@property (nonatomic,strong)BSDInlet *parametersInlet;

@end
