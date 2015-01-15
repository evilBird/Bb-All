//
//  BSDViewController.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/14/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

static NSString *kRequestPresentationNotificationChannel = @"com.birdsound.bb.viewcontroller.present";
static NSString *kRequestDismissalNoficationChannel = @"com.birdsound.bb.viewcontroller.dismiss";

@interface BSDViewControllerRoot : BSDObject

//hot inlet: takes an integer. 1 = present view controller, 0 = dismiss view controller
//cold inlet: forwards to a BSDView object pointing to the view controller's view
//display inlet: add/display view controllers

@property (nonatomic,strong)BSDInlet *displayInlet;

@end


@interface BSDViewController : BSDObject

@property (nonatomic,strong)BSDOutlet *viewOutlet;

@end