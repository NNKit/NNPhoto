//
//  NNPhotoBrowserTransition.m
//
//
//  Created by XMFraker on 16/6/14.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "NNPhotoBrowserTransition.h"
#import "NNPhotoBrowserController.h"
#import "NNPhotoBrowserCell.h"
#import "NNPhotoMaskView.h"
#import "NNPhotoModel.h"

#import <YYWebImage/YYWebImage.h>

@interface NNPhotoBrowserController (NNPrivate)
@property (assign, nonatomic) NSInteger firstBrowserIndex;
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation NNPhotoBrowserPresentTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return .4f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    //获取两个VC 和 动画发生的容器
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NNPhotoBrowserController *browserVC = nil;
    if ([toVC isKindOfClass:[NNPhotoBrowserController class]]) {
        browserVC = (NNPhotoBrowserController *)toVC;
    } else if ([toVC isKindOfClass:[UINavigationController class]]
               && [[(UINavigationController *)toVC topViewController] isKindOfClass:[NNPhotoBrowserController class]]) {
        browserVC = (NNPhotoBrowserController *)[(UINavigationController *)toVC topViewController];
    }
    if (!browserVC) return;
    
    UIView *containerView = [transitionContext containerView];
    
    NNPhotoModel *photo = [browserVC.photos objectAtIndex:browserVC.currentIndex];
    [photo image];
    const CGSize size = [NNPhotoModel adjustImageSize:photo.size toFittingTargetSize:toVC.view.bounds.size];
    
    UIView *snapshotView;
    if (browserVC.sourceView) {
        if ([browserVC.sourceView isKindOfClass:[UIImageView class]]) {
            snapshotView = [[UIImageView alloc] initWithImage:[(UIImageView *)browserVC.sourceView image]];
        } else {
            snapshotView = [browserVC.sourceView snapshotViewAfterScreenUpdates:YES];
        }
        snapshotView.frame = [containerView convertRect:browserVC.sourceView.frame fromView:browserVC.sourceView.superview ? : fromVC.view];
    } else {
        snapshotView = [[UIImageView alloc] initWithImage:photo.image ? : photo.thumbnail];
        snapshotView.frame = CGRectMake(0, 0, size.width, size.height);
        snapshotView.center = containerView.center;
        snapshotView.transform = CGAffineTransformMakeScale(.1f, .1f);
    }
    snapshotView.clipsToBounds = YES;
    snapshotView.contentMode = UIViewContentModeScaleAspectFill;
    
    //设置第二个控制器的位置、透明度
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
//    browserVC.maskView.frame = containerView.bounds;
    browserVC.collectionView.hidden = browserVC.maskView.hidden = YES;
    
    //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapshotView];
    
    //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:CGFLOAT_MIN
         usingSpringWithDamping:.8f
          initialSpringVelocity:1.f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [containerView layoutIfNeeded];
                         toVC.view.alpha = 1.0;
                         snapshotView.frame = CGRectMake(0, 0, size.width, size.height);
                         snapshotView.center = containerView.center;
                         snapshotView.layer.cornerRadius = .0f;
                     } completion:^(BOOL finished) {
                         [self handlePresentTranistionCompletionWithContainerView:containerView
                                                                     snapshotView:snapshotView
                                                                             toVC:browserVC
                                                                transitionContext:transitionContext];
                     }];
}

/**
 处理切换动画完成后, 显示图片尺寸已经发生变化, 更新snapshotView.frame
 */
- (void)handlePresentTranistionCompletionWithContainerView:(UIView *)containerView
                                              snapshotView:(UIView *)snapshotView
                                                      toVC:(NNPhotoBrowserController *)toVC
                                         transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    NNPhotoBrowserCell *visiableCell = (NNPhotoBrowserCell *)[toVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:toVC.currentIndex inSection:0]];
    BOOL animated = (!CGSizeEqualToSize(snapshotView.bounds.size, visiableCell.imageView.bounds.size));
    // 检查当前显示cell图片大小是否已经改变, 如果改变重新适应
    [UIView animateWithDuration:animated ? .2f : CGFLOAT_MIN animations:^{
        snapshotView.frame = CGRectMake(0, 0, visiableCell.imageView.bounds.size.width, visiableCell.imageView.bounds.size.height);
        snapshotView.center = containerView.center;
    } completion:^(BOOL finished) {
        toVC.sourceView.hidden = NO;
        toVC.collectionView.hidden = toVC.maskView.hidden = NO;
        [snapshotView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end


@implementation NNPhotoBrowserDismissTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.4f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{

    UIViewController *toVC = nil; UIViewController *fromVC = nil; NNPhotoBrowserController *browserVC = nil;
    [self paraseTransitionContext:transitionContext fromVC:&fromVC toVC:&toVC browserVC:&browserVC];
    if (!browserVC) return;
    UIView *containerView = [transitionContext containerView];
    
    /** 如果当前index == firstBrowserIndex 使用返回到之前页面的动画 */
    if (browserVC.sourceView && (browserVC.currentIndex == browserVC.firstBrowserIndex)) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:browserVC.currentIndex inSection:0];
        NNPhotoBrowserCell *browserCell = (NNPhotoBrowserCell *)[browserVC.collectionView cellForItemAtIndexPath:indexPath];
        /** 配置动画view */
        UIImageView *snapshotView = [[UIImageView alloc] initWithImage:browserCell.imageView.image];
        snapshotView.contentMode = UIViewContentModeScaleAspectFill;
        snapshotView.clipsToBounds = YES;
        snapshotView.frame = [containerView convertRect:browserCell.imageView.frame fromView:browserCell.imageView.superview ? : fromVC.view];
        
        /** 隐藏 返回的view */

        browserCell.hidden = YES;

        //设置第二个控制器的位置、透明度
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        toVC.view.alpha = 0;
        
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapshotView];
        
        const CGRect finallyFrame = [containerView convertRect:browserVC.sourceView.frame fromView:browserVC.sourceView.superview ? : toVC.view];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            [containerView layoutIfNeeded];
            toVC.view.alpha = 1.f;
            fromVC.view.alpha = .0f;
            snapshotView.frame = finallyFrame;
        } completion:^(BOOL finished) {
            
            browserVC.sourceView.hidden = NO;
            [snapshotView removeFromSuperview];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else {
        /** sourceview 未设置 ,使用另外种转场方式 */
        [self normalDismissTranistionWithContext:transitionContext];
    }
}

- (void)normalDismissTranistionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    //获取两个VC 和 动画发生的容器
    UIViewController *toVC = nil; UIViewController *fromVC = nil; NNPhotoBrowserController *browserVC = nil;
    [self paraseTransitionContext:transitionContext fromVC:&fromVC toVC:&toVC browserVC:&browserVC];
    if (!browserVC) return;
    UIView *containerView = [transitionContext containerView];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:browserVC.currentIndex inSection:0];
    NNPhotoBrowserCell *browserCell = (NNPhotoBrowserCell *)[browserVC.collectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *snapShotView = [[UIImageView alloc] initWithImage:browserCell.imageView.image];
    snapShotView.clipsToBounds = YES;
    snapShotView.contentMode = UIViewContentModeScaleAspectFill;
    snapShotView.frame = [containerView convertRect:browserCell.imageView.frame fromView:browserCell.imageView.superview ? : browserVC.view];
    
    //设置第二个控制器的位置、透明度
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapShotView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        [containerView layoutIfNeeded];
        toVC.view.alpha = 1.f;
        snapShotView.alpha = .0f;
        snapShotView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        
        browserVC.sourceView.hidden = NO;
        [snapShotView removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)paraseTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
                         fromVC:(inout __kindof UIViewController **)fromVC
                           toVC:(inout __kindof UIViewController **)toVC
                      browserVC:(inout UIViewController **)browserVC {
    
    *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([*fromVC isKindOfClass:[NNPhotoBrowserController class]]) {
        *browserVC = (NNPhotoBrowserController *)*fromVC;
    } else if ([*fromVC isKindOfClass:[UINavigationController class]]
               && [[(UINavigationController *)*fromVC topViewController] isKindOfClass:[NNPhotoBrowserController class]]) {
        *browserVC = (NNPhotoBrowserController *)[(UINavigationController *)*fromVC topViewController];
    }
}

@end
