//
//  BSDGraphBox.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDBox.h"

@interface BSDGraphBox : BSDBox <UITextFieldDelegate>

@property (nonatomic,strong)UITextField *textField;

@end
