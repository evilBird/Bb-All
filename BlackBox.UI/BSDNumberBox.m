//
//  BSDNumberBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDNumberBox.h"
#import "BSDBang.h"

@implementation BSDNumberBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.className = @"BSDNumber";
        [self makeObjectInstance];
        _textField = [[UITextField alloc]initWithFrame:self.bounds];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.text = [NSString stringWithFormat:@"%@",@(0)];
        _textField.textColor = [UIColor whiteColor];
        _textField.delegate = self;
        _textField.tintColor = [UIColor whiteColor];
        _textField.text = @"0";
        _textField.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeDecimalPad;
        [self addSubview:_textField];
        [self setSelected:NO];
        NSArray *inletViews = [self inlets];
        self.inletViews = [NSMutableArray arrayWithArray:inletViews];
        NSArray *outletViews = [self outlets];
        self.outletViews = [NSMutableArray arrayWithArray:outletViews];
    }
    
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

- (void)handleLongPress:(id)sender
{
    if (sender == self.longPress) {
        [self.textField becomeFirstResponder];
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *text = nil;
    if (textField.text && textField.text.length > 0) {
        text = textField.text;
        [self setValueWithText:text];
    }else{
        [[self.object hotInlet]input:[BSDBang bang]];
    }
    
    [textField endEditing:YES];
    [textField resignFirstResponder];
}


- (void)setValueWithText:(NSString *)text
{
    if (!text) {
        return;
    }
    
    NSRange r = [text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    if (r.length > 0) {
        [[self.object hotInlet]input:[BSDBang bang]];
        return;
    }
    
    double value = [text floatValue];
    [[self.object hotInlet]input:@(value)];
}

- (void)resizeToFitText:(NSString *)messageText
{
    NSDictionary *attributes = @{NSFontAttributeName:self.textField.font};
    CGSize size = [messageText sizeWithAttributes:attributes];
    CGSize minSize = [self minimumSize];
    CGRect frame = self.frame;
    frame.size.width = size.width * 1.3;
    if (frame.size.width < minSize.width) {
        frame.size.width = minSize.width;
    }
    self.frame = frame;
    self.textField.frame = CGRectInset(self.bounds, size.width * 0.15, 0);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)handleObjectValueShouldChangeNotification:(NSNotification *)notification
{
    NSDictionary *changeInfo = notification.object;
    NSNumber *val = changeInfo[@"value"];
    if (val) {
        self.stepper.value = val.doubleValue;
        double diff = val.doubleValue - val.integerValue;
        if (diff == 0) {
            self.textField.text = [NSString stringWithFormat:@"%@",val];
        }else{
            self.textField.text = [NSString stringWithFormat:@"%.3f",val.doubleValue];
        }
        [self resizeToFitText:self.textField.text];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
