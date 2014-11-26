//
//  BSDCommentBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/30/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDCommentBox.h"

@implementation BSDCommentBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _textField = [[UITextField alloc]initWithFrame:self.bounds];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.text = [NSString stringWithFormat:@"%@",@(0)];
        _textField.textColor = [UIColor blackColor];
        _textField.delegate = self;
        _textField.tintColor = [UIColor blackColor];
        _textField.text = @"Comment";
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeDefault;
        self.defaultColor = [UIColor whiteColor];
        self.selectedColor = [UIColor colorWithWhite:1 alpha:1];
        self.currentColor = self.defaultColor;
        self.backgroundColor = self.currentColor;
        self.layer.borderColor = self.selectedColor.CGColor;
        [self addSubview:_textField];
        self.inletViews = nil;
        self.outletViews = nil;
        self.boxClassString = @"BSDCommentBox";
        self.className = @"BSDComment";
    }
    
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"comment"]) {
        textField.text = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text && textField.text.length > 0) {
        self.creationArguments = @[textField.text];
        [textField endEditing:YES];
        [textField resignFirstResponder];
        [self handleText:textField.text];
    }
}

- (void)handleText:(NSString *)text
{
    self.argString = text;
    NSArray *message = [NSArray arrayWithObject:self.argString];
    self.creationArguments = message;
    [self resizeToFitText:text];
    if (self.object == nil) {
        [self makeObjectInstanceArgs:self.creationArguments];
    }
    
    if (![self.textField.text isEqualToString:text]) {
        self.textField.text = text;
    }
}

- (void)resizeToFitText:(NSString *)messageText
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{NSFontAttributeName:self.textField.font,
                                 NSParagraphStyleAttributeName:style};
    CGSize size = [messageText sizeWithAttributes:attributes];
    CGRect frame = self.frame;
    frame.size = size;
    
    self.frame = CGRectInset(frame,-8,-8);

    self.textField.frame = CGRectInset(self.bounds, 8, 8);
    /*
    self.argString = messageText;
    NSArray *message = [NSArray arrayWithObject:self.argString];
    self.creationArguments = messageText;
     */
    
}

- (void)initializeWithText:(NSString *)text
{
    //[self makeObjectInstanceArgs:text];
    if (text) {
        [self handleText:text];
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
