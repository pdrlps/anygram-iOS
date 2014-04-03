//
//  LOPMetadataView.h
//  Selfix
//
//  Created by Pedro Lopes on 31/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOPPhotoController.h"
#import <SAMCategories/NSDate+SAMAdditions.h>
#import <SSKeychain/SSKeychain.h>
#import <SAMCache/SAMCache.h>

@interface LOPMetadataView : UIView

@property (nonatomic) NSDictionary *photo;
@property (nonatomic) UIViewController *controller;

@end
