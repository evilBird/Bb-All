//
//  BSDTextField.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/25/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSDTextField : UITextField

@property (nonatomic,strong)NSString *suggestedCompletion;
@property (nonatomic,strong)NSString *suggestedText;
@property (nonatomic,strong)NSString *className;
@property (nonatomic,strong)NSMutableArray *arguments;

- (void)editingWillEnd;
- (void)editingWillBegin;

- (NSString *)suggestedCompletionForText:(NSString *)text;



@end
