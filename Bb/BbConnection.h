//
//  BbConnection.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/20/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbBase.h"
#import "BbObject.h"

typedef NS_ENUM(NSUInteger, BbConnectionStatus)
{
    BbConnectionStatus_Connected,
    BbConnectionStatus_NotConnected,
    BbConnectionStatus_TypeMismatch,
    BbConnectionStatus_Dirty,
};

@interface BbConnection : BbEntity

//Pointers to connection components
@property (nonatomic,strong)                            BbObject                *sender;
@property (nonatomic,strong)                            BbOutlet                *outlet;
@property (nonatomic,strong)                            BbObject                *receiver;
@property (nonatomic,strong)                            BbInlet                 *inlet;

//Unique Id
@property (nonatomic,readonly)                          NSString                *connectionId;

//Accessors
@property (nonatomic,readonly)                          NSInteger               senderIndex;
@property (nonatomic,readonly)                          NSInteger               outletIndex;
@property (nonatomic,readonly)                          NSInteger               receiverIndex;
@property (nonatomic,readonly)                          NSInteger               inletIndex;

//Connection Status
@property (nonatomic,readonly,getter=isConnected)       BOOL                    connected;
@property (nonatomic,readonly)                          BbConnectionStatus      status;

//selection status
@property (nonatomic)                                   BOOL                    selected;


+ (BbConnection *)newWithOutlet:(BbOutlet *)outlet
                          inlet:(BbInlet *)inlet;

+ (BbConnection *)connectOutlet:(BbOutlet *)outlet
                        toInlet:(BbInlet *)inlet;

- (NSInteger)connect;
- (NSInteger)disconnect;
- (void)tearDown;
- (NSString *)textDescription;

@end
