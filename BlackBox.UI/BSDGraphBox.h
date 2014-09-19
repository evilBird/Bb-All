//
//  BSDGraphBox.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDBox.h"

@class BSDCanvas;
@interface BSDGraphBox : BSDBox <UITextFieldDelegate>

+ (BSDGraphBox *)graphBoxWithFrame:(CGRect)frame className:(NSString *)className args:(id)args;
- (instancetype)initWithDescription:(BSDObjectDescription *)desc;

@property (nonatomic,strong)UITextField *textField;

@end
