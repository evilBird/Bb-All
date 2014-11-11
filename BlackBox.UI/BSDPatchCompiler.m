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
#import "BSDInletBox.h"
#import "BSDOutletBox.h"

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
            [self parseText:string];
            BSDCanvas *canvas = [self makeCanvasWithString:string];
            [self.canvasOutlet output:canvas];
        }
    }else if (inlet == self.canvasInlet){
        BSDCanvas *canvas = inlet.value;
        if (canvas && [canvas isKindOfClass:[BSDCanvas class]]){
            NSString *string = [self makeStringWithCanvas:canvas];
            [self parseText:string];
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
                NSInteger senderIdx = [canvas.graphBoxes indexOfObject:b];
                NSInteger senderPortIdx = [b.outletViews indexOfObject:sendPort];
                NSInteger receiverIdx = [canvas.graphBoxes indexOfObject:receivePort.superview];
                BSDBox *receiver = (BSDBox *)receivePort.superview;
                NSInteger receiverPortIdx = [receiver.inletViews indexOfObject:receivePort];
                NSString *connection = [NSString stringWithFormat:@"#X connection %@ %@ %@ %@;\n",@(senderIdx),@(senderPortIdx),@(receiverIdx),@(receiverPortIdx)];
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
    CGRect rect = [self rectForType:boxClass];
    NSValue *arg = [NSValue valueWithCGRect:rect];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:initializer]];
    invocation.target = instance;
    invocation.selector = initializer;
    [invocation setArgument:&rect atIndex:2];
    [invocation invoke];
    
    [instance setValue:components[1] forKey:@"boxClassString"];
    CGFloat x = [components[2]floatValue];
    CGFloat y = [components[3]floatValue];
    CGPoint center = CGPointMake(x, y);
    [(UIView *)instance setCenter:center];
    NSString *className = components[4];
    [instance setValue:className forKey:@"className"];
    NSString *argString = nil;
    if (components.count > 5) {
        
        NSMutableString *mas = [[NSMutableString alloc]initWithString:components[5]];
        for (NSInteger i = 6; i < components.count; i++) {
            [mas appendFormat:@" %@",components[i]];
        }
        
        argString = [NSString stringWithString:mas];
        [instance setValue:arg forKey:@"argString"];
    }
    
    [instance initializeWithText:argString];

    return instance;
}


- (BSDCanvas *)addToCanvas:(BSDCanvas *)canvas withLines:(NSArray *)lines
{
    static NSString *currentCanvasName;
    
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
        currentCanvasName = canvas.name;
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
        }
    
    }else {
        BSDBox *box = (BSDBox *)[self viewWithText:newLine];
        NSInteger count = canvas.graphBoxes.count;
        box.tag = count;
        box.delegate = canvas;
        [canvas.graphBoxes addObject:box];
        [canvas addSubview:box];
        if ([box isKindOfClass:[BSDInletBox class]]) {
            if (!canvas.inlets) {
                canvas.inlets = [NSMutableArray array];
            }
            BSD2WayPort *port = [box object];
            [canvas.inlets addObject:port.inlets.firstObject];
        }else if ([box isKindOfClass:[BSDOutletBox class]]){
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

- (NSInteger)testWithString:(NSString *)string
{
    self.canvasOutlet.value = nil;
    self.stringOutlet.value = nil;
    self.canvasInlet.value = nil;
    self.stringInlet.value = nil;
    
    [self.stringInlet input:string];
    [self.canvasInlet input:self.canvasOutlet.value];
    NSString *result = [NSString stringWithString:self.stringOutlet.value];
    if ([result isEqualToString:string]) {
        return 0;
    }

    return 1;
}

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

- (NSString *)testPatch2
{
    NSString *result = @"#N canvas 0 0 1536 2048 testscreen;\n#N canvas 0 0 1536 2048 new;\n#X BSDGraphBox 263 261 BSDCompiledPatch testview;\n#X BSDGraphBox 391 415 BSDScreen;\n#X BSDBangControlBox 271 75 BSDBangBox;\n#X BSDGraphBox 567 264 BSDCompiledPatch testview;\n#X BSDBangControlBox 536 87 BSDBangBox;\n#X BSDInletBox 122 67 BSD2WayPort;\n#X BSDGraphBox 223 142 BSDTrigger b b;\n#X connection 0 0 1 2;\n#X connection 3 0 1 2;\n#X connection 5 0 6 0;\n#X connection 6 0 0 0;\n#X connection 6 1 3 0;\n#X BSDAbstractionBox 322 417 new;\n#X BSDInletBox 279 196 BSD2WayPort;\n#X connection 1 0 7 0;";
    return result;
}

- (BSDCanvas *)restoreCanvasWithText:(NSString *)text
{
    return [self parseText:text];
}

- (id)parseText:(NSString *)text
{
    //NSLog(@"\n\nBLACKBOX PARSE: \n\n%@\n\n",text);
    NSArray *lines = [text componentsSeparatedByString:@";\n"];
    NSInteger canvasCount = 0;
    NSInteger currentCanvas = 0;
    NSInteger lineNumber = 0;
    NSMutableArray *canvases = nil;
    for (NSString *currentLine in lines) {
        lineNumber ++;
        NSArray *components = [currentLine componentsSeparatedByString:@" "];
        NSString *flag = components.firstObject;
        if (components.count > 2) {
            if ([flag isEqualToString:@"#N"]) {
                BSDCanvas *canvas = [[BSDCanvas alloc]initWithDescription:currentLine];
                canvas.graphBoxes = [NSMutableArray array];
                canvas.inlets = [NSMutableArray array];
                canvas.outlets = [NSMutableArray array];
                if (!canvases) {
                    canvases = [NSMutableArray array];
                    canvas.parentCanvas = nil;
                    [canvases addObject:canvas];
                }else{
                    [canvases addObject:canvas];
                    canvas.delegate = canvas.parentCanvas.delegate;
                }
                canvasCount = canvases.count;
                currentCanvas = [canvases indexOfObject:canvas];
                if (currentCanvas > 0) {
                    canvas.parentCanvas = canvases[currentCanvas - 1];
                }
                
            }else {
                BSDCanvas *current = canvases[currentCanvas];
                NSString *type = components[1];
                if ([type isEqualToString:@"BSDAbstractionBox"]) {
                    id box = [self viewWithText:currentLine];
                    [box setObject:current];
                    if (components.count == 5) {
                        [box initializeWithText:components[4]];
                    }else if (components.count > 5){
                        [box initializeWithText:components[5]];
                    }
                    BSDCanvas *next = current.parentCanvas;
                    if (next) {
                        currentCanvas = [canvases indexOfObject:next];
                        [box setValue:next forKey:@"delegate"];
                        [next.graphBoxes addObject:box];
                        [next addSubview:box];
                    }else{
                        NSLog(@"error: canvas was dismissed too early!");
                    }
                    
                }else if ([type isEqualToString:@"connection"]) {
                    NSInteger senderIdx = [components[2] integerValue];
                    NSInteger senderPortIdx = [components[3]integerValue];
                    NSInteger receiverIdx = [components[4]integerValue];
                    NSInteger receiverPortIdx = [components[5]integerValue];
                    NSInteger boxCount = current.graphBoxes.count;
                    
                    if (senderIdx >= boxCount || receiverIdx >= boxCount) {
                        //NSLog(@"\n\nline %@ ERROR: connection %@.%@->%@.%@ %@ canvas %@ only has %@ boxes\n\n",@(lineNumber),@(senderIdx),@(senderPortIdx),@(receiverIdx),@(receiverPortIdx),current.name,@(currentCanvas),@(boxCount));
                    }else{
                        BSDBox *sender = current.graphBoxes[senderIdx];
                        BSDBox *receiver = current.graphBoxes[receiverIdx];
                        if (senderPortIdx >= sender.outletViews.count) {
                          //  NSLog(@"\n\nline %@ ERROR: connection %@.%@->%@.%@ sender box %@-%@-%@ only has %@ outlets\n\n",@(lineNumber),@(senderIdx),@(senderPortIdx),@(receiverIdx),@(receiverPortIdx),sender.boxClassString,sender.className,sender.argString,@(sender.outletViews.count));
                        }else if (receiverPortIdx >= receiver.inletViews.count){
                           // NSLog(@"\n\nline %@ ERROR: connection %@.%@->%@.%@ receiver box %@-%@-%@ only has %@ inlets\n\n",@(lineNumber),@(senderIdx),@(senderPortIdx),@(receiverIdx),@(receiverPortIdx),receiver.boxClassString,receiver.className,receiver.argString,@(receiver.inletViews.count));
                        }else{
                            [sender connectOutlet:senderPortIdx toInlet:receiverPortIdx inBox:receiver];
                          //  NSLog(@"\n\nline %@ connection in %@ canvas %@ (%@ boxes): %@.%@->%@.%@\n\n",@(lineNumber),current.name,@(currentCanvas),@(boxCount),@(senderIdx),@(senderPortIdx),@(receiverIdx),@(receiverPortIdx));
                        }
                    }
                }else{
                    id box = [self viewWithText:currentLine];
                    //BSDCanvas *current = canvases[currentCanvas - 1];
                    [box setValue:current forKey:@"delegate"];
                    [current.graphBoxes addObject:box];
                    [current addSubview:box];
                    if ([box isKindOfClass:[BSDInletBox class]]) {
                        BSD2WayPort *port = [box object];
                        if (!current.inlets) {
                            current.inlets = [NSMutableArray array];
                        }
                        [current.inlets addObject:port.inlets.firstObject];
                    }else if ([box isKindOfClass:[BSDOutletBox class]]){
                        BSD2WayPort *port = [box object];
                        if (!current.outlets) {
                            current.outlets = [NSMutableArray array];
                        }
                        
                        [current.outlets addObject:port.outlets.firstObject];
                    }
                }
            }
        }
    }
    BSDCanvas *mainCanvas = canvases.firstObject;
    [mainCanvas boxDidMove:nil];
    return mainCanvas;
}


- (NSArray *)restoreBoxesWithText:(NSString *)text
{
    if (!text) {
        return nil;
    }
    
    //NSLog(@"\n\nBLACKBOX PARSE: \n\n%@\n\n",text);
    NSArray *lines = [text componentsSeparatedByString:@";\n"];
    if (!lines) {
        return nil;
    }
    NSInteger canvasCount = 0;
    NSInteger currentCanvas = 0;
    NSInteger lineNumber = 0;
    NSMutableArray *canvases = nil;
    NSMutableArray *boxes = nil;
    for (NSString *currentLine in lines) {
        lineNumber ++;
        NSArray *components = [currentLine componentsSeparatedByString:@" "];
        NSString *flag = components.firstObject;
        if (components.count > 2) {
            if ([flag isEqualToString:@"#N"]) {
                BSDCanvas *canvas = [[BSDCanvas alloc]initWithDescription:currentLine];
                canvas.graphBoxes = [NSMutableArray array];
                canvas.inlets = [NSMutableArray array];
                canvas.outlets = [NSMutableArray array];
                if (!canvases) {
                    canvases = [NSMutableArray array];
                    canvas.parentCanvas = nil;
                    [canvases addObject:canvas];
                }else{
                    [canvases addObject:canvas];
                    canvas.delegate = canvas.parentCanvas.delegate;
                }
                canvasCount = canvases.count;
                currentCanvas = [canvases indexOfObject:canvas];
                if (currentCanvas > 0) {
                    canvas.parentCanvas = canvases[currentCanvas - 1];
                }
            }else {
                NSString *type = components[1];
                BSDCanvas *current = nil;
                if (canvases.count > 0 && currentCanvas < canvases.count) {
                    current = canvases[currentCanvas];
                }
                if ([type isEqualToString:@"BSDAbstractionBox"]) {
                    id box = [self viewWithText:currentLine];
                    [box setObject:current];
                    if (components.count == 5) {
                        [box initializeWithText:components[4]];
                    }else if (components.count > 5){
                        [box initializeWithText:components[5]];
                    }
                    BSDCanvas *next = current.parentCanvas;
                    if (next && [canvases containsObject:current]) {
                        currentCanvas = [canvases indexOfObject:next];
                        [box setValue:next forKey:@"delegate"];
                        [next.graphBoxes addObject:box];
                        [next addSubview:box];
                    }else{
                        if (!boxes) {
                            boxes = [NSMutableArray array];
                        }
                        
                        [boxes addObject:box];
                    }
                }else if ([type isEqualToString:@"connection"]) {
                    
                    NSInteger senderIdx = [components[2] integerValue];
                    NSInteger senderPortIdx = [components[3]integerValue];
                    NSInteger receiverIdx = [components[4]integerValue];
                    NSInteger receiverPortIdx = [components[5]integerValue];
                    NSArray *referenceArray = nil;
                    if (current) {
                        referenceArray = [NSArray arrayWithArray:current.graphBoxes];
                    }else{
                        referenceArray = boxes;
                    }
                    
                    NSInteger boxCount = referenceArray.count;
                    
                    if (senderIdx >= boxCount || receiverIdx >= boxCount) {

                    }else{
                        BSDBox *sender = referenceArray[senderIdx];
                        BSDBox *receiver = referenceArray[receiverIdx];
                        if (senderPortIdx >= sender.outletViews.count) {
                        }else if (receiverPortIdx >= receiver.inletViews.count){
                        }else{
                            [sender connectOutlet:senderPortIdx toInlet:receiverPortIdx inBox:receiver];
                        }
                    }
                }else{
                    id box = [self viewWithText:currentLine];
                    if (current) {
                        [box setValue:current forKey:@"delegate"];
                        [current.graphBoxes addObject:box];
                        [current addSubview:box];
                        if ([box isKindOfClass:[BSDInletBox class]]) {
                            BSD2WayPort *port = [box object];
                            [current.inlets addObject:port.inlets.firstObject];
                        }else if ([box isKindOfClass:[BSDOutletBox class]]){
                            BSD2WayPort *port = [box object];
                            [current.outlets addObject:port.outlets.firstObject];
                        }
                    }else{
                        if (!boxes) {
                            boxes = [NSMutableArray array];
                        }
                        
                        [boxes addObject:box];
                    }
                }
            }
        }
    }
    return boxes;
}

- (NSString *)saveCanvas:(BSDCanvas *)canvas
{
    if (!canvas) {
        return nil;
    }
    
    NSString *result = [NSString stringWithFormat:@"#N canvas %@ %@ %@ %@ %@;\n",@((NSInteger)canvas.frame.origin.x),@((NSInteger)canvas.frame.origin.y),@((NSInteger)canvas.frame.size.width),@((NSInteger)canvas.frame.size.height),canvas.name];
    
    if (!canvas && canvas.graphBoxes.count == 0)
    {
        return result;
    }
    
    NSString *boxes = [self saveBoxes:canvas.graphBoxes];
    NSString *conections = [self saveConnectionsBetweenBoxes:canvas.graphBoxes];
    
    return [NSString stringWithFormat:@"%@%@%@",result,boxes,conections];
}

- (NSString *)saveBoxes:(NSArray *)boxes
{
    if (!boxes) {
        return @"";
    }
    
    NSMutableString *result = [[NSMutableString alloc]init];
    for (BSDBox *box in boxes) {
        if ([box isKindOfClass:[BSDAbstractionBox class]]) {
            BSDCanvas *canvas = (BSDCanvas *)box.object;
            if (canvas) {
                NSString *savedCanvas = [self saveCanvas:canvas];
                [result appendString:savedCanvas];
                if (canvas.graphBoxes.count > 0) {
                    [result appendString:[self saveConnectionsBetweenBoxes:canvas.graphBoxes]];
                }
            }
        }
        
        [result appendString:@"#X "];
        [result appendFormat:@"%@ ",box.boxClassString];
        [result appendFormat:@"%@ %@ ",@(box.center.x),@(box.center.y)];
        if (box.argString) {
            [result appendFormat:@"%@ %@;\n",box.className,box.argString];
        }else{
            [result appendFormat:@"%@;\n",box.className];
        }
    }
    
    return [NSString stringWithString:result];
}

- (NSString *)saveConnectionsBetweenBoxes:(NSArray *)boxes
{
    if (!boxes) {
        return @"";
    }
    
    NSMutableString *result = [[NSMutableString alloc]init];
    for (BSDBox *aBox in boxes) {
        NSInteger senderIndex = [boxes indexOfObject:aBox];
        for (BSDPortView *senderPort in aBox.outletViews){
            NSInteger senderPortIndex = [aBox.outletViews indexOfObject:senderPort];
            for (BSDPortView *receiverPort in senderPort.connectedPortViews) {
                BSDBox *receiver = (BSDBox *)receiverPort.superview;
                NSInteger receiverIndex = [boxes indexOfObject:receiver];
                NSInteger receiverPortIndex = [receiver.inletViews indexOfObject:receiverPort];
                [result appendFormat:@"#X connection "];
                [result appendFormat:@"%@ ",@(senderIndex)];
                [result appendFormat:@"%@ ",@(senderPortIndex)];
                [result appendFormat:@"%@ ",@(receiverIndex)];
                [result appendFormat:@"%@;\n",@(receiverPortIndex)];
            }
        }
    }
    
    return [NSString stringWithString:result];
}

- (CGRect)rectForType:(NSString *)type
{
    if ([type isEqualToString:@"BSDGraphBox"]) {
        return CGRectMake(0, 0, 140, 44);
    }else if ([type isEqualToString:@"BSDNumberBox"]){
        return CGRectMake(100, 100, 72, 44);
    }else if ([type isEqualToString:@"BSDMessageBox"]){
        return CGRectMake(100, 100, 160, 44);
    }else if ([type isEqualToString:@"BSDBangControlBox"]){
        return CGRectMake(100, 100, 60, 60);
    }else if ([type isEqualToString:@"BSDCommentBox"]){
        return CGRectMake(100, 100, 200, 200);
    }else if ([type isEqualToString:@"BSDInletBox"]){
        return CGRectMake(100, 100, 80, 44);
    }else if ([type isEqualToString:@"BSDOutletBox"]){
        return CGRectMake(100, 100, 80, 44);
    }else if ([type isEqualToString:@"BSDAbstractionBox"]){
        return CGRectMake(0, 0, 140, 44);
    }else if ([type isEqualToString:@"BSDHSlider"]){
        return CGRectMake(0, 0, 200, 36);
    }
    
    return CGRectMake(0, 0, 44, 44);
}

@end
