//
//  BSDFactory.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/26/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDFactory : BSDObject

@property (nonatomic,strong)BSDInlet *classNameInlet;
@property (nonatomic,strong)BSDInlet *selectorInlet;
@property (nonatomic,strong)BSDInlet *creationArgsInlet;

@end
