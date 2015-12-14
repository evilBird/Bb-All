//
//  BSDPointer.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/11/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDInstanceMethod : BSDObject
// hot inlet: takes a bang, performs selector with cold inlet value
// cold inlet: takes a point to any object
// selector inlet: takes a selector as NSString
// arguments inlet: takes an array of args passed to selector in order of input
// mainoutlet: outputs the return value of the selector, if non-void, else outputs a bang
@property (nonatomic,strong)BSDInlet *selectorInlet;
@property (nonatomic,strong)BSDInlet *argumentsInlet;

@end
