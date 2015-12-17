//
//  BSDAbstractionBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDAbstractionBox.h"
#import "BSDCanvas.h"
@interface BSDAbstractionBox () <UITextFieldDelegate>


@end

@implementation BSDAbstractionBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textField = [[UITextField alloc]initWithFrame:self.bounds];
        _textField.placeholder = @"Abstraction";
        _textField.delegate = self;
        _textField.textColor = [UIColor whiteColor];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = [UIFont fontWithName:@"Courier-Bold" size:[UIFont systemFontSize]];
        _textField.tintColor = [UIColor colorWithWhite:0.7 alpha:1];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.enabled = NO;
        self.boxClassString = @"BSDAbstractionBox";
        self.className = @"BSDCanvas";
        [self insertSubview:_textField atIndex:0];
        kAllowEdit = NO;
    }
    
    return self;
}

- (void)initializeWithText:(NSString *)text
{
    if (text != nil) {
        self.argString = text;
    }
    
    if (self.object) {
        self.argString = text;
        NSArray *args = [text componentsSeparatedByString:@" "];
        self.textField.text = args.lastObject;
        [self createPortViewsForObject:self.object];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
