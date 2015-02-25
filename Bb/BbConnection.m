//
//  BbConnection.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/20/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbConnection.h"
#import "NSMutableString+Bb.h"
#import "BbPatch.h"

@interface BbConnection ()

@property (nonatomic)                               NSUInteger      ancestors;
//If any of the BbEntitys are deleted
@property (nonatomic,readonly,getter=isDirty)       BOOL            isDirty;

@end

@implementation BbConnection

+ (BbConnection *)newWithOutlet:(BbOutlet *)outlet inlet:(BbInlet *)inlet
{
    BbConnection *connection = [[BbConnection alloc]init];
    connection.outlet = outlet;
    connection.sender = outlet.parent;
    connection.inlet = inlet;
    connection.receiver = inlet.parent;
    connection.parent = connection.sender.parent;
    connection.ancestors = [connection.parent countAncestors] + 1;
    return connection;
}

+ (BbConnection *)connectOutlet:(BbOutlet *)outlet toInlet:(BbInlet *)inlet
{
    BbConnection *connection = [BbConnection newWithOutlet:outlet
                                                     inlet:inlet];
    [connection connect];
    return connection;
}

- (NSInteger)connect
{
    if (self.isDirty) {
        return -1;
    }
    [self.outlet connectToInlet:self.inlet];
    
    return 0;
}

- (NSInteger)disconnect
{
    if (self.isDirty) {
        return -1;
    }
    
    [self.outlet disconnectFromInlet:self.inlet];
    
    return 0;
}

- (NSString *)textDescription
{
    NSMutableString *desc = [NSMutableString newDescription];
    [desc tabCt:[self countAncestors]];
    [desc appendThenSpace:@"#X"];
    [desc appendThenSpace:@"connect"];
    [desc appendThenSpace:@(self.senderIndex)];
    [desc appendThenSpace:@(self.outletIndex)];
    [desc appendThenSpace:@(self.receiverIndex)];
    [desc appendThenSpace:@(self.inletIndex)];
    [desc semiColon];
    [desc lineBreak];
    
    return desc;
}

- (BOOL)isConnected
{
    return (self.status == BbConnectionStatus_Connected);
}

- (BbConnectionStatus)status
{
    if (self.isDirty) {
        return BbConnectionStatus_Dirty;
    }else if (![self.outlet canConnectToInlet:self.inlet]){
        return BbConnectionStatus_TypeMismatch;
    }else if ([self.outlet.outputElement.observers containsObject:self.inlet.inputElement]){
        return BbConnectionStatus_Connected;
    }
    
    return BbConnectionStatus_NotConnected;
}

- (NSString *)connectionId
{
    return [NSString stringWithFormat:@"%@",@(self.objectId)];
}

- (NSInteger)senderIndex
{
    if (self.isDirty) {
        return -1;
    }
    
    return [self.sender.parent indexOfChild:self.sender];
}

- (NSInteger)outletIndex
{
    if (self.isDirty) {
        return -1;
    }
    
    return [self.outlet indexOfPort:self.outlet];
}


- (NSInteger)receiverIndex
{
    if (self.isDirty) {
        return -1;
    }
    
    return [self.receiver.parent indexOfChild:self.receiver];
}

- (NSInteger)inletIndex
{
    if (self.isDirty) {
        return -1;
    }
    
    return [self.receiver indexOfPort:self.inlet];
}

- (NSUInteger)hash
{
    if (self.isDirty) {
        return -1;
    }
    
    BbEntity *dad = (BbEntity *)self.parent;
    return ((([dad objectId]/1000) + (self.sender.objectId/1000 + self.outlet.objectId/1000) + (self.receiver.objectId/1000 + self.inlet.objectId/1000))/1000);
}

//If any of the BbEntitys are deleted
- (BOOL)isDirty
{
    return (self.sender && self.outlet && self.receiver && self.inlet);
}

- (void)tearDown
{
    if (self.isConnected && !self.isDirty) {
        [self disconnect];
    }
    
    self.outlet = nil;
    self.inlet = nil;
    self.parent = nil;
    self.sender = nil;
    self.receiver = nil;
    
    [super tearDown];
}

- (void)dealloc
{
    [self tearDown];
}


@end
