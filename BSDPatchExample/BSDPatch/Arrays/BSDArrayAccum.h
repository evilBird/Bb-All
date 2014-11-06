//
//  BSDArrayAccum.h
//  BSDPatchExample
//
//  Created by Travis Henspeter on 8/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDArrayAccum : BSDObject

//Left inlet: emits accumulated array to main outlet when a bang is received
//Right inlet: accepts any value, which is added to the accumulated array. If it receives a bang, the accumulated array is cleared
//main outlet: emits accumulated array

- (instancetype)initWithMaxLength:(NSNumber *)maxLength;

@property(nonatomic,strong)NSMutableArray *accumulated;


@end
