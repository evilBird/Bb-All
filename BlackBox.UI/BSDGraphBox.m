//
//  BSDGraphBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDGraphBox.h"
#import "BSDPatch.h"
#import "BSDPortView.h"
#import "BSDPortConnection.h"
#import <objc/runtime.h>


@interface BSDGraphBox () {
    
    BSDPortView *selectedPort;
    BOOL kAllowEdit;
}

@end

@implementation BSDGraphBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textField = [[UITextField alloc]initWithFrame:self.bounds];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.placeholder = @"Object";
        _textField.delegate = self;
        _textField.textColor = [UIColor whiteColor];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = [UIFont boldSystemFontOfSize:frame.size.height * 0.35];
        [self insertSubview:_textField atIndex:0];
        kAllowEdit = YES;
    }
    
    return self;
}

- (void)updatePortFrames
{
    self.frame = CGRectInset([self.superview convertRect:self.textField.frame fromView:self],
                             -5, -5);
    
    for (BSDPortView *inletView in self.inletViews) {
        CGRect bounds = self.bounds;
        CGRect frame;
        frame.size.width = bounds.size.width * 0.25;
        frame.size.height = bounds.size.height * 0.35;
        if ([inletView.portName isEqualToString:@"hot"]) {
            frame.origin = bounds.origin;
            inletView.frame = frame;
        }else if ([inletView.portName isEqualToString:@"cold"]){
            frame.origin.x = bounds.size.width - frame.size.width;
            frame.origin.y = 0;
            inletView.frame = frame;
        }
    }
    
    for (BSDPortView *outletView in self.outletViews) {
        
        CGRect bounds = self.bounds;
        CGRect frame;
        frame.size.width = bounds.size.width * 0.25;
        frame.size.height = bounds.size.height * 0.35;
        frame.origin.x = 0;
        frame.origin.y = bounds.size.height - frame.size.height;
        outletView.frame = frame;
    }
    
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.textField.backgroundColor = [UIColor clearColor];
    }else{
        self.textField.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return kAllowEdit;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.className = nil;
    self.selected = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField endEditing:YES];
    [textField resignFirstResponder];
    [textField.nextResponder becomeFirstResponder];
    [self handleText:textField.text];
}

- (void)handleText:(NSString *)text
{
    NSMutableArray *components = [[text componentsSeparatedByString:@" "]mutableCopy];
    NSString *name = nil;
    if (components) {
        name = components.firstObject;
        [components removeObject:name];
    }
    
    NSMutableArray *argsList = nil;
    if (components.count) {
        for (NSString *comp in components) {
            NSRange r = [comp rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
            if (r.length > 0) {
                NSNumber *arg = @(comp.floatValue);
                if (!argsList) {
                    argsList = [NSMutableArray array];
                }
                
                [argsList addObject:arg];
            }else{
                if (!argsList) {
                    argsList = [NSMutableArray array];
                }
                [argsList addObject:comp];
            }
        }
    }
    
    [self createObjectWithName:name arguments:argsList];
}

- (void)createObjectWithName:(NSString *)name arguments:(NSArray *)args
{
    self.className = name;
    [self makeObjectInstanceArgs:args];
    [self.textField setText:[self.object name]];
    NSArray *inletViews = [self inlets];
    self.inletViews = [NSMutableArray arrayWithArray:inletViews];
    NSArray *outletViews = [self outlets];
    self.outletViews = [NSMutableArray arrayWithArray:outletViews];
    kAllowEdit = NO;
}



@end
