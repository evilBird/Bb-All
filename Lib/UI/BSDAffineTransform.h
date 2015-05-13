//
//  BSDAffineTransform.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/26/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import "BSDNumberInlet.h"

@interface BSDAffineTransform : BSDObject

@property (nonatomic,strong)BSDNumberInlet *a;
@property (nonatomic,strong)BSDNumberInlet *b;
@property (nonatomic,strong)BSDNumberInlet *c;
@property (nonatomic,strong)BSDNumberInlet *d;
@property (nonatomic,strong)BSDNumberInlet *tx;
@property (nonatomic,strong)BSDNumberInlet *ty;

@end
