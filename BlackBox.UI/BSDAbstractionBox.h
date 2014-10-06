//
//  BSDAbstractionBox.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDGraphBox.h"

@class BSDCanvas;
@interface BSDAbstractionBox : BSDBox

@property (nonatomic,strong)UITextField *textField;
@property (nonatomic,strong)BSDCanvas *canvas;

@end
