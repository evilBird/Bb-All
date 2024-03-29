//
//  BSDTouchGenerator.h
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDGenerator.h"

@interface BSDTouchGenerator : BSDGenerator

//BSDTouchGenerator: Generates touch events received by a view
//Hot inlet: takes a bang to poll the gesture recognizer
//Main outlet: emits an instance of a UIGestureRecogizer when hot inlet receives a bang
//Touches outlet: emits a dictionary describing the location and velocity of touches

@property (nonatomic,strong)BSDOutlet *touchesOutlet;

@end
