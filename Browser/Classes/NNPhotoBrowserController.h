//  NNPhotoBrowserController.h
//  Pods
//
//  Created by  XMFraker on 2018/1/2
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNPhotoBrowserController
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <UIKit/UIKit.h>

@class NNPhotoModel;

NS_ASSUME_NONNULL_BEGIN

@interface NNPhotoBrowserController : UIViewController

@property (assign, nonatomic) NSUInteger currentIndex;
@property (weak, nonatomic, nullable) UIView *sourceView;
@property (copy, nonatomic, readonly, nullable)   NSArray<NNPhotoModel *> *photos;

/**
 create NNPhotoBrowserController instance

 @param photos display photos
 @return NNPhotoBrowserController instance
 */
- (instancetype)initWithPhotos:(NSArray<NNPhotoModel *> *)photos;

/**
 show browserVC with UINavigationController

 @param controller parent controller
 */
- (void)showFromParentController:(__kindof UIViewController *)controller;
@end

NS_ASSUME_NONNULL_END
