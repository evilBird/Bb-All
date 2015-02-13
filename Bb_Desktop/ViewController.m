//
//  ViewController.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ViewController.h"
#import "BbCocoaPatchView+Touches.h"
#import "BbObject+Decoder.h"
#import "BbCocoaObjectView.h"
#import "BbCocoaPatchView.h"
#import "BbUI.h"
#import "BbPatch.h"
#import "NSMutableString+Bb.h"
@interface ViewController ()
{
    CGPoint kFocusPoint;
}

@property (nonatomic,strong)BbCocoaPatchView *patchView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.patchView = [[BbCocoaPatchView alloc]initWithEntity:[[BbPatch alloc]initWithArguments:@"test"]
                                                 viewDescription:nil
                                                    inParent:self.view];
    // Do any additional setup after loading the view.
    NSString *desc = nil;
    NSUInteger ancestors;
    ancestors = [[self.patchView patch]countAncestors];
    
    desc = [NSMutableString descBbObject:@"BbAdd"
                               ancestors:ancestors+1
                                position:@[@50,@50]
                                    args:@5];
    [self.patchView addObjectWithText:desc];
    
    desc = [NSMutableString descBbObject:@"BbAdd"
                               ancestors:ancestors+1
                                position:@[@25,@50]
                                    args:@25];
    [self.patchView addObjectWithText:desc];
    
    desc = [NSMutableString descBbObject:@"BbMod"
                               ancestors:ancestors+1
                                position:@[@75,@50]
                                    args:@3];
    [self.patchView addObjectWithText:desc];
    
    desc = [NSMutableString descBbObject:@"BbSubtract"
                               ancestors:ancestors+1
                                position:@[@50,@25]
                                    args:@10];
    [self.patchView addObjectWithText:desc];
    
    desc = [NSMutableString descBbObject:@"BbMultiply"
                               ancestors:ancestors+1
                                position:@[@50,@75]
                                    args:@100];
    [self.patchView addObjectWithText:desc];
    
    NSString *patch = [self.patchView.patch textDescription];
    
    NSLog(@"\n%@\n",patch);
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
    
}

@end
