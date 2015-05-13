//
//  BSDBezierPath.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDBezierPath : BSDObject

//Hot inlet: takes an NSArray containing NSValue instances which wrap CGPoints
//Cold inlet: takes an NSNumber. If value is non-zero, the output CGPath is closed, else it is not
//Main outlet: outputs an Instance of UIBezierPath

@end
