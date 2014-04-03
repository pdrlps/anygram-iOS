//
//  LOPPhotoCell.h
//  Selfix
//
//  Created by Pedro Lopes on 27/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOPPhotoController.h"
#import <SSKeychain/SSKeychain.h>

@interface LOPPhotoCell : UICollectionViewCell

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) NSDictionary *photo;

@end
