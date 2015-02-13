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
#import "BbUI.h"
static CGFloat kMinWidth = 100.0;

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
    self.textField.alignment = NSCenterTextAlignment;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidBeginEditing:) name:NSTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidEndEditing:) name:NSTextDidEndEditingNotification object:nil];
    self.textField.backgroundColor = self.defaultColor;
    self.textField.bordered = NO;
    [(NSView *)self addSubview:self.textField];
}

- (void)setupConstraintsInParentView:(id)parent
{
    [super setupConstraintsInParentView:parent];
    [self.textField autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(kPortViewHeightConstraint,
                                                                            kPortViewWidthConstraint/2,
                                                                            kPortViewHeightConstraint,
                                                                            kPortViewWidthConstraint/2)];
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
    CGFloat textWidthRaw = [text sizeWithAttributes:[BbCocoaEntityViewDescription textAttributes]].width;
    CGFloat textWidth = pow(textWidthRaw, 1.1);
    
    CGFloat textInsetsWidth = kPortViewWidthConstraint;
    CGFloat widthRequiredByText = textWidth + textInsetsWidth;
    if (widthRequiredByText >= kMinWidth) {
        return [NSView roundFloat:widthRequiredByText];
    }else{
        return kMinWidth;
    }
}

- (CGFloat)intrinsicContentHeight
{
    CGFloat contentHeight = kMinVerticalSpacerSize + 2.0f * kPortViewHeightConstraint;
    return contentHeight;
}

- (NSColor *)defaultColor
{
    return [NSColor blackColor];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.3 alpha:1.0];
}

- (instancetype)initWithDelegate:(id<BbPlaceholderViewDelegate>)delegate
                 viewDescription:(id)viewDescription
                        inParent:(id)parentView
{
    self = [super initWithEntity:nil
                 viewDescription:viewDescription
                        inParent:parentView];
    if (self) {
        _delegate = delegate;
    }
    
    return self;
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
    [self invalidateIntrinsicContentSize];
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    [self.textField resignFirstResponder];
    [self.delegate placeholder:self enteredText:self.textField.stringValue];
    NSLog(@"text ended editing");
}

- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    NSLog(@"completion method was called");
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

/*
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
*/
@end
