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

//@property (nonatomic,strong)UILongPressGestureRecognizer *longpress;

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
        [textField endEditing:YES];
        [textField resignFirstResponder];
        [textField.nextResponder becomeFirstResponder];
        NSString *text = textField.text;
        if ([textField isKindOfClass:[BSDTextField class]]) {
            BSDTextField *tf = (BSDTextField *)textField;
            if (tf.suggestedText) {
                text = tf.suggestedText;
                tf.suggestedCompletion = nil;
                [tf setNeedsDisplay];
            }
        }
        [self handleText:text];
    }
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
            if (!argsString) {
                argsString = [[NSMutableString alloc]init];
                [argsString appendFormat:@"%@",comp];
            }else{
                [argsString appendFormat:@" %@",comp];
            }
            
            if (r.length == 0) {
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
    
    //self.argString = [NSString stringWithString:argsString];
    [self createObjectWithName:name arguments:argsList];
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
        [self makeObjectInstanceArgs:args];
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

    NSArray *inletViews = [self inlets];
    self.inletViews = [NSMutableArray arrayWithArray:inletViews];
    NSArray *outletViews = [self outlets];
    self.outletViews = [NSMutableArray arrayWithArray:outletViews];
    kAllowEdit = NO;
    self.selected = NO;
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
    self.frame = frame;
    self.textField.frame = CGRectInset(self.bounds, size.width * 0.15, 0);
}

- (id)makeCreationArgs
{
    return self.creationArguments;
}

@end
