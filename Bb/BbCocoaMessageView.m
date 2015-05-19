//
//  BbCocoaMessageView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaMessageView.h"
#import "BbMessage.h"
#import "NSObject+Bb.h"
#import "NSString+Bb.h"
#import "NSMutableString+Bb.h"
#import "BbCocoaEntityView+TextDelegate.h"

@interface BbCocoaMessageView () <BbObjectDisplayDelegate>

- (void)object:(id)sender didUpdate:(NSString *)updateToDisplay;

@end

@implementation BbCocoaMessageView

- (void)commonInitEntity:(BbEntity *)entity viewDescription:(id)viewDescription
{
    [super commonInitEntity:entity viewDescription:viewDescription];
    [(BbMessage *)entity setDisplayDelegate:self];
    kMinWidth = 100.0;
    
    [self setupTextField];
    __weak BbCocoaMessageView *weakself = self;
    self.textEditingChangedHandler = ^(VCTextField *textField){
        [weakself invalidateIntrinsicContentSize];
#if TARGET_OS_IPHONE == 1
        [weakself setNeedsDisplay];
        [weakself.superview setNeedsDisplay];
#else
        [weakself setNeedsDisplay:YES];
        [weakself.superview setNeedsDisplay:YES];
#endif

    };
    
    self.textEditingEndedHandler = ^(NSString *text){
        
        NSMutableString *mutable = [NSMutableString stringWithString:text];
        [mutable trimWhiteSpace];
        NSString *message = [NSString stringWithString:mutable.mutableCopy];
        [(BbMessage *)weakself.entity setMessageBuffer:message];
#if TARGET_OS_IPHONE == 0
        weakself.textField.stringValue = message;
        [weakself invalidateIntrinsicContentSize];
        [weakself setNeedsDisplay:YES];
        [weakself.superview setNeedsDisplay:YES];
#else
        //TODO
        weakself.textField.text = message;
        [weakself.textField invalidateIntrinsicContentSize];
        [weakself setNeedsDisplay];
        [weakself.superview setNeedsDisplay];
#endif
    };
    
    self.editing = NO;
}

- (VCSize)intrinsicContentSize
{
    VCSize size;
    size.height = [self intrinsicContentHeight];
    size.width = [self intrinsicContentWidth];
    return size;
}

- (CGFloat)editingTextExpansionFactor
{
    return 1.1;
}

- (CGFloat)defaultTextExpansionFactor
{
    return 1.07;
}

- (VCColor *)defaultColor
{
    return [VCColor colorWithWhite:0.9 alpha:1];
}

- (VCColor *)selectedColor
{
    return [VCColor colorWithWhite:0.8 alpha:1];
}

- (VCColor *)sendingColor
{
    return [VCColor colorWithWhite:0.7 alpha:1];
}

- (VCColor *)editingColor
{
    return [VCColor whiteColor];
}
#if TARGET_OS_IPHONE == 1

#else
- (void)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    NSLog(@"Selector method is (%@)", NSStringFromSelector( commandSelector ) );
    if (commandSelector == @selector(insertNewline:)) {
        //Do something against ENTER key
        if (self.editing) {
            [self endEditingText];
            self.editing = NO;
            NSString *text = [NSString stringWithString:self.textField.stringValue];
            self.textEditingEndedHandler(text);
        }
    }
}
#endif


- (void)sendMessage
{
    [[(BbMessage *)self.entity hotInlet]input:[BbBang bang]];
    self.sending = YES;
#if TARGET_OS_IPHONE == 0
    [self setNeedsDisplay:YES];
#else
    [self setNeedsDisplay];
#endif
    __weak BbCocoaMessageView *weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself endMessage];
    });
}

- (void)endMessage
{
    self.sending = NO;
#if TARGET_OS_IPHONE == 0
    [self setNeedsDisplay:YES];
#else
    [self setNeedsDisplay];
#endif
}

- (id)clickDown:(VCEvent *)theEvent
{
    [super clickDown:theEvent];
    [self sendMessage];
    if (self.selected) {
        return self;
    }
    
    return nil;
}

+ (NSDictionary *)textAttributes
{
    VCFont *font = [VCFont fontWithName:@"Courier" size:[VCFont systemFontSize]];
    VCColor *color = [VCColor blackColor];
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    
    #if TARGET_OS_IPHONE == 1
    paragraphStyle.alignment = NSTextAlignmentCenter;

#else
    paragraphStyle.alignment = NSCenterTextAlignment;
#endif
    NSDictionary *textAttributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:color,
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
    return textAttributes;
}

- (void)drawRect:(VCRect)dirtyRect {
    //[super drawRect:dirtyRect];
    // Drawing code here.
    
    VCColor *fillColor;
    if (self.sending) {
        fillColor = [self sendingColor];
    }else if (self.editing){
        fillColor = self.editingColor;
    }else if (self.selected){
        fillColor = self.selectedColor;
    }else{
        fillColor = self.defaultColor;
    }
    
    [fillColor setFill];
    #if TARGET_OS_IPHONE == 0
    NSRectFill(dirtyRect);
#else
    //TODO
#endif
    
    VCBezierPath *outlinePath = [VCBezierPath bezierPathWithRect:self.bounds];
    [[VCColor blackColor]setStroke];
    [outlinePath setLineWidth:1];
    [outlinePath stroke];
}


#pragma mark - BbObjectDisplayDelegate

- (void)object:(id)sender didUpdate:(NSString *)updateToDisplay
{
    NSString *textFieldText = nil;
#if TARGET_OS_IPHONE == 0
    textFieldText = self.textField.stringValue;
#else
    textFieldText = self.textField.text;
#endif
    if (sender == self.entity && ![updateToDisplay isEqualToString:textFieldText]) {
#if TARGET_OS_IPHONE == 0
        [self.textField setStringValue:updateToDisplay];
        [self invalidateIntrinsicContentSize];
        [self setNeedsDisplay:YES];
        [self.superview setNeedsDisplay:YES];
#else
        [self.textField setText:updateToDisplay];
        [self.textField invalidateIntrinsicContentSize];
        [self setNeedsDisplay];
        [self.superview setNeedsDisplay];
#endif
    }
}

@end
