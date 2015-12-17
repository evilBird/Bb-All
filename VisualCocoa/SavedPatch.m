//
//  Document.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/20/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "SavedPatch.h"
#import "BbParsers.h"
#import "BbPatch+Connections.h"
#import "BbObject+Decoder.h"
#import "BbObject+EntityParent.h"
#import "PatchViewController.h"
#import "NSMutableArray+Stack.h"
#import "BbCocoaPatchView+Helpers.h"
#import "BbAbstraction.h"

@interface SavedPatch ()

@property (nonatomic,strong)NSMutableArray *patchStack;
@property (nonatomic,strong)NSString *pasteboard;

@end

@implementation SavedPatch

- (IBAction)copy:(id)sender
{
    BbPatch *patch = [self.patchStack pop];
    BbCocoaPatchView *patchView = (BbCocoaPatchView *)patch.view;
    NSString *copy = [patchView copySelected];
    NSLog(@"copy: \n%@",copy);
    self.pasteboard = copy;
    [self.patchStack push:patch];
}


- (IBAction)paste:(id)sender
{
    BbPatch *patch = [self.patchStack pop];
    BbCocoaPatchView *patchView = (BbCocoaPatchView *)patch.view;
    NSString *pasteboard = [NSString stringWithString:self.pasteboard];
    NSLog(@"paste:\n%@",pasteboard);
    [patchView pasteCopied:pasteboard];
    [self.patchStack push:patch];
}

- (IBAction)abstract:(id)sender
{
    BbPatch *patch = [self.patchStack pop];
    BbCocoaPatchView *patchView = (BbCocoaPatchView *)patch.view;
    [patchView abstractSelected];
    [self.patchStack push:patch];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _patchStack = [NSMutableArray array];
    }
    return self;
}

#if TARGET_OS_IPHONE == 0
- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}
#endif


+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)makeWindowControllers {
    // Override to return the Storyboard file name of the document.
#if TARGET_OS_IPHONE
//TODO
#else
    NSWindowController *wc = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Document Window Controller"];
    [self addWindowController:wc];
#endif
    
    BbPatch *patch = [self.patchStack pop];
    
    if (!patch) {
        patch = [[BbPatch alloc]initWithArguments:@"untitled"];
    }
    
    if (patch) {
#if TARGET_OS_IPHONE
        PatchViewController *vc = nil;
        [vc setRepresentedPatch:patch];
#else
        [wc.contentViewController setRepresentedObject:patch];
#endif
    }
    
    [self.patchStack push:patch];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -
#if TARGET_OS_IPHONE
    PatchViewController *vc = nil;
#else
    PatchViewController *vc = (PatchViewController *)[self.windowControllers.lastObject contentViewController];
#endif
    
    NSString *patchDescription = vc.patch.textDescription;
    NSData *data = [NSData dataWithBytes:[patchDescription UTF8String] length:patchDescription.length];
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSString *convertedString = nil;
    BOOL usedLossyConversion;
    [NSString stringEncodingForData:data
                    encodingOptions:nil
                    convertedString:&convertedString
                usedLossyConversion:&usedLossyConversion];
    if (convertedString) {
        [self parseFileText:convertedString];
        return YES;
    }
    return NO;
}

- (void)parseFileText:(NSString *)text
{
    BbPatch *patch = [SavedPatch patchFromText:text];
#if TARGET_OS_IPHONE
    PatchViewController *vc = nil;
    if (vc) {
        [vc setRepresentedPatch:patch];
    }else{
        [self.patchStack push:patch];
    }
#else
    PatchViewController *vc = (PatchViewController *)[self.windowControllers.lastObject contentViewController];
    if (vc) {
        [vc setRepresentedObject:patch];
    }else{
        [self.patchStack push:patch];
    }
#endif
    
}

+ (BbPatch *)patchFromText:(NSString *)text
{
    NSArray *descriptions = [BbBasicParser descriptionsWithText:text];
    NSMutableArray *patches = [NSMutableArray array];
    NSMutableArray *childObjects = nil;
    NSMutableArray *connections = nil;
    
    BbPatch *result = nil;
    for (BbDescription *desc in descriptions) {
        if ([desc.stackInstruction isEqualToString:@"#N"]) {
            if ([desc.UIType isEqualToString:@"canvas"]) {
                BbPatch *patch = (BbPatch *)[BbObject objectWithDescription:(BbObjectDescription *)desc];
                patch.position = [(BbObjectDescription *)desc UIPosition];
                [patches push:patch];
            }else if ([desc.UIType isEqualToString:@"restore"]){
                BbPatch *patch = [patches pop];
                patch.name = [(BbObjectDescription *)desc BbObjectType];
                BbPatch *parent = [patches pop];
                if (parent) {
                    [parent addChildObject:patch];
                }else{
                    result = patch;
                }
            }
        }else if ([desc.stackInstruction isEqualToString:@"#X"]){
            
            if ([desc.UIType isEqualToString:@"connect"]) {
                if (!connections) {
                    connections = [NSMutableArray array];
                }
                
                [connections addObject:desc];
                BbPatch *patch = [patches pop];
                [patch addConnectionWithDescription:(BbConnectionDescription *)desc];
                [patches push:patch];
                
            }else{
                
                BbObject *child = [BbObject objectWithDescription:(BbObjectDescription *)desc];
                child.position = [(BbObjectDescription *)desc UIPosition];
                if (!childObjects) {
                    childObjects = [NSMutableArray array];
                }
                
                BbPatch *patch = [patches pop];
                [patch addChildObject:child];
                [patches push:patch];
                
                if ([desc.UIType isEqualToString:@"inlet"]) {
                    
                }else if ([desc.UIType isEqualToString:@"outlet"]){
                    
                }
            }
        }
    }
    
    return result;
}

@end
