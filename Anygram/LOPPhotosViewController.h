//
//  LOPPhotosViewController.h
//  Selfix
//
//  Created by Pedro Lopes on 26/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOPPhotoCell.h"
#import "LOPDetailViewController.h"
#import "LOPPresentDetailTransition.h"
#import "LOPDismissDetailTransition.h"
#import <SimpleAuth/SimpleAuth.h>
#import <SSKeychain/SSKeychain.h>
#import <SSKeychain/SSKeychainQuery.h>
#import <SAMCache/SAMCache.h>

@interface LOPPhotosViewController : UICollectionViewController <UIViewControllerTransitioningDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIAlertViewDelegate>

@property (nonatomic) NSString *accessToken;
@property (nonatomic) NSMutableString *searchToken;
@property (nonatomic) NSMutableArray *photos;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) UITextField *search;
@property (nonatomic) BOOL loading;

-(BOOL)connected;

@end
