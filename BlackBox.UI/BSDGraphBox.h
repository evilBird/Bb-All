//
//  BSDGraphBox.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDBox.h"
#import "BSDCompiledPatch.h"

@class BSDCanvas;
@interface BSDGraphBox : BSDBox <UITextFieldDelegate,BSDCompiledPatchDelegate>

+ (BSDGraphBox *)graphBoxWithFrame:(CGRect)frame className:(NSString *)className args:(id)args;
- (instancetype)initWithDescription:(BSDObjectDescription *)desc;
- (void)handleText:(NSString *)text;

@property (nonatomic,strong)BSDTextField *textField;
- (void)prepareToReinitializeRemovePortViews:(BOOL)portViews;
- (void)createObjectWithName:(NSString *)name arguments:(NSArray *)args;

@end
