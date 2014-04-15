//
//  LOPPhotosViewController.m
//  Selfix
//
//  Created by Pedro Lopes on 26/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPPhotosViewController.h"
#import "LOPReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>


@implementation LOPPhotosViewController

# pragma mark - Accessors

- (void)setLoading:(BOOL)loading {
	_loading = loading;
}

# pragma mark - UIViewController

-(instancetype)init {
    // start layout and set properties
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(106.0f, 106.0f);
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 1.0;
    layout.headerReferenceSize = CGSizeMake(0,36);
    
    // init boolean var for loading status
    self.loading = NO;
    
    return (self = [super initWithCollectionViewLayout:layout]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Anygram";
    
    // register DidBecomeActive (reload content)
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:UIApplicationDidBecomeActiveNotification object:nil];
   
    
    self.search = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    [self.search setReturnKeyType:UIReturnKeyGo];
    
    [self.search setBorderStyle:UITextBorderStyleNone];
    self.search.tintColor = [UIColor colorWithRed:0.0f green:76.0f/255 blue:147.0f/255 alpha:1];
    self.search.delegate = self;
    self.search.textAlignment = NSTextAlignmentCenter;
    self.search.font = [UIFont fontWithName:@"Avenir-Light" size:16.0f];
    self.search.layer.masksToBounds = YES;
    self.search.placeholder = @"Search anything!";
    self.search.textColor = [UIColor colorWithRed:0.0f green:112.0f/255 blue:213.0f/255 alpha:1];
    self.search.backgroundColor =  [UIColor whiteColor];
    self.search.clearButtonMode = UITextFieldViewModeUnlessEditing;
    
    // set search field
    
    // set title image
    UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64.0, 64.0)];
    [titleButton setImage:[UIImage imageNamed:@"shuffle"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(searchForToken) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton;
//    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shuffle"]];
    
    // right navigation shows camera
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera"] style:UIBarButtonItemStylePlain target:self action:@selector(showCamera)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStylePlain target:self action:@selector(showCamera)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"Avenir-Light" size:14.0f], NSFontAttributeName,nil] forState:UIControlStateNormal];
  
    
    // customize collection view
    [self.collectionView addSubview:self.search];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[LOPPhotoCell class] forCellWithReuseIdentifier:@"photo"];
    
    // refresh on pull down
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.0f green:112.0f/255 blue:213.0f/255 alpha:1];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    // load Instagram data
    self.accessToken = [SSKeychain passwordForService:@"instagram" account:@"anygram"];
    if(self.accessToken == nil ) {
        // no previous account, authorize
        [SimpleAuth authorize:@"instagram" options:@{@"scope":@[@"likes"]} completion:^(NSDictionary *responseObject, NSError *error) {
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credentials error!" message:@"Sorry! There was a problem with your Instagram credentials! Please try again!" delegate:nil cancelButtonTitle:@"Try again!" otherButtonTitles:nil];
                    [alert show];
                });
                [self showSignInButton];
                return;
            } else {
                
                // all ok, store token and load Instagram content
                if(responseObject[@"credentials"][@"token"]) {
                    self.accessToken = responseObject[@"credentials"][@"token"];
                    [SSKeychain setPassword:self.accessToken forService:@"instagram" account:@"anygram"];
                    [self showSignOutButton];
                    [self refresh];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credentials error!" message:@"Sorry! There was a problem with your Instagram credentials! Please try again!"delegate:nil cancelButtonTitle:@"Try again!" otherButtonTitles:nil];
                        [alert show];
                    });
                    [self showSignInButton];
                    return;
                }
            }
        }];
    } else {
        // account already available, load Instagram content
        [self showSignOutButton];
        [self refresh];
    }
}

# pragma mark - UICollectionViewController

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LOPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photo" forIndexPath:indexPath];
    cell.photo = self.photos[indexPath.row];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *photo = self.photos[indexPath.row];
    
    LOPDetailViewController *detailView = [[LOPDetailViewController alloc] init];
    detailView.modalPresentationStyle = UIModalPresentationCustom;
    detailView.transitioningDelegate = self;
    detailView.photo = photo;
    
    [self presentViewController:detailView animated:YES completion:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.search resignFirstResponder];
}

# pragma mark - UIViewControllerTransitioningDelegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[LOPPresentDetailTransition alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[LOPDismissDetailTransition alloc] init];
}

# pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length) {
        [self searchForToken];
        return YES;
    }
    
    return NO;
}

# pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.search becomeFirstResponder];
}

# pragma mark - UIImagePickerController
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // load image from picker
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // dismiss picker
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([MGInstagram isAppInstalled]) {
            [MGInstagram postImage:image inView:self.view];
        }
        else
        {
            NSMutableArray *sharingItems = [NSMutableArray new];
            NSString *shareText = @"via #selfix #selfie http://pedrolopes.net/selfix/";
            [sharingItems addObject:shareText];
            [sharingItems addObject:image];
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
            [self presentViewController:activityController animated:YES completion:nil];
            
        }
    }];
}


# pragma mark - Actions
-(void)searchForToken {
    
    self.searchToken = [[NSMutableString alloc] initWithString:[self.search.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [[SAMCache sharedCache] setObject:self.searchToken forKey:@"searchToken"];
    
    [self refresh];
    [self.search resignFirstResponder];
}

-(void)refresh {
    self.searchToken = [[SAMCache sharedCache] objectForKey:@"searchToken"];
    if (self.searchToken == nil) {
        self.searchToken = [[NSMutableString alloc] initWithString:@"infinity"];
    }
    
    if([self connected]){
        if (self.loading) {
            return;
        }
        
        self.loading = YES;
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?access_token=%@",self.searchToken, self.accessToken ];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            NSData *data = [[NSData alloc] initWithContentsOfURL:location];
            if(data.length > 0) {
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                self.photos = [responseDictionary valueForKeyPath:@"data"];

            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.refreshControl endRefreshing];
                    self.loading = NO;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram error!" message:@"Sorry! There's something wrong with Instagram and we can't load picture pictures... Please try again!" delegate:self cancelButtonTitle:@"Try again" otherButtonTitles:nil];
                    [alert show];
                });
              
            }
            
             // finish by async reloading the collection view
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self.refreshControl endRefreshing];
                self.loading = NO;
            });
            
        }];
        
        [task resume];
    }
    // no internet!
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error!" message:@"Please check your Internet connection, you need an Internet connection to use Anygram!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

/*
 *  Shows system Camera.
 */
-(void)showCamera {
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    [self presentViewController:picker animated:YES completion:nil];
}

/*
 *  User sign out (remove from keychain).
 */
-(void)signOut {
    [SSKeychain deletePasswordForService:@"instagram" account:@"anygram"];
    self.accessToken = nil;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signed out!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.photos = nil;
        [self.collectionView reloadData];
        [self showSignInButton];
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}

/**
 *  User sign in.
 */
-(void)signIn {
    if(self.accessToken == nil ) {
        [SimpleAuth authorize:@"instagram" options:@{@"scope":@[@"likes"]} completion:^(NSDictionary *responseObject, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credentials error!" message:@"Sorry! There was a problem with your Instagram credentials! Please try again!" delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles:nil];
                    [alert show];
                });
                [self showSignInButton];
                return;
            } else {
                self.accessToken = responseObject[@"credentials"][@"token"];
                [SSKeychain setPassword:self.accessToken forService:@"instagram" account:@"anygram"];
                [self showSignOutButton];
                [self refresh];
            }
        }];
        
    } else {
        [self refresh];
    }
}

/**
 *  Change leftBartButtonItem to sign in on sign out.
 **/
-(void)showSignInButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign in" style:UIBarButtonItemStylePlain target:self action:@selector(signIn)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    [UIFont fontWithName:@"Avenir-Light" size:14.0f], NSFontAttributeName,nil] forState:UIControlStateNormal];
}

/**
 *  Change leftBartButtonItem to sign out on sign in.
 **/
-(void)showSignOutButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    [UIFont fontWithName:@"Avenir-Light" size:14.0f], NSFontAttributeName,nil] forState:UIControlStateNormal];
}


/**
 *  Check if there's an internet connection available.
 */
-(BOOL)connected {
    LOPReachability *reachability = [LOPReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}


@end
