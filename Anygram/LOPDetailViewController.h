//
//  LOPDetailViewController.h
//  Selfix
//
//  Created by Pedro Lopes on 28/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOPPhotoController.h"
#import "LOPMetadataView.h"
#import <SSKeychain/SSKeychain.h>

@interface LOPDetailViewController : UIViewController

@property (nonatomic) NSDictionary *photo;
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) LOPMetadataView *metadataView;

@end
