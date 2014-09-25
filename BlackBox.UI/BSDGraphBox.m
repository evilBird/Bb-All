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
#import "BSDCanvas.h"
#import "BSDTextParser.h"


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
        _textField.tintColor = [UIColor colorWithWhite:0.7 alpha:1];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self insertSubview:_textField atIndex:0];
        kAllowEdit = YES;
    }
    
    return self;
}

+ (BSDGraphBox *)graphBoxWithFrame:(CGRect)frame className:(NSString *)className args:(id)args
{
    BSDGraphBox *graphBox = [[BSDGraphBox alloc]initWithFrame:frame];
    [graphBox createObjectWithName:className arguments:args];
    return graphBox;
}

- (instancetype)initWithDescription:(BSDObjectDescription *)desc
{
    CGRect frame = desc.displayRect.CGRectValue;
    
    self = [self initWithFrame:frame];
    if (self) {
        self.assignedId = desc.uniqueId;
        [self createObjectWithName:desc.className arguments:desc.creationArguments];
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

- (void)setDelegate:(id<BSDBoxDelegate>)delegate
{
    [super setDelegate:delegate];
    if (self.object != NULL) {
        UIView *myView = [[self.object coldInlet]value];
        if ([myView isKindOfClass:[UIView class]]) {
            UIView *superview = [self.delegate displayViewForBox:self];
            myView.center = [myView convertPoint:superview.center toView:myView];
            [superview insertSubview:myView atIndex:0];
            self.selected = NO;
        }
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text && textField.text.length > 0) {
        [textField endEditing:YES];
        [textField resignFirstResponder];
        [textField.nextResponder becomeFirstResponder];
        [self handleText:textField.text];
    }
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
    
    /*
    NSDictionary *parsedText = [BSDTextParser getClassNameAndArgsFromText:text];
    NSString *class = nil;
    NSArray *argsList = nil;
    if (parsedText && [parsedText.allKeys containsObject:@"class"]) {
        class = parsedText[@"class"];
        if ([parsedText.allKeys containsObject:@"args"]) {
            argsList = parsedText[@"args"];
        }
    }
     */
    
    [self createObjectWithName:name arguments:argsList];
}


- (void)createObjectWithName:(NSString *)name arguments:(NSArray *)args
{
    self.className = nil;
    
    if (self.delegate) {
        self.className = [self.delegate getClassNameForText:name];
    }else{
        self.className = name;
    }
    
    if (self.className) {
        if ([name isEqualToString:@"BSDView"] || [name isEqualToString:@"BSDLabel"]) {

            if (self.delegate) {
                UIView *view = [self.delegate displayViewForBox:self];
                self.creationArguments = args;
                [self makeObjectInstanceArgs:@[view]];
            }else{
                [self makeObjectInstance];
            }
            
        }else{
            
            self.creationArguments = args;
            if (args) {
                [self makeObjectInstanceArgs:args];
            }else{
                [self makeObjectInstance];
            }
        }
        
        NSMutableString *displayName = [[NSMutableString alloc]initWithString:[self.object name]];
        for (id arg in args) {
            if ([arg isKindOfClass:[NSNumber class]]|| [arg isKindOfClass:[NSString class]]) {
                [displayName appendFormat:@" %@",arg];
            }
        }
        
        [self.textField setText:displayName];
        NSArray *inletViews = [self inlets];
        self.inletViews = [NSMutableArray arrayWithArray:inletViews];
        NSArray *outletViews = [self outlets];
        self.outletViews = [NSMutableArray arrayWithArray:outletViews];
        kAllowEdit = NO;
        self.selected = NO;
    }else{
        
        self.textField.text = name;
        [self.textField becomeFirstResponder];
    }

}

- (id)makeCreationArgs
{
    return self.creationArguments;
}

@end
