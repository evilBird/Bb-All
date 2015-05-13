//
//  BSDType.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/22/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDType : BSDObject

@property (nonatomic,strong)BSDOutlet *numberOutlet;
@property (nonatomic,strong)BSDOutlet *stringOutlet;
@property (nonatomic,strong)BSDOutlet *arrayOutlet;
@property (nonatomic,strong)BSDOutlet *dictionaryOutlet;
@property (nonatomic,strong)BSDOutlet *otherTypeOutlet;

@end
