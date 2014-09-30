//
//  BSDMessageBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDMessageBox.h"
#import "BSDMessage.h"
#import "BSDTextParser.h"

@interface BSDMessageBox ()<UITextFieldDelegate,UIGestureRecognizerDelegate>{
    BOOL kAllowEdit;
}


@property (nonatomic,strong)UITapGestureRecognizer *taprecognizer;

@end

@implementation BSDMessageBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.className = @"BSDMessage";
        [self makeObjectInstance];
        _textField = [[UITextField alloc]initWithFrame:self.bounds];
        _textField.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.placeholder = @"message";
        _textField.delegate = self;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.delegate = self;
        _textField.tintColor = [UIColor darkGrayColor];
        [self addSubview:_textField];
        NSArray *inletViews = [self inlets];
        self.inletViews = [NSMutableArray arrayWithArray:inletViews];
        NSArray *outletViews = [self outlets];
        self.outletViews = [NSMutableArray arrayWithArray:outletViews];
        self.defaultColor = [UIColor colorWithWhite:0.9 alpha:1];
        self.selectedColor = [UIColor colorWithWhite:0.99 alpha:1];
        self.currentColor = self.defaultColor;
        kAllowEdit = YES;
        [self setSelected:NO];
    }
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIGestureRecognizerState pan = self.panGesture.state;
    if (pan == UIGestureRecognizerStateBegan || pan == UIGestureRecognizerStateChanged) {
        return NO;
    }
    textField.text = @"";
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField endEditing:YES];
    [textField resignFirstResponder];
    if (textField.text && textField.text.length) {
        [self handleText:textField.text];
    }else{
        [[self.object hotInlet]input:[BSDBang bang]];
    }
}

- (void)handleText:(NSString *)text
{
    if (!text || text.length == 0) {
        return;
    }
    
    id theMessage = nil;
    NSArray *components = [text componentsSeparatedByString:@" "];
    
    if (components.count == 1) {
        id component = components.firstObject;
        theMessage = [self setTypeForString:component];
    }else {
        NSMutableArray *temp = nil;
        for (id component in components) {
            
            if (!temp) {
                temp = [NSMutableArray array];
            }
            
            [temp addObject:[self setTypeForString:component]];
        }
        theMessage = [temp mutableCopy];
    }
    
    if (theMessage!=nil) {
        [[(BSDMessage *)self.object hotInlet]input:@{@"set":theMessage}];
    }
}

- (void)resizeToFitText:(NSString *)messageText
{
    if (self.object) {
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
}

- (void)handleObjectValueShouldChangeNotification:(NSNotification *)notification
{
    NSDictionary *changeInfo = notification.object;
    id val = changeInfo[@"value"];
    if (val) {
        NSString *displayText = [NSString stringWithFormat:@"%@",val];
        NSString *nnl = [displayText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *nt = [nnl stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSString *nq = [nt stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        self.textField.text = nq;
        [self resizeToFitText:self.textField.text];
    }
}

- (id)setTypeForString:(NSString *)string
{
    NSRange n = [string rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    
    if (n.length > 0) {
        return string;
    }else{
        return @([string doubleValue]);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect bounds = self.bounds;
    //bounds.size.width += 10;
    //self.backgroundColor = [UIColor clearColor];
    [path moveToPoint:bounds.origin];
    CGPoint pt = CGPointMake(bounds.size.width, 0);
    [path addLineToPoint:pt];
    //pt.x = bounds.size.width-10;
    //pt.y = bounds.size.height*0.5;
    //[path addLineToPoint:pt];
    pt.x = bounds.size.width;
    pt.y = bounds.size.height;
    [path addLineToPoint:pt];
    pt.x = bounds.origin.x;
    [path addLineToPoint:pt];
    pt = bounds.origin;
    [path addLineToPoint:pt];
    [path setLineWidth:1];
    [[UIColor darkGrayColor]setStroke];
    [self.currentColor setFill];
    [path fill];
    [path stroke];

}
*/

@end
