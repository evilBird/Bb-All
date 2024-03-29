//
//  BbArraySplit
//  Bb
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbObject.h"

@interface BbArraySplit : BbObject

//BbArraySplit splits an array received by the hot inlet into two smaller arrays which are sent to separate outlets. The index at which the array is split is set by the cold inlet, e.g., setting the cold inlet to a value of 1 would cause an array with 4 elements to be split into an array of one element sent to the main outlet, and an array of 3 elements sent to the remainder outlet
@property (nonatomic,strong)BbOutlet *remainderOutlet;

@end
