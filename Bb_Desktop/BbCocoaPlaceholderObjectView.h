//
//  BbCocoaPlaceholderObjectView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"

@interface BbCocoaPlaceholderObjectView : BbCocoaEntityView <NSTextFieldDelegate,NSTextDelegate>

@property (nonatomic,strong)    NSTextField                                 *textField;
@property (nonatomic,weak)      id<BbPlaceholderViewDelegate>               delegate;

- (instancetype)initWithDelegate:(id<BbPlaceholderViewDelegate>)delegate
                 viewDescription:(id)viewDescription
                        inParent:(id)parentView;

@end
