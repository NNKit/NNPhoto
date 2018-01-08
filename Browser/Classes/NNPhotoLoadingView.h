//  NNPhotoLoadingView.h
//  Pods
//
//  Created by  XMFraker on 2018/1/8
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNPhotoLoadingView
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <UIKit/UIKit.h>

@interface NNPhotoLoadingView : UIView

@property (assign, nonatomic) CGFloat progress;

- (void)removeAllAnimations;
- (void)revealAnimation;
- (void)revealAnimationWithCompletionHandler:(nullable void(^)(void))handler;

@end
