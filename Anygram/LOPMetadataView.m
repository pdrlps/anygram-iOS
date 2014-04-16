//
//  LOPMetadataView.m
//  Selfix
//
//  Created by Pedro Lopes on 31/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPMetadataView.h"

@interface LOPMetadataView ()

@property (nonatomic) UIImageView *avatarImageView;
@property (nonatomic) UIButton *usernameButton;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) UIButton *likesButton;
@property (nonatomic) UIButton *commentsButton;

@end

@implementation LOPMetadataView

# pragma mark - Accessors

-(void)setImage:(UIImage *)image {
    _image = image;
}

- (void)setPhoto:(NSDictionary *)photo {
	_photo = photo;
    
    // likes
    NSString *likes = [[NSString alloc] initWithFormat:@"%@",[self.photo valueForKeyPath:@"likes.count"]];
    [self.likesButton setTitle:likes forState:UIControlStateNormal];
    
    //username
    [self.usernameButton setTitle:[self.photo valueForKeyPath:@"user.username"] forState:UIControlStateNormal];
    
    // comments
    NSArray *data = [self.photo valueForKeyPath:@"comments.data"];
    NSString *comments = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)data.count];
    [self.commentsButton setTitle:comments forState:UIControlStateNormal];
    
    // avatar
    UIImage *image = [[SAMCache sharedCache] imageForKey:[self.photo valueForKeyPath:@"user.username"]];
    if (image) {
        self.avatarImageView.image = image;
    } else {
        NSURL *url = [[NSURL alloc] initWithString:[self.photo valueForKeyPath:@"user.profile_picture"]];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            NSData *data = [[NSData alloc] initWithContentsOfURL:location];
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            [[SAMCache sharedCache] setImage:image forKey:[self.photo valueForKeyPath:@"user.username"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.avatarImageView.image = image;
            });
        }];
        
        [task resume];
    }
}

#pragma mark - Actions
/**
 *  Open user on tap on Instagram (if available) or web.
 *
 *  @param sender tapped button (user icon or username).
 */
- (void)openUser:(id)sender {
    NSURL *instagramUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"instagram://user?username=%@",[self.photo valueForKeyPath:@"user.username"]]];
    if ([[UIApplication sharedApplication] canOpenURL:instagramUrl]) {
        [[UIApplication sharedApplication] openURL:instagramUrl];
    } else {
        [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"http://instagram.com/%@",[self.photo valueForKeyPath:@"user.username"]]]];
    }
}

/**
 *  Open photo on tap on Instagram (if available) or web.
 *
 *  @param sender tapped button (comment button)
 */
- (void)openPhoto:(id)sender {
    NSURL *instagramUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"instagram://media?id=%@",[self.photo valueForKeyPath:@"id"]]];
    if ([[UIApplication sharedApplication] canOpenURL:instagramUrl]) {
        [[UIApplication sharedApplication] openURL:instagramUrl];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.photo[@"link"]]];
    }
}

/**
 *  Share photo link.
 *
 *  @param sender tapped button (share button)
 */
-(void)share:(id)sender {
    NSMutableArray *sharingItems = [NSMutableArray new];
    NSString *shareText = [[NSString alloc] initWithFormat:@"%@ via #anygram http://pedrolopes.net/anygram/",self.photo[@"link"] ];
    UIImage *shareImage = self.image;
        [sharingItems addObject:shareImage];
    [sharingItems addObject:shareText];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self.controller presentViewController:activityController animated:YES completion:nil];
}

/**
 *  Like tapped photo on Instagram.
 *
 *  @param sender tapped button (like button)
 */
-(void)like:(id)sender {

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/media/%@/likes?access_token=%@", self.photo[@"id"], [SSKeychain passwordForService:@"instagram" account:@"anygram"]];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showLikeCompletion];
        });
    }];
    
    [task resume];
}

/**
 *  Display UIAlertView with confirming "like" and updated like label.
 */
-(void)showLikeCompletion {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Liked!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    int likes = [self.likesButton.titleLabel.text integerValue];
    likes += 1;
    NSString *likeText = [[NSString alloc] initWithFormat:@"%d",likes];
    [self.likesButton setTitle:likeText forState:UIControlStateNormal];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}

#pragma mark - UIView
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self addSubview:self.usernameButton];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.shareButton];
        [self addSubview:self.likesButton];
        [self addSubview:self.commentsButton];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(320.0f, 400.0f);
}

#pragma mark - UIControls

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 32.0f, 32.0f)];
        _avatarImageView.layer.cornerRadius = 16.0f;
        _avatarImageView.layer.borderColor = [[self class] darkTextColor].CGColor;
        _avatarImageView.layer.borderWidth = 1.0f;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0f];
        _avatarImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUser:)];
        tap.numberOfTapsRequired = 1;
        [_avatarImageView addGestureRecognizer:tap];

    }
    return _avatarImageView;
}

- (UIButton *)usernameButton {
    if (!_usernameButton) {
        _usernameButton = [[UIButton alloc] initWithFrame:CGRectMake(47.0f, 0.0f, 200.0f, 32.0f)];
        _usernameButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.0f];
        _usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        UIColor *textColor = [[self class] lightTextColor];
        [_usernameButton setTitleColor:textColor forState:UIControlStateNormal];
        [_usernameButton setTitleColor:[textColor colorWithAlphaComponent:0.5f] forState:UIControlStateHighlighted];
        [_usernameButton addTarget:self action:@selector(openUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _usernameButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(260.0f, 0.0f, 64.0f, 64.0f)];
        [_shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        _shareButton.adjustsImageWhenHighlighted = NO;
        _shareButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 24.0f, 6.0f);
        _shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        [_shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

- (UIButton *)likesButton {
    if (!_likesButton) {
        _likesButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 350.0f, 64.0f, 64.0f)];
        _likesButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.0f];
        [_likesButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        _likesButton.adjustsImageWhenHighlighted = NO;
        _likesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _likesButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
        UIColor *textColor = [[self class] lightTextColor];
        [_likesButton setTitleColor:textColor forState:UIControlStateNormal];
        [_likesButton setTitleColor:[textColor colorWithAlphaComponent:0.5f] forState:UIControlStateHighlighted];
        [_likesButton addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likesButton;
}

- (UIButton *)commentsButton {
    if (!_commentsButton) {
        _commentsButton = [[UIButton alloc] initWithFrame:CGRectMake(240.0f, 350.0f, 64.0f, 64.0f)];
        _commentsButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.0f];
        [_commentsButton setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        _commentsButton.adjustsImageWhenHighlighted = NO;
        _commentsButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        _commentsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        UIColor *textColor = [[self class] lightTextColor];
        [_commentsButton setTitleColor:textColor forState:UIControlStateNormal];
        [_commentsButton setTitleColor:[textColor colorWithAlphaComponent:0.5f] forState:UIControlStateHighlighted];
        [_commentsButton addTarget:self action:@selector(openPhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentsButton;
}

#pragma mark - Private
+ (UIColor *)darkTextColor {
    return [UIColor whiteColor];
}


+ (UIColor *)lightTextColor {
    return [UIColor whiteColor];
}



@end
