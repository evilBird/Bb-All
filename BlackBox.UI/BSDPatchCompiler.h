//
//  BSDPatchCompiler.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/7/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDPatchCompiler : BSDObject

@property (nonatomic,strong)BSDInlet *stringInlet;
@property (nonatomic,strong)BSDInlet *canvasInlet;
@property (nonatomic,strong)BSDOutlet *canvasOutlet;
@property (nonatomic,strong)BSDOutlet *stringOutlet;

- (NSString *)testPatch1;

@end
