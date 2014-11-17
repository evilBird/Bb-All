//
//  ViewController.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCloud/iCloud.h>
#import "BSDCanvasViewController.h"
#import "BlackBoxCategories.h"

@interface ViewController : UIViewController<iCloudDelegate,iCloudDocumentDelegate,BSDCanvasViewControllerDelegate>


@end

