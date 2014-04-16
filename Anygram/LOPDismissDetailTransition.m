//
//  LOPDismissDetailTransition.m
//  Selfix
//
//  Created by Pedro Lopes on 28/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPDismissDetailTransition.h"

@implementation LOPDismissDetailTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *detail = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:0.5 animations:^{
        // end transition with from at full transparency
        detail.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [detail.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

@end
