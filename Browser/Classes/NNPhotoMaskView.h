//  NNPhotoMaskView.h
//  Pods
//
//  Created by  XMFraker on 2018/1/9
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNPhotoMaskView
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <UIKit/UIKit.h>
#import <NNPhoto/NNPhotoBrowserController.h>

typedef NS_ENUM(NSUInteger, NNPhotoMaskViewHandlerMode) {
    /** download origin image */
    NNPhotoMaskViewHandlerModeDownloadOrigin,
    /** save image to album */
    NNPhotoMaskViewHandlerModeSaveAlbum,
};

@interface NNPhotoMaskView : UIView <NNPhotoBrowserControllerDelegate>
/** IBEvents Action will be called in handler */
@property (copy, nonatomic)   void(^handler)(NNPhotoMaskViewHandlerMode mode);
/**
 *  add your subviews on maskView
 *  @warnings not call [super setupUI] if you override this method
 */
- (void)setupUI;

@end
