//
//  BbBlockMatrix.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSNumber* (^BbBlockMatrixEvaluator) (id input);

#import "BbMatrix.h"

@interface BbBlockMatrix : BbMatrix

@end
