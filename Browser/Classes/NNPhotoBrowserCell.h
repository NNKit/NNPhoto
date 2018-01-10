//  NNPhotoBrowserCell.h
//  Pods
//
//  Created by  XMFraker on 2018/1/2
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNPhotoBrowserCell
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NNPhotoBrowserCellHandlerMode) {
    NNPhotoBrowserCellHandlerModeSingleTap,
    NNPhotoBrowserCellHandlerModeLongPress,
};

@class NNPhotoModel;
@class YYAnimatedImageView;

NS_ASSUME_NONNULL_BEGIN

@interface NNPhotoBrowserCell : UICollectionViewCell
@property (nonatomic, strong, readonly) YYAnimatedImageView *imageView;
/** handler triggered when user tap or longPress imageView */
@property (copy, nonatomic, nullable)   void(^handler)(NNPhotoBrowserCell *cell, NNPhotoBrowserCellHandlerMode mode);

- (void)configCellWithItem:(NNPhotoModel *)item;
- (void)configCellWithItem:(NNPhotoModel *)item displayOriginal:(BOOL)displayOriginal;

@end

NS_ASSUME_NONNULL_END
