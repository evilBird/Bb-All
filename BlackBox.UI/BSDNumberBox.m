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
        NSArray *inletViews = [self inlets];
        self.inletViews = [NSMutableArray arrayWithArray:inletViews];
        NSArray *outletViews = [self outlets];
        self.outletViews = [NSMutableArray arrayWithArray:outletViews];
        _stepper = [[UIStepper alloc]init];
        _stepper.tintColor = [UIColor whiteColor];
        _stepper.minimumValue = -1e10;
        _stepper.maximumValue = 1e10;
        CGRect frame = _stepper.frame;
        frame.origin.y = CGRectGetMaxY(self.bounds) - frame.size.height - 5;
        frame.origin.x = (CGRectGetWidth(self.bounds) - frame.size.width)/2 + 9;
        _stepper.frame = frame;
        [_stepper addTarget:self action:@selector(stepperValueDidChange:) forControlEvents:UIControlEventValueChanged];
        [self insertSubview:_stepper atIndex:0];
        [_stepper setBackgroundImage:self.emptyImageForStepper forState:UIControlStateNormal];
        [_stepper setBackgroundImage:self.emptyImageForStepper forState:UIControlStateHighlighted];

        _textField = [[UITextField alloc]initWithFrame:frame];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.text = [NSString stringWithFormat:@"%@",@(0)];
        _textField.textColor = self.backgroundColor;
        _textField.delegate = self;
        frame = _textField.frame;
        frame.origin.y -= frame.size.height + 10;
        _textField.frame = frame;
        [self addSubview:_textField];
        [self setSelected:NO];

    }
    
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *text = nil;
    if (textField.text) {
        text = textField.text;
    }else{
        text = @"0";
    }
    
    [textField endEditing:YES];
    [self setValueWithText:text];
}


- (void)setValueWithText:(NSString *)text
{
    self.textField.text = [NSString stringWithFormat:@"%@",@([text floatValue])];
    [[self.object hotInlet]input:@([text floatValue])];
    self.stepper.value = [text floatValue];
}

- (void)senderValueChanged:(id)value
{
}

- (void)stepperValueDidChange:(id)sender
{
    UIStepper *stepper = sender;
    [[self.object hotInlet]input:@(stepper.value)];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [_stepper setBackgroundImage:self.emptyImageForStepper forState:UIControlStateNormal];
    [_stepper setBackgroundImage:self.emptyImageForStepper forState:UIControlStateHighlighted];
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
        self.textField.text = [NSString stringWithFormat:@"%@",val];
    }
}

- (UIImage *)emptyImageForStepper
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor clearColor];
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
