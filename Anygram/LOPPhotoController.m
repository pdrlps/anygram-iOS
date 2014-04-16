//
//  LOPPhotoController.m
//  Selfix
//
//  Created by Pedro Lopes on 28/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPPhotoController.h"

@implementation LOPPhotoController

# pragma mark - LOPPhotoController
+(void)imageForPhoto:(NSDictionary *)photo size:(NSString *)size completion:(void(^)(UIImage *image))completion {
    
    // must have all parameters
    if(photo == nil || size == nil || completion == nil ) {
        return;
    }
    
    // compose image name
    NSString *key = [[NSString alloc] initWithFormat:@"%@-%@",photo[@"id"], size];
    
    // check if image is on cache
    UIImage *image = [[SAMCache sharedCache] imageForKey:key];
    if (image) {
        completion(image);
        return;
    }
    
    // not on cache, load image
    NSURL *url = [[NSURL alloc] initWithString:photo[@"images"][size][@"url"]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        // store image on cache
        [[SAMCache sharedCache] setImage:image forKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    }];
    
    // always task resume
    [task resume];
}

@end
