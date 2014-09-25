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
    BOOL kCanEdit;
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
        NSArray *inletViews = [self inlets];
        self.inletViews = [NSMutableArray arrayWithArray:inletViews];
        NSArray *outletViews = [self outlets];
        self.outletViews = [NSMutableArray arrayWithArray:outletViews];
        self.defaultColor = [UIColor colorWithWhite:0.9 alpha:1];
        self.selectedColor = [UIColor colorWithWhite:0.99 alpha:1];
        self.currentColor = self.defaultColor;
        _textField = [[UITextField alloc]initWithFrame:self.bounds];
        _textField.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.placeholder = @"message";
        _textField.delegate = self;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.tintColor = [UIColor darkGrayColor];
        [self addSubview:_textField];
        kCanEdit = YES;
    }
    return self;
}

- (void)handleMessageChangedNotification:(NSNotification *)notification
{
    NSDictionary *object = notification.object;
    if ([object.allKeys containsObject:@"message"]) {
        self.textField.text = [NSString stringWithFormat:@"%@",object[@"message"]];
        [self.textField sizeToFit];
        [self setNeedsDisplay];
    }
}
/*
- (NSArray *)inlets
{
    if (self.object == NULL) {
        return nil;
    }
    
    NSArray *inlets = [self.object inlets];
    CGRect bounds = self.bounds;
    CGRect frame;
    frame.size.width = bounds.size.width * 0.25;
    frame.size.height = bounds.size.height * 0.35;
    frame.origin.y = 0;
    NSMutableArray *result = [NSMutableArray array];
    BSDInlet *inlet = inlets.firstObject;
    frame.origin.x = 0;
    BSDPortView *portView = [[BSDPortView alloc]initWithName:inlet.name delegate:self];
    portView.frame = frame;
    [result addObject:portView];
    [self addSubview:portView];
    
    return result;
}
 */

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return kCanEdit;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    self.currentColor = self.defaultColor;
    [[self.object hotInlet]input:[BSDBang bang]];
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
        kCanEdit = NO;
    }
}

- (void)handleText:(NSString *)text
{
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
        self.textField.frame = CGRectInset(self.bounds, self.bounds.size.width * 0.15, 0);
    }
}

- (void)handleObjectValueShouldChangeNotification:(NSNotification *)notification
{
    NSDictionary *changeInfo = notification.object;
    id val = changeInfo[@"value"];
    if (val) {
        NSString *displayText = [NSString stringWithFormat:@"%@",val];
        NSString *nws = [displayText stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.textField.text = nws;
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
