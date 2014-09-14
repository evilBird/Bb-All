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

- (NSArray *)inlets
{
    CGRect bounds = self.bounds;
    CGRect frame;
    frame.origin = bounds.origin;
    frame.size.width = bounds.size.width * 0.25;
    frame.size.height = bounds.size.height * 0.25;
    BSDPortView *hotInletView = [[BSDPortView alloc]initWithName:@"hot" delegate:self];
    hotInletView.frame = frame;
    [self addSubview:hotInletView];
    BSDPortView *coldInletView = [[BSDPortView alloc]initWithName:@"cold" delegate:self];
    frame.origin.x = bounds.size.width - frame.size.width;
    coldInletView.frame = frame;
    [self addSubview:coldInletView];
    return @[hotInletView,coldInletView];
}

- (NSArray *)outlets
{
    CGRect bounds = self.bounds;
    CGRect frame;
    frame.origin = bounds.origin;
    frame.size.width = bounds.size.width * 0.25;
    frame.size.height = bounds.size.height * 0.25;
    BSDPortView *mainOutletView = [[BSDPortView alloc]initWithName:@"main" delegate:self];
    frame.origin.x = 0;
    frame.origin.y = bounds.size.height - frame.size.height;
    mainOutletView.frame = frame;
    [self addSubview:mainOutletView];
    return @[mainOutletView];
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
    /*
    CGRect f = self.textField.frame;
    CGRect frame = [self.inletViews.firstObject frame];
    f.origin.x += frame.size.width;
    self.textField.frame = frame;
     */

    
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
    self.selected = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField endEditing:YES];
    [textField resignFirstResponder];
    [textField.nextResponder becomeFirstResponder];
    [self handleText:textField.text];
    //UITextField *t = [[UITextField alloc]initWithFrame:textField];
    //t.frame = textField.frame;
    //t.text = textField.text;
    //[t sizeToFit];
    //CGRect frame = textField.frame;
    //frame.size.width = t.frame.size.width;
    //[textField sizeToFit];
    //[self updatePortFrames];
    [self.delegate box:self instantiateObjectWithName:textField.text];
}

- (void)handleText:(NSString *)text
{
    self.className = text;
    kAllowEdit = YES;
}



@end
