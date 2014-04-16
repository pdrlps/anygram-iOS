//
//  LOPPresentDetailTransition.m
//  Selfix
//
//  Created by Pedro Lopes on 28/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPPresentDetailTransition.h"

@implementation LOPPresentDetailTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *detail = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    // start transition is transparent
    detail.view.alpha = 0.0f;
    
    CGRect frame = containerView.bounds;
    detail.view.frame = frame;
    
    [containerView addSubview:detail.view];
    
    [UIView animateWithDuration:0.5 animations:^{
        // end transition is full view
        detail.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

@end
