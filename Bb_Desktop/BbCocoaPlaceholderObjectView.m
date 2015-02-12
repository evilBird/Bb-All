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

@implementation BbCocoaPlaceholderObjectView

- (void)commonInit
{
    [super commonInit];
    self.textField = [[NSTextField alloc]initWithFrame:self.bounds];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.textColor = [NSColor whiteColor];
    self.textField.placeholderString = @"placeholder";
    NSDictionary *textAttributes = [BbViewDescription textAttributes];
    self.textField.font = [textAttributes valueForKey:NSFontAttributeName];
    self.textField.delegate = self;
    self.textField.backgroundColor = self.defaultColor;
    self.textField.bordered = NO;
    [self addSubview:(id<BbEntityView>)_textField];
}

- (NSColor *)defaultColor
{
    return [NSColor blackColor];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.3 alpha:1.0];
}

- (void)setupConstraints
{
    [super setupConstraints];
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
    return nil;
}

/*
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
*/
@end
