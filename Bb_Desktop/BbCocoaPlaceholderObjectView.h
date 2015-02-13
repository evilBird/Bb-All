//
//  BbCocoaPlaceholderObjectView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"

@interface BbCocoaPlaceholderObjectView : BbCocoaEntityView <NSTextFieldDelegate,NSTextDelegate>

@property (nonatomic,strong)NSTextField *textField;

@end
