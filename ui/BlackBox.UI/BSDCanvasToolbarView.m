//
//  BSDCanvasToolBar.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/30/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDCanvasToolbarView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@interface BSDCanvasToolbarView ()
{
    UIColor *kDefaultBarButtonColor;
    UIColor *kSelectedBarButtonColor;
    UIColor *kDisabledBarButtonColor;
}

@property (nonatomic,strong)NSMutableDictionary *myItems;

@end

@implementation BSDCanvasToolbarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _toolbar = [[UIToolbar alloc]initWithFrame:self.bounds];
        _toolbar.delegate = self;
        _toolbar.backgroundColor = [UIColor clearColor];
        NSArray *items = @[@"home",@"save",@"load",@"add",@"delete",@"edit",@"cut",@"copy",@"paste",@"patch",@"view"];
        [self addItems:items toToolbar:_toolbar];
        [self addSubview:_toolbar];
        self.backgroundColor = [UIColor whiteColor];
        kDefaultBarButtonColor = [UIColor colorWithWhite:0.3 alpha:1];
        kSelectedBarButtonColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:1];
        kDisabledBarButtonColor = [UIColor colorWithWhite:0.8 alpha:1];
        self.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1].CGColor;
        self.layer.borderWidth = 1.0;
        
        /*
        bounds = self.bounds;
        bounds.size.height = 20;
        bounds.origin.y += 88;
        frame = CGRectInset(bounds, 10, 0);
        _titleLabel = [[UILabel alloc]initWithFrame:frame];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
         */
        
        [self configureConstraints];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CGRect bounds = self.bounds;
        _toolbar = [[UIToolbar alloc]initWithFrame:bounds];
        _toolbar.delegate = self;
        _toolbar.backgroundColor = [UIColor clearColor];
        NSArray *items = @[@"home",@"save",@"load",@"add",@"delete",@"edit",@"cut",@"copy",@"paste",@"patch",@"view"];
        [self addItems:items toToolbar:_toolbar];
        [self addSubview:_toolbar];
        self.backgroundColor = [UIColor whiteColor];
        kDefaultBarButtonColor = [UIColor colorWithWhite:0.3 alpha:1];
        kSelectedBarButtonColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:1];
        kDisabledBarButtonColor = [UIColor colorWithWhite:0.8 alpha:1];
        self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.5].CGColor;
        self.layer.borderWidth = 1.0;
        
        [self configureConstraints];
    }
    
    return self;
}

- (UIBarButtonItem *)itemForName:(NSString *)name
{
    return self.myItems[name];
}

- (void)addItems:(NSArray *)items toToolbar:(UIToolbar *)toolbar
{
    NSMutableArray *temp = [NSMutableArray array];
    self.myItems = [NSMutableDictionary dictionary];
    NSInteger idx = 1;
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [temp addObject:space];
    for (NSString *anItem in items) {
        NSString *imageName = [@"toolbar_" stringByAppendingString:anItem];
        UIImage *image = [UIImage imageNamed:imageName];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]initWithImage:image
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(handleTapInToolbarItem:)];
        bbi.tag = idx;
        bbi.tintColor = [UIColor colorWithWhite:0.2 alpha:1];
        [temp addObject:bbi];
        self.myItems[anItem] = bbi;
        [temp addObject:space];
        idx ++;
    }
    [toolbar setItems:temp];
}

- (void)handleTapInToolbarItem:(id)sender
{
    [self.delegate tapInToolBar:self item:sender];
}

- (void)setEditState:(BSDCanvasEditState)editState
{
    UIBarButtonItem *home = [self itemForName:@"home"];
    UIBarButtonItem *save = [self itemForName:@"save"];
    UIBarButtonItem *load = [self itemForName:@"load"];
    UIBarButtonItem *add = [self itemForName:@"add"];
    UIBarButtonItem *delete = [self itemForName:@"delete"];
    UIBarButtonItem *edit = [self itemForName:@"edit"];
    UIBarButtonItem *cut = [self itemForName:@"cut"];
    UIBarButtonItem *copy = [self itemForName:@"copy"];
    UIBarButtonItem *paste = [self itemForName:@"paste"];
    UIBarButtonItem *patch = [self itemForName:@"patch"];
    UIBarButtonItem *view = [self itemForName:@"view"];
    BOOL homeEnabled = [self.delegate enableHomeButtonInToolbarView:self];
    if (homeEnabled) {
        home.tintColor = kDefaultBarButtonColor;
    }else{
        home.tintColor = kDisabledBarButtonColor;
    }
    save.tintColor = kDefaultBarButtonColor;
    load.tintColor = kDefaultBarButtonColor;
    add.tintColor = kDefaultBarButtonColor;
    delete.tintColor = kDefaultBarButtonColor;
    
    switch (editState) {
        case BSDCanvasEditStateDefault:
            edit.tintColor = kDefaultBarButtonColor;
            cut.tintColor = kDisabledBarButtonColor;
            copy.tintColor = kDisabledBarButtonColor;
            paste.tintColor = kDisabledBarButtonColor;
            patch.tintColor = kDisabledBarButtonColor;
            view.tintColor = kDefaultBarButtonColor;
            break;
        case BSDCanvasEditStateEditing:
            edit.tintColor = kSelectedBarButtonColor;
            cut.tintColor = kDisabledBarButtonColor;
            copy.tintColor = kDisabledBarButtonColor;
            paste.tintColor = kDisabledBarButtonColor;
            patch.tintColor = kDisabledBarButtonColor;
            view.tintColor = kDefaultBarButtonColor;
            break;
        case BSDCanvasEditStateContentSelected:
            edit.tintColor = kSelectedBarButtonColor;
            cut.tintColor = kDefaultBarButtonColor;
            copy.tintColor = kDefaultBarButtonColor;
            paste.tintColor = kDisabledBarButtonColor;
            patch.tintColor = kDisabledBarButtonColor;
            view.tintColor = kDefaultBarButtonColor;
            break;
        case BSDCanvasEditStateContentCopied:
            edit.tintColor = kSelectedBarButtonColor;
            cut.tintColor = kDefaultBarButtonColor;
            copy.tintColor = kDefaultBarButtonColor;
            paste.tintColor = kDefaultBarButtonColor;
            patch.tintColor = kDefaultBarButtonColor;
            view.tintColor = kDefaultBarButtonColor;
            break;
            
        default:
            break;
    }
}

- (void)configureConstraints
{
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraint = nil;
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.toolbar
                  attribute:NSLayoutAttributeTop
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeTop
                  multiplier:1
                  constant:0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.toolbar
                  attribute:NSLayoutAttributeBottom
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeBottom
                  multiplier:1
                  constant:0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.toolbar
                  attribute:NSLayoutAttributeLeading
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeLeading
                  multiplier:1
                  constant:0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.toolbar
                  attribute:NSLayoutAttributeTrailing
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeTrailing
                  multiplier:1
                  constant:0];
    [self addConstraint:constraint];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
