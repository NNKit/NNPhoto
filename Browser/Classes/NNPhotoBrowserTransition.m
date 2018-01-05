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
    NNPhotoBrowserController *toVC   = (NNPhotoBrowserController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (toVC.sourceView) {
        
        /** 判断sourceview 是否设置了 */
        UIView * snapShotView;
        if ([toVC.sourceView isKindOfClass:[UIImageView class]]) {
            snapShotView = [[UIImageView alloc] initWithImage:[(UIImageView *)toVC.sourceView image]];
        } else {
            snapShotView = [toVC.sourceView snapshotViewAfterScreenUpdates:YES];
        }
        snapShotView.clipsToBounds = YES;
        snapShotView.contentMode = UIViewContentModeScaleAspectFill;
        snapShotView.frame = [containerView convertRect:toVC.sourceView.frame fromView:toVC.sourceView.superview ? : fromVC.view];
        toVC.sourceView.hidden = YES;
        
        NNPhotoModel *photo = [toVC.photos objectAtIndex:toVC.currentIndex];
        [photo image];
        const CGSize size = [NNPhotoModel adjustImageSize:photo.size toFittingTargetSize:toVC.view.bounds.size];
        
        //设置第二个控制器的位置、透明度
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        toVC.view.alpha = 0;
        toVC.collectionView.hidden = YES;

        //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapShotView];
        
        //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            [containerView layoutIfNeeded];
            toVC.view.alpha = 1.0;
            snapShotView.frame = CGRectMake(0, 0, size.width, size.height);
            snapShotView.center = containerView.center;
            snapShotView.layer.cornerRadius = .0f;
        } completion:^(BOOL finished) {
            [self handlePresentTranistionCompletionWithContainerView:containerView
                                                        snapshotView:snapShotView
                                                                toVC:toVC
                                                   transitionContext:transitionContext];
        }];
    } else {
        /** sourceview 未设置 ,使用另外种转场方式 */
        [self normalPresentTranistionWithContext:transitionContext];
    }
}


- (void)normalPresentTranistionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    //获取两个VC 和 动画发生的容器
    NNPhotoBrowserController *toVC   = (NNPhotoBrowserController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    /** 创建一个snapShotView  */
    UIImageView *snapShotView = [[UIImageView alloc] init];
    snapShotView.contentMode = UIViewContentModeScaleAspectFill;
    snapShotView.layer.masksToBounds = YES;
    NNPhotoModel *photo = [toVC.photos objectAtIndex:toVC.currentIndex];
    snapShotView.image =   photo.image ? : photo.thumbnail;

    CGSize size = [NNPhotoModel adjustImageSize:photo.size toFittingTargetSize:toVC.view.bounds.size];
    snapShotView.frame = CGRectMake(0, 0, size.width, size.height);
    snapShotView.center = containerView.center;
    snapShotView.transform = CGAffineTransformMakeScale(.1f, .1f);

    //设置第二个控制器的位置、透明度
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    toVC.collectionView.hidden = YES;
    
    //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapShotView];
    
    //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
  
        [containerView layoutIfNeeded];
        toVC.view.alpha = 1.0;
        snapShotView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self handlePresentTranistionCompletionWithContainerView:containerView
                                                    snapshotView:snapShotView
                                                            toVC:toVC
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
    [UIView animateWithDuration:animated ? .15f : CGFLOAT_MIN animations:^{
        snapshotView.frame = CGRectMake(0, 0, visiableCell.imageView.bounds.size.width, visiableCell.imageView.bounds.size.height);
        snapshotView.center = containerView.center;
    } completion:^(BOOL finished) {
        toVC.sourceView.hidden = NO;
        toVC.collectionView.hidden = NO;
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

    //获取两个VC 和 动画发生的容器
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NNPhotoBrowserController *fromVC   = (NNPhotoBrowserController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (fromVC.sourceView && (fromVC.currentIndex == fromVC.firstBrowserIndex)) {
        /** 判断sourceview 是否设置了 */

        /** 如果当前index == firstBrowserIndex 使用返回到之前页面的动画 */
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:fromVC.currentIndex inSection:0];
        
        NNPhotoBrowserCell *browserCell = (NNPhotoBrowserCell *)[fromVC.collectionView cellForItemAtIndexPath:indexPath];
        
        /** 配置动画view */
        UIImageView *snapShotView = [[UIImageView alloc] initWithImage:browserCell.imageView.image];
        snapShotView.contentMode = UIViewContentModeScaleAspectFill;
        snapShotView.clipsToBounds = YES;
        snapShotView.frame = [containerView convertRect:browserCell.imageView.frame fromView:browserCell.imageView.superview ? : fromVC.view];
        
        /** 隐藏 返回的view */
        fromVC.sourceView.hidden = YES;
        browserCell.hidden = YES;

        //设置第二个控制器的位置、透明度
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        toVC.view.alpha = 0;
        
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapShotView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            [containerView layoutIfNeeded];
            toVC.view.alpha = 1.f;
            snapShotView.frame = [containerView convertRect:fromVC.sourceView.frame fromView:fromVC.sourceView.superview ? : toVC.view];
        } completion:^(BOOL finished) {
            
            fromVC.sourceView.hidden = NO;
            [snapShotView removeFromSuperview];
            //告诉系统动画结束
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else {
        /** sourceview 未设置 ,使用另外种转场方式 */
        [self normalDismissTranistionWithContext:transitionContext];
    }
}

- (void)normalDismissTranistionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    //获取两个VC 和 动画发生的容器
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NNPhotoBrowserController *fromVC   = (NNPhotoBrowserController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    /** 如果当前index == firstBrowserIndex 使用返回到之前页面的动画 */
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:fromVC.currentIndex inSection:0];
    
    NNPhotoBrowserCell *browserCell = (NNPhotoBrowserCell *)[fromVC.collectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *snapShotView = [[UIImageView alloc] initWithImage:browserCell.imageView.image];
    snapShotView.clipsToBounds = YES;
    snapShotView.contentMode = UIViewContentModeScaleAspectFill;
    snapShotView.frame = [containerView convertRect:browserCell.imageView.frame fromView:browserCell.imageView.superview ? : fromVC.view];
    
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
        
        [snapShotView removeFromSuperview];
        //告诉系统动画结束
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}


@end
