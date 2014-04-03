//
//  LOPDetailViewController.m
//  Selfix
//
//  Created by Pedro Lopes on 28/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPDetailViewController.h"

@interface LOPDetailViewController()

@property (nonatomic)   UIImageView *imageView;

@end

@implementation LOPDetailViewController

# pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // customize view
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    self.view.clipsToBounds = YES;
    
    // customize metadata
    self.metadataView = [[LOPMetadataView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0f, 400.0f)];
    self.metadataView.alpha = 0.0;
    self.metadataView.controller = self;
    self.metadataView.photo = self.photo;
    [self.view addSubview:self.metadataView];
    
    // customize image
    self.imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -320.0, 320.0, 320.0)];
    [LOPPhotoController imageForPhoto:self.photo size:@"standard_resolution" completion:^(UIImage *image) {
        self.imageView.image = image;
    }];
    [self.view addSubview:self.imageView];
    
    // dismiss gestures (tap + swipes)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    [self.view addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeUp];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    // customize animations
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGPoint center = self.view.center;
    
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.imageView snapToPoint:center];
    [self.animator addBehavior:snap];
    
    self.metadataView.center = center;
    [UIView animateWithDuration:0.5 delay:0.64 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:kNilOptions animations:^{
        self.metadataView.alpha = 1.0;
    } completion:nil];
}

# pragma mark - Action

-(void)close {
    [self.animator removeAllBehaviors];
    
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.imageView snapToPoint:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(self.view.bounds) + 180.0f)];
    [self.animator addBehavior:snap];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
