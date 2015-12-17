//
//  BSDExpression.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDExpression : BSDObject

@property (nonatomic,strong)BSDInlet *argsInlet;
@property (nonatomic,strong)BSDInlet *contextInlet;

@end
