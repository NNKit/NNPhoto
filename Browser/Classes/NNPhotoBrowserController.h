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
@class NNPhotoMaskView;
@class NNPhotoBrowserController;

NS_ASSUME_NONNULL_BEGIN

@protocol NNPhotoBrowserControllerDelegate <NSObject>

- (void)browser:(NNPhotoBrowserController *)browser willDisplayPhoto:(NNPhotoModel *)photo;
- (void)browser:(NNPhotoBrowserController *)browser didDisplayPhoto:(NNPhotoModel *)photo;

@end


@interface NNPhotoBrowserController : UIViewController

/** delegate */
@property (weak, nonatomic) id<NNPhotoBrowserControllerDelegate> delegate;
/** current photo index */
@property (assign, nonatomic) NSUInteger currentIndex;
/** sourceView will determine animation to show */
@property (weak, nonatomic, nullable) UIView *sourceView;
/** photos will be displayed */
@property (copy, nonatomic, readonly, nullable)   NSArray<NNPhotoModel *> *photos;
/** mask view will be cover on browserController.view. Default NNPhotoMaskView instance */
@property (strong, nonatomic) __kindof NNPhotoMaskView<NNPhotoBrowserControllerDelegate> *maskView;

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


/**
 reveal photo's origin image if exists

 @param photo A photo model
 */
- (void)revealPhotoOriginImage:(NNPhotoModel *)photo;

/**
 save photo's image to ablum
 if photo's origin image exists and downloaded, will save origin image to ablum
 
 @param photo   A photo model
 @param handler handler called after saved completed
 */
- (void)savePhotoImageToAblum:(NNPhotoModel *)photo completionHandler:(void(^)(NSURL * _Nullable assetURL, NSError * _Nullable error))handler;
@end

NS_ASSUME_NONNULL_END
