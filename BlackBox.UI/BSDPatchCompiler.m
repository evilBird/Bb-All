//
//  BSDPatchCompiler.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/7/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPatchCompiler.h"
#import "BSDCanvas.h"
#import "BSDAbstractionBox.h"
#import "BSDGraphBox.h"
#import "BSDBangControlBox.h"
#import <objc/runtime.h>
#import "BSD2WayPort.h"

@implementation BSDPatchCompiler

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"patch compiler";
    
    self.stringInlet = [[BSDInlet alloc]initHot];
    self.stringInlet.name = @"string inlet";
    [self addPort:self.stringInlet];
    
    self.canvasInlet = [[BSDInlet alloc]initHot];
    self.canvasInlet.name = @"canvas inlet";
    [self addPort:self.canvasInlet];
    
    self.canvasOutlet = [[BSDOutlet alloc]init];
    self.canvasOutlet.name = @"canvas outlet";
    [self addPort:self.canvasOutlet];
    
    self.stringOutlet = [[BSDOutlet alloc]init];
    self.stringOutlet.name = @"string outlet";
    [self addPort:self.stringOutlet];

    
}

- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet{
    return nil;
}

- (BSDOutlet *)makeLeftOutlet
{
    return nil;
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.stringInlet) {
        NSString *string = inlet.value;
        if (string && [string isKindOfClass:[NSString class]]) {
            BSDCanvas *canvas = [self makeCanvasWithString:string];
            [self.canvasOutlet output:canvas];
        }
    }else if (inlet == self.canvasInlet){
        BSDCanvas *canvas = inlet.value;
        if (canvas && [canvas isKindOfClass:[BSDCanvas class]]){
            NSString *string = [self makeStringWithCanvas:canvas];
            [self.stringOutlet output:string];
        }
    }
}

- (BSDCanvas *)makeCanvasWithString:(NSString*)string
{
    return [self addToCanvas:nil withLines:[string componentsSeparatedByString:@";\n"]];
}

- (NSString *)makeStringWithCanvas:(BSDCanvas *)canvas
{
    return [self describeCanvas:canvas appendToString:nil];
}

- (NSString *)describeBox:(BSDBox *)box appendToString:(NSMutableString *)string
{
    if (!string) {
        string = [[NSMutableString alloc]initWithString:@""];
    }
    
    if ([box isKindOfClass:[BSDAbstractionBox class]]) {
        BSDCanvas *canvas = (BSDCanvas *)box.object;
        [string appendString:[self describeCanvas:canvas appendToString:string]];
        [string appendFormat:@"#X BSDAbstractionBox %@ %@ %@;\n",@((NSInteger)box.center.x),@((NSInteger)box.center.y),canvas.name];
        return string;
    }else{
        if (box.argString) {
            return [NSString stringWithFormat:@"#X %@ %@ %@ %@ %@;\n",box.boxClassString,@((NSInteger)box.center.x),@((NSInteger)box.center.y),box.className,box.argString];
        }else{
            return [NSString stringWithFormat:@"#X %@ %@ %@ %@;\n",box.boxClassString,@((NSInteger)box.center.x),@((NSInteger)box.center.y),box.className];
        }
    }
    
    return string;
}

- (NSString *)describeCanvas:(BSDCanvas *)canvas appendToString:(NSMutableString *)string
{
    if (!string) {
        string = [[NSMutableString alloc]initWithString:@""];
    }
    
    CGRect frame = canvas.frame;
    NSMutableString *newMutable = [[NSMutableString alloc]init];
    [newMutable appendFormat:@"#N canvas %@ %@ %@ %@ %@;\n",@((NSInteger)frame.origin.x),
     @((NSInteger)frame.origin.y),@((NSInteger)frame.size.width),@((NSInteger)frame.size.height),canvas.name];
    for (BSDBox *b in canvas.graphBoxes) {
        [newMutable appendString:[self describeBox:b appendToString:string]];
    }
    for (BSDBox *b in canvas.graphBoxes) {
        for (BSDPortView *sendPort in b.outletViews) {
            for (BSDPortView *receivePort in sendPort.connectedPortViews) {
                NSString *connection = [NSString stringWithFormat:@"#X connection %@ %@ %@ %@;\n",@(sendPort.superview.tag),@(sendPort.tag),@(receivePort.superview.tag),@(receivePort.tag)];
                [newMutable appendString:connection];
            }
        }
    }
    return [string stringByAppendingString:newMutable];

}

- (UIView *)viewWithText:(NSString *)text
{
    NSArray *components = [text componentsSeparatedByString:@" "];
    if (!components || components.count < 5) {
        return nil;
    }
    
    NSString *boxClass = components[1];
    const char *class = [boxClass UTF8String];
    id c = objc_getClass(class);
    id instance = [c alloc];
    SEL initializer = NSSelectorFromString(@"initWithFrame:");
    CGRect rect = [BSDCanvas rectForType:boxClass];
    NSValue *arg = [NSValue valueWithCGRect:rect];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:initializer]];
    invocation.target = instance;
    invocation.selector = initializer;
    [invocation setArgument:&arg atIndex:2];
    [invocation invoke];
    
    [instance setValue:components[1] forKey:@"boxClassString"];
    CGFloat x = [components[2]floatValue];
    CGFloat y = [components[3]floatValue];
    CGPoint center = CGPointMake(x, y);
    [instance setValue:[NSValue valueWithCGPoint:center] forKey:@"position"];
    NSString *className = components[4];
    [instance setValue:className forKey:@"className"];
    NSString *argString = nil;
    if (components.count > 5) {
        
        NSMutableString *mas = [[NSMutableString alloc]initWithString:components[5]];
        for (NSInteger i = 6; i < components.count; i++) {
            [mas appendFormat:@" %@",components[i]];
        }
        
        argString = [NSString stringWithString:mas];
    }
    
    [instance initializeWithText:argString];

    return instance;
}

- (BSDCanvas *)addToCanvas:(BSDCanvas *)canvas withLines:(NSArray *)lines
{
    if (!lines) {
        return canvas;
    }
    
    NSString *newLine = lines.firstObject;
    
    if (newLine.length < 2) {
        return canvas;
    }
    
    NSMutableArray *newLines = lines.mutableCopy;
    if (newLines.count == 0){
        return canvas;
    }
    [newLines removeObjectAtIndex:0];

    NSArray *components = [newLine componentsSeparatedByString:@" "];
    if ([newLine hasPrefix:@"#N"]) {
        BSDCanvas *newCanvas = [[BSDCanvas alloc]initWithDescription:newLine];
        newCanvas.graphBoxes = [NSMutableArray array];
        if (!canvas) {
            return [self addToCanvas:newCanvas withLines:newLines];
        }else{
            newCanvas.parentCanvas = canvas;
            [self addToCanvas:newCanvas withLines:newLines];
        }
    }else if ([newLine hasPrefix:@"#X"]){
        NSString *type = components[1];
        if ([type isEqualToString:@"BSDAbstractionBox"]) {
            NSString *name = components[4];
            if ([name isEqualToString:canvas.name]) {
                BSDBox *abs = (BSDBox *)[self viewWithText:newLine];
                abs.object = canvas;
                abs.delegate = canvas.parentCanvas;
                NSInteger count = canvas.parentCanvas.graphBoxes.count;
                abs.tag = count;
                [canvas.parentCanvas.graphBoxes addObject:abs];
                [canvas.parentCanvas addSubview:abs];
                return [self addToCanvas:canvas.parentCanvas withLines:newLines];
            }else{
                [self addToCanvas:canvas withLines:newLines];
            }
        }else if ([type isEqualToString:@"connection"]){
            NSInteger sendertag = [components[2] integerValue];
            NSInteger senderport = [components[3] integerValue];
            NSInteger receivetag = [components[4] integerValue];
            NSInteger receiveport = [components[5] integerValue];
            BSDBox *sender = canvas.graphBoxes[sendertag];
            BSDBox *receiver = canvas.graphBoxes[receivetag];
            BSDPortView *senderPortView = sender.outletViews[senderport];
            BSDPortView *receiverPortView = receiver.inletViews[receiveport];
            BSDOutlet *outlet = [[sender object]outlets][senderport];
            BSDInlet *inlet = [[receiver object]inlets][receiveport];
            [outlet connectToInlet:inlet];
            [senderPortView addConnectionToPortView:receiverPortView];
            [self addToCanvas:canvas withLines:newLines];
            
        }else {
            BSDBox *box = (BSDBox *)[self viewWithText:newLine];
            NSInteger count = canvas.graphBoxes.count;
            box.tag = count;
            box.delegate = canvas;
            [canvas.graphBoxes addObject:box];
            [canvas addSubview:box];
            if ([box isKindOfClass:[BSDPatchInlet class]]) {
                if (!canvas.inlets) {
                    canvas.inlets = [NSMutableArray array];
                }
                BSD2WayPort *port = [box object];
                [canvas.inlets addObject:port.inlets.firstObject];
            }else if ([box isKindOfClass:[BSDPatchOutlet class]]){
                if (!canvas.outlets) {
                    canvas.outlets = [NSMutableArray array];
                }
                BSD2WayPort *port = [box object];
                [canvas.outlets addObject:port.outlets.firstObject];
            }
            
            return [self addToCanvas:canvas withLines:newLines];
        }
        return canvas;
    }
    
    return canvas;
}

/*
- (BSDCanvas *)addToCanvas:(BSDCanvas *)canvas withLines:(NSArray *)lines
{
    if (!lines) {
        return canvas;
    }
    
    NSString *newLine = lines.firstObject;
    NSMutableArray *newLines = lines.mutableCopy;
    [newLines removeObjectAtIndex:0];
    NSArray *components = [newLine componentsSeparatedByString:@" "];
    if ([newLine hasPrefix:@"#N"]) {
        BSDCanvas *newCanvas = [[BSDCanvas alloc]initWithDescription:newLine];
        newCanvas.graphBoxes = [NSMutableArray array];
        if (!canvas) {
            return [self addToCanvas:newCanvas withLines:newLines];
        }else{
            [canvas.subcanvases addObject:[self addToCanvas:newCanvas withLines:newLines]];
        }
    }else if ([newLine hasPrefix:@"#X"] && [components[1] isEqualToString:@"restore"]){
        
        if (components.count < 5) {
            return [self addToCanvas:canvas withLines:newLines];
        }
        if (![components[4] isEqualToString:canvas.name]) {
            return [self addToCanvas:canvas withLines:newLines];
        }
        
        return canvas;
        
    }else if ([newLine hasPrefix:@"#X"]){
        [canvas.graphBoxes addObject:[self viewWithText:newLine]];
        return [self addToCanvas:canvas withLines:newLines];
    }
    
    return canvas;
}

*/




- (void)test
{
    //[self.hotInlet input:[self testPatch0]];
    NSString *test1 = [self testPatch1];
    [self.stringInlet input:test1];
    BSDCanvas *canvas = [self.canvasOutlet value];
    [self.canvasInlet input:canvas];
    NSString *testoutput = [self.stringOutlet value];
    NSLog(@"\nString input:\n%@\nString output:\n%@\n",test1,testoutput);
    
}

- (NSString *)testPatch0
{
    return @"#N canvas 0 0 786 1024 canvas1;\n#X BSDGraphBox 0 0 BSDRoute routeKey;\n#X BSDNumberBox 0 0 BSDNumber;\n#N canvas 0 0 786 1024 canvas2;\n#X BSDMessageBox 0 0 BSDMessage hello;\n#X restore 0 0 canvas2;\n";
}

- (NSString *)testPatch1
{
    return @"#N canvas 0 0 1536 2048 untitled;\n#X BSDGraphBox 291 209 BSDAdd 10;\n#X BSDGraphBox 236 124 BSDDivide 2;\n#X BSDGraphBox 256 281 BSDSubtract;\n#X connection 0 0 1 0;\n#X connection 1 0 2 0;\n";
}

@end
