//
//  BbCompiledPatch.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCompiledPatch.h"
#import "BbObject+Decoder.h"
#import "NSMutableArray+Stack.h"

@implementation BbCompiledPatch

- (void)setupWithArguments:(id)arguments
{
    self.name = @"";
    self.creationArguments = arguments;
    if (arguments) {
        NSString *name = [arguments firstObject];
        NSString *patchName = [name stringByAppendingPathExtension:@"txt"];
        if (patchName) {
            NSString *text = [BbCompiledPatch textForSavedPatchWithName:patchName];
            if (text) {
                [self createChildObjectsWithText:text];
            }
        }
    }
}

- (NSArray *)filterDescriptions:(NSArray *)descriptions
{
    NSMutableArray *desc = descriptions.mutableCopy;
    [desc removeObjectAtIndex:0];
    [desc removeObjectAtIndex:(desc.count - 1)];
    return desc;
}

- (void)createChildObjectsWithText:(NSString *)text
{
    NSMutableArray *rawDescriptions = [BbBasicParser descriptionsWithText:text].mutableCopy;
    NSArray *descriptions = [self filterDescriptions:rawDescriptions];
    NSMutableArray *patches = [NSMutableArray array];
    NSMutableArray *childObjects = nil;
    NSMutableArray *connections = nil;
    
    [patches push:self];
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
                [childObjects addObject:child];
                
                BbPatch *patch = [patches pop];
                [patch addChildObject:child];
                [patches push:patch];
            }
        }
    }
}


+ (NSString *)textForSavedPatchWithName:(NSString *)patchName
{
    //NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask,YES);
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSAllDomainsMask,YES);

    NSString *documentsDirectory = [pathArray objectAtIndex:0];
    NSString *patchPath = [documentsDirectory stringByAppendingPathComponent:patchName];
    NSURL *patchURL = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:patchPath])
    {
        patchURL = [NSURL fileURLWithPath:patchPath isDirectory:NO];
        NSLog(@"found saved patch %@ at path: %@",patchName,patchPath);
    }else{
        
        NSLog(@"couldn't find saved patch named %@ at path %@",patchName,patchPath);
    }
    
    NSString *result = nil;
    if (patchURL) {
        NSError *e = nil;
        NSStringEncoding encoding = 0;
        result = [NSString stringWithContentsOfURL:patchURL
                                      usedEncoding:&encoding
                                             error:&e];
        
        if (!e) {
            return result;
        }else{
            NSLog(@"error loading patch: %@",e.debugDescription);
        }
    }
    
    
    return nil;
}

+ (NSString *)stackInstruction
{
    return @"#X";
}

+ (NSString *)UIType
{
    return @"obj";
}


@end
