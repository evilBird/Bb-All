//
//  BbCocoaPlaceholderObjectView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPlaceholderObjectView.h"
#import "BbCocoaPortView.h"
#import "BbCocoaObjectView.h"

static CGFloat kHorizontalInset = 10.0;
static CGFloat kVerticalInset = 5.0;
static CGFloat kMinWidth = 50.0;

@implementation BbCocoaPlaceholderObjectView

- (void)commonInitEntity:(BbEntity *)entity viewDescription:(id)viewDescription
{
    [super commonInitEntity:entity viewDescription:viewDescription];
    self.textField = [[NSTextField alloc]initWithFrame:self.bounds];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.placeholderString = @"enter text";
    NSDictionary *textAttributes = [BbCocoaEntityViewDescription textAttributes];
    self.textField.font = [textAttributes valueForKey:NSFontAttributeName];
    self.textField.textColor = [textAttributes valueForKey:NSForegroundColorAttributeName];
    self.textField.delegate = self;
    self.textField.backgroundColor = self.defaultColor;
    self.textField.bordered = NO;
    [(NSView *)self addSubview:self.textField];
}

- (void)setupConstraintsInParentView:(id)parent
{
    [super setupConstraintsInParentView:parent];
    [self.textField autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(kVerticalInset, kHorizontalInset, kVerticalInset, kHorizontalInset)];
    
}

- (NSSize)intrinsicContentSize
{
    CGSize size;
    size.height = [self intrinsicContentHeight];
    size.width = [self intrinsicContentWidth];
    return NSSizeFromCGSize(size);
}

- (CGFloat)intrinsicContentWidth
{
    if (!self.textField || !self.textField.stringValue || !self.textField.stringValue.length) {
        return kMinWidth;
    }
    NSString *text = [NSString stringWithString:self.textField.stringValue];
    CGFloat textWidth = [text sizeWithAttributes:[BbCocoaEntityViewDescription textAttributes]].width;
    CGFloat textInsetsWidth = kPortViewWidthConstraint;
    CGFloat widthRequiredByText = textWidth + textInsetsWidth;
    
    return [NSView roundFloat:widthRequiredByText];
}

- (CGFloat)intrinsicContentHeight
{
    return kMinVerticalSpacerSize + 2.0f * kPortViewHeightConstraint;
}

- (NSColor *)defaultColor
{
    return [NSColor blackColor];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.3 alpha:1.0];
}

// These delegate and notification methods are sent from NSControl subclasses that allow text editing such as NSTextField and NSMatrix.  The classes that need to send these have delegates.  NSControl does not.
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    return YES;
}

- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error
{
    return NO;
}
- (void)control:(NSControl *)control didFailToValidatePartialString:(NSString *)string errorDescription:(NSString *)error
{
    
}
- (BOOL)control:(NSControl *)control isValidObject:(id)obj
{
    return YES;
}

- (void)textDidBeginEditing:(NSNotification *)notification
{
    NSLog(@"text began editing");
}

- (void)textDidChange:(NSNotification *)notification
{
    NSLog(@"text did change");
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    NSLog(@"text ended editing");
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector{
    NSString *text = textView.textContainer.textView.string;
    NSLog(@"\nTEXT\n%@\n",text);
    if ([NSStringFromSelector(commandSelector)isEqualToString:@"insertNewline:"]) {
        return NO;
    }
    return YES;
}

- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    NSLog(@"completion method was called");
    return nil;
}

/*
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
*/
@end
