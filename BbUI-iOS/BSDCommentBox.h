//
//  BSDCommentBox.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/30/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDBox.h"

@interface BSDCommentBox : BSDBox<UITextViewDelegate>

@property (nonatomic,strong)UITextView *textField;

@end
