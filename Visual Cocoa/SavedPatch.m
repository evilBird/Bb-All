//
//  Document.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/20/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "SavedPatch.h"
#import "BbParsers.h"
#import "BbPatch.h"
#import "BbObject+Decoder.h"
#import "BbObject+EntityParent.h"
#import "PatchViewController.h"
#import "NSMutableArray+Stack.h"

@interface SavedPatch ()

@property (nonatomic,strong)NSMutableArray *patchStack;

@end

@implementation SavedPatch

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _patchStack = [NSMutableArray array];
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)makeWindowControllers {
    // Override to return the Storyboard file name of the document.
    NSWindowController *wc = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Document Window Controller"];
    [self addWindowController:wc];
    BbPatch *patch = [self.patchStack pop];
    
    if (!patch) {
        patch = [[BbPatch alloc]initWithArguments:@"untitled patch"];
    }
    
    if (patch) {
        [wc.contentViewController setRepresentedObject:patch];
    }
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    PatchViewController *vc = (PatchViewController *)[self.windowControllers.lastObject contentViewController];
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
    PatchViewController *vc = (PatchViewController *)[self.windowControllers.lastObject contentViewController];
    if (vc) {
        [vc setRepresentedObject:patch];
    }else{
        [self.patchStack push:patch];
    }
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
                [patch addConnectionWithDescription:desc];
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
