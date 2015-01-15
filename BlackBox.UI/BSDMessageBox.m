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
        self.boxClassString = @"BSDMessageBox";
        _textField = [[UITextField alloc]initWithFrame:self.bounds];
        _textField.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.placeholder = @"message";
        _textField.delegate = self;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.delegate = self;
        _textField.tintColor = [UIColor darkGrayColor];
        _textField.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeDefault;
        [self addSubview:_textField];
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
    //textField.text = @"";
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!textField.text || textField.text.length == 0) {
        return;
    }
    
    [textField endEditing:YES];
    [textField resignFirstResponder];
    [self handleText:textField.text];
}

- (void)handleText:(NSString *)text
{
    if (!text || text.length == 0) {
        [self.textField becomeFirstResponder];
        [self resizeToFitText:text];
        return;
    }
    self.argString = text;
    id theMessage = nil;
    theMessage = [self formatMessage:text];
        /*
        NSArray *components = [text componentsSeparatedByString:@" "];
        if (components.count == 1) {
            id component = components.firstObject;
            argText = [[NSMutableString alloc]initWithString:component];
            theMessage = [self setTypeForString:component];
        }else {
            NSMutableArray *temp = nil;
            NSMutableString *argText = nil;
            for (id component in components) {
                
                if (!argText) {
                    argText = [[NSMutableString alloc]init];
                    [argText appendString:component];
                }else{
                    [argText appendFormat:@" %@",argText];
                }
                
                
                if (!temp) {
                    temp = [NSMutableArray array];
                }
                
                [temp addObject:[self setTypeForString:component]];
            }
            theMessage = [temp mutableCopy];
        }
         */
    if (theMessage!=nil) {
        
        if ([theMessage respondsToSelector:@selector(count)]) {
            self.creationArguments = theMessage;
        }else{
            self.creationArguments = @[theMessage];
        }
        
        if (self.object != nil) {
            NSMutableArray *toSend = [self.creationArguments mutableCopy];
            [toSend insertObject:@"set" atIndex:0];
            [[(BSDMessage *)self.object hotInlet]input:toSend];
        }
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
    [self.delegate boxDidMove:self];
}

- (void)resizeToFitText:(NSString *)messageText
{
    if (self.object) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{NSFontAttributeName:self.textField.font,
                                     NSParagraphStyleAttributeName:style};
        CGSize size = [messageText sizeWithAttributes:attributes];
        CGSize minSize = [self minimumSize];
        CGRect frame = self.frame;
        frame.size.width = size.width * 1.3;
        if (frame.size.width < minSize.width) {
            frame.size.width = minSize.width;
        }
        
        CGFloat maxWidth = self.superview.bounds.size.width;
        if (frame.size.width > maxWidth) {
            frame.size.width = maxWidth;
        }
        self.frame = frame;
        CGFloat XinsetAmount = size.width * 0.15;
        if (XinsetAmount > 30) {
            XinsetAmount = 30;
        }
        self.textField.frame = CGRectInset(self.bounds, XinsetAmount, 0);
    }
}

- (void)handleObjectValueShouldChangeNotification:(NSNotification *)notification
{
    NSDictionary *changeInfo = notification.object;
    id val = changeInfo[@"value"];
    if (val) {
        self.textField.text = val;
        //self.textField.text = [self formatValue:val];
        [self resizeForText:self.textField.text];
        [self setNeedsDisplay];
    }
}

- (id)formatMessage:(NSString *)message
{
    if (!message) {
        return nil;
    }
    
    NSString *quotesRemoved = [message stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSInteger diff = message.length - quotesRemoved.length;
    if (diff == 2) {
        self.argString = message;
        return message;
        //return quotesRemoved;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    NSArray *comp = [message componentsSeparatedByString:@","];
    
    if (comp.count > 1) {
        for (NSInteger i = 0; i < comp.count; i ++) {
            [result addObject:[self formatMessage:comp[i]]];
        }
        
        return result;
    }
    
    NSArray *elems = [message componentsSeparatedByString:@" "];
    for (NSInteger i  = 0; i < elems.count; i ++) {
        NSString *e = elems[i];
        
        [result addObject:[self setTypeForString:e]];
    }
    
    if (result.count > 1) {
        return result;
    }
    
    return result.firstObject;
}

- (NSString *)formatValue:(id)value
{
    NSMutableString *result = nil;
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (NSInteger i = 0; i < array.count; i ++) {
            id val = array[i];
            if ([val isKindOfClass:[NSArray class]]) {
                if (!result) {
                    result = [[NSMutableString alloc]init];
                    result = [NSMutableString stringWithFormat:@"%@",[self formatValue:val]];
                }else{
                    [result appendFormat:@", %@",[self formatValue:val]];
                }
            }else{
                
                if (!result) {
                    result = [[NSMutableString alloc]init];
                }
                
                if ((i + 1) == array.count) {
                    [result appendFormat:@"%@",val];
                }else{
                    [result appendFormat:@"%@ ",val];
                }
            }
        }
    }else if ([value isKindOfClass:[NSString class]]||[value isKindOfClass:[NSNumber class]]){
        result = [NSMutableString stringWithFormat:@"%@",value];
    }
    
    return result;
}

- (id)setTypeForString:(NSString *)string
{
    NSRange n = [string rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    NSRange s = [string rangeOfCharacterFromSet:[NSCharacterSet symbolCharacterSet]];
    
    if (n.length > 0 || s.length > 0) {
        return string;
    }else{
        return @([string doubleValue]);
    }
    return nil;
}

- (void)initializeWithText:(NSString *)text
{
    [self makeObjectInstance];
    [self createPortViewsForObject:self.object];
    
    if (text) {
        self.argString = text;
        [self handleText:text];
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
