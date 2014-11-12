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
        _textField = [[BSDTextField alloc]initWithFrame:self.bounds];
        _textField.placeholder = @"Object";
        _textField.delegate = self;
        _textField.textColor = [UIColor whiteColor];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = [UIFont fontWithName:@"Courier-Bold" size:[UIFont systemFontSize]];
        _textField.tintColor = [UIColor colorWithWhite:0.7 alpha:1];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.enabled = YES;
        self.boxClassString = @"BSDGraphBox";
        [_textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BSDTextField *tf = (BSDTextField *)textField;
    //[tf editingWillBegin];
    return kAllowEdit;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.className = nil;
    self.selected = NO;
}

- (void)textDidChange:(id)sender
{
    if (sender == self.textField){
        [self.textField suggestedCompletionForText:self.textField.text];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BSDTextField *tf = (BSDTextField *)textField;
    //[tf editingWillEnd];
    [textField endEditing:YES];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text && textField.text.length > 0) {
        NSString *text = textField.text;
        if ([textField isKindOfClass:[BSDTextField class]]) {
            BSDTextField *tf = (BSDTextField *)textField;
            if (tf.suggestedText) {
                text = tf.suggestedText;
                tf.suggestedCompletion = nil;
                [tf setNeedsDisplay];
                [self handleText:text];
                [self createPortViewsForObject:self.object];

            }
        }
    }
    
    [textField endEditing:YES];
    [textField resignFirstResponder];
    [textField.nextResponder becomeFirstResponder];
}

- (void)handleText:(NSString *)text
{
    NSMutableArray *components = [[text componentsSeparatedByString:@" "]mutableCopy];
    NSMutableString *argsString = nil;
    NSString *name = nil;
    if (components) {
        name = components.firstObject;
        [components removeObject:name];
    }
    
    NSMutableArray *argsList = nil;
    if (components.count) {
        for (NSString *comp in components) {
            NSRange r = [comp rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
            NSRange s = [comp rangeOfString:@"$"];
            if (!argsString) {
                argsString = [[NSMutableString alloc]init];
                [argsString appendFormat:@"%@",comp];
            }else{
                [argsString appendFormat:@" %@",comp];
            }
            
            if (r.length == 0 && s.length == 0) {
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
    
    if (argsString) {
        self.argString = [NSString stringWithString:argsString];
    }
    
    [self createObjectWithName:name arguments:argsList];
    kAllowEdit = NO;
}


- (void)createObjectWithName:(NSString *)name arguments:(NSArray *)args
{
    if (!name) {
        [self.textField becomeFirstResponder];
        return;
    }
    self.className = name;
    
    if (args) {
        self.creationArguments = args;
        [self makeObjectInstanceArgs:[self makeSubstitutionsInArgs:args canvasArgs:self.canvasCreationArgs]];
    }else{
        self.creationArguments = nil;
        [self makeObjectInstance];
    }
    
    
    NSMutableString *displayName = [[NSMutableString alloc]initWithString:[self.object name]];
    for (id arg in args) {
        if ([arg isKindOfClass:[NSNumber class]]|| [arg isKindOfClass:[NSString class]]) {
            [displayName appendFormat:@" %@",arg];
        }
    }
    
    [self.textField setText:displayName];
    [self resizeForText:displayName];
    kAllowEdit = NO;
}

- (NSArray *)makeSubstitutionsInArgs:(NSArray *)args
{
    NSMutableArray *result = nil;
    for (id anArg in args) {
        id subbedArg = nil;
        if ([anArg isKindOfClass:[NSString class]]) {
            subbedArg = [anArg stringByReplacingOccurrencesOfString:@"$0" withString:self.canvasId];
        }else{
            subbedArg = anArg;
        }
        
        if (!result) {
            result = [NSMutableArray array];
        }
        [result addObject:subbedArg];
    }
    return result;
}

- (NSArray *)makeSubstitutionsInArgs:(NSArray *)args canvasArgs:(NSArray *)canvasArgs
{
    NSMutableArray *result = nil;
    for (id anArg in args) {
        id subbedArg = nil;
        if ([anArg isKindOfClass:[NSString class]]) {
            NSRange range = [anArg rangeOfString:@"$0"];
            if (range.length > 0) {
                subbedArg = [anArg stringByReplacingOccurrencesOfString:@"$0" withString:self.canvasId];
            }else if (canvasArgs != nil){
                for (NSInteger idx = 0; idx < canvasArgs.count; idx ++) {
                    NSString *toReplace = [NSString stringWithFormat:@"$%@",@(idx+1)];
                    range = [anArg rangeOfString:toReplace];
                    if (range.length > 0) {
                        NSString *replacementString = [NSString stringWithFormat:@"%@",canvasArgs[idx]];
                        subbedArg = [anArg stringByReplacingOccurrencesOfString:toReplace withString:replacementString];
                    }
                }
            }
            
            if (subbedArg == nil) {
                subbedArg = [NSString stringWithString:anArg];
            }
            
        }else{
            subbedArg = anArg;
        }
        
        if (!result) {
            result = [NSMutableArray array];
        }
        [result addObject:subbedArg];
    }
    
    return result;
}

- (void)initializeWithText:(NSString *)text
{
    if (text) {
        [self handleText:[NSString stringWithFormat:@"%@ %@",self.className,text]];
        [self createPortViewsForObject:self.object];
        kAllowEdit = NO;
    }else{
        [self handleText:[NSString stringWithFormat:@"%@",self.className]];
        [self createPortViewsForObject:self.object];
        kAllowEdit = NO;
    }
}

- (void)resizeForText:(NSString *)text
{
    NSDictionary *attributes = @{NSFontAttributeName:self.textField.font};
    
    CGSize size = [text sizeWithAttributes:attributes];
    CGSize minSize = [self minimumSize];
    CGRect frame = self.frame;
    frame.size.width = size.width * 1.3;
    if (frame.size.width < minSize.width) {
        frame.size.width = minSize.width;
    }
    CGPoint oldCenter = self.center;
    self.frame = frame;
    self.textField.frame = CGRectInset(self.bounds, size.width * 0.15, 0);
    self.center = oldCenter;
}

- (id)makeCreationArgs
{
    return self.creationArguments;
}

@end
