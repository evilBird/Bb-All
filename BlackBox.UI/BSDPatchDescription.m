//
//  BSDPatchDescription.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/3/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPatchDescription.h"
#import "BSDPatchDescriptionUtility.h"
#import <UIKit/UIKit.h>

@interface BSDPatchDescription ()

@property (nonatomic,strong)BSDPatchDescriptionUtility *patchDescriptionUtility;
@property (nonatomic,strong)NSMutableString *patchText;
@property (nonatomic,strong)NSString *canvasText;
@property (nonatomic,strong)NSMutableArray *objectEntries;

@end

@implementation BSDPatchDescription

- (NSString *)getDescription
{
    if (!self.patchText) {
        return self.canvasText;
    }
    
    NSString *result = [self.canvasText stringByAppendingString:self.patchText];
    
    return [NSString stringWithString:result];
    
}

- (NSUInteger)addEntryType:(NSString *)type className:(NSString *)className args:(NSString *)args position:(CGPoint)position
{
    if (className == nil) {
        return [self addAtomType:type args:args position:position];
    }
    
    return [self addObjectType:type className:className args:args position:position];
}

- (NSUInteger)addObjectType:(NSString *)type className:(NSString *)className args:(NSString *)args position:(CGPoint)position
{
    if (!className) {
        return -1;
    }
    
    NSString *x = [NSString stringWithFormat:@"%@",@((NSInteger)position.x)];
    NSString *y = [NSString stringWithFormat:@"%@",@((NSInteger)position.y)];
    NSString *toAdd = nil;
    
    if (args && args.length) {
        toAdd = [NSString stringWithFormat:@"#X %@ %@ %@ %@ %@;\n",type,x,y,className,args];
    }else{
        toAdd = [NSString stringWithFormat:@"#X %@ %@ %@ %@;\n",type,x,y,className];
    }
    
    [self addEntry:toAdd];
    return [self addObject:toAdd];
    return -1;
}

- (NSUInteger)addPatchDescription:(NSString *)desc name:(NSString *)name frame:(CGRect)frame
{
    if (!desc || !name) {
        return -1;
    }
    NSString *x = [NSString stringWithFormat:@"%@",@((NSInteger)frame.origin.x)];
    NSString *y = [NSString stringWithFormat:@"%@",@((NSInteger)frame.origin.y)];
    NSString *w = [NSString stringWithFormat:@"%@",@((NSInteger)frame.size.width)];
    NSString *h = [NSString stringWithFormat:@"%@",@((NSInteger)frame.size.height)];
    NSString *toAdd = nil;
    toAdd = [NSString stringWithFormat:@"#N canvas %@ %@ %@ %@ %@;\n%@",x,y,w,h,name,desc];
    [self addEntry:toAdd];
    NSLog(@"description:%@",toAdd);
    return [self addObject:toAdd];
    return -1;
}

- (NSUInteger)addAtomType:(NSString *)type args:(NSString *)args position:(CGPoint)position
{
    NSString *x = [NSString stringWithFormat:@"%@",@((NSInteger)position.x)];
    NSString *y = [NSString stringWithFormat:@"%@",@((NSInteger)position.y)];
    NSString *toAdd = nil;
    if (args && args.length) {
        toAdd = [NSString stringWithFormat:@"#X %@ %@ %@ %@;\n",type,x,y,args];
    }else{
        toAdd = [NSString stringWithFormat:@"#X %@ %@ %@;\n",type,x,y];
    }
    
    [self addEntry:toAdd];
    return  [self addObject:toAdd];
    return -1;
}

- (void)addConnectionSender:(NSUInteger)sender outlet:(NSUInteger)outlet receiver:(NSUInteger)receiver inlet:(NSUInteger)inlet
{
    NSString *s = [NSString stringWithFormat:@"%@",@(sender)];
    NSString *o = [NSString stringWithFormat:@"%@",@(outlet)];
    NSString *r = [NSString stringWithFormat:@"%@",@(receiver)];
    NSString *i = [NSString stringWithFormat:@"%@",@(inlet)];
    NSString *toAdd = [NSString stringWithFormat:@"#X connection %@ %@ %@ %@;\n",s,o,r,i];
    
    [self addEntry:toAdd];
}

- (void)removeObject:(NSUInteger)index
{
    NSString *toRemove = self.objectEntries[index];
    NSLog(@"remove object entry:%@",toRemove);
}

- (void)removeConnection:(NSUInteger)index
{
    
}

- (NSUInteger)addObject:(NSString *)object
{
    if (!self.objectEntries) {
        self.objectEntries = [NSMutableArray array];
    }
    
    [self.objectEntries addObject:object];
    return self.objectEntries.count - 1;
}

- (void)addEntry:(NSString *)entry
{
    if (!self.patchText) {
        self.patchText = [[NSMutableString alloc]init];
    }
    
    [self.patchText appendString:entry];
}

- (NSInteger)entryCount
{
    if (!self.patchText) {
        return 0;
    }
    NSArray *components = [self.patchText componentsSeparatedByString:@";\n"];
    return components.count;
}

- (void)clear
{
    self.patchText = nil;
}

- (void)print
{
    NSString *desc = [self getDescription];
    NSLog(@"\n\n%@\n\n",desc);
}

- (instancetype)initWithCanvasRect:(CGRect)rect
{
    self = [super init];
    if (self) {
        NSString *x = [NSString stringWithFormat:@"%@",@((NSInteger)rect.origin.x)];
        NSString *y = [NSString stringWithFormat:@"%@",@((NSInteger)rect.origin.y)];
        NSString *w = [NSString stringWithFormat:@"%@",@((NSInteger)rect.size.width)];
        NSString *h = [NSString stringWithFormat:@"%@",@((NSInteger)rect.size.height)];
        _canvasText = [NSString stringWithFormat:@"#N canvas %@ %@ %@ %@;\n",x,y,w,h];
        _patchDescriptionUtility = [[BSDPatchDescriptionUtility alloc]init];
    }
    
    return self;
}

@end
