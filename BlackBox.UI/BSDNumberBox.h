//
//  BSDNumberBox.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDBox.h"

@interface BSDNumberBox : BSDBox <UITextFieldDelegate>

@property (nonatomic,strong)UITextField *textField;
@property (nonatomic,strong)UIStepper *stepper;

@end
