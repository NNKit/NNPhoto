//  NNPhotoModel.h
//  Pods
//
//  Created by  XMFraker on 2018/1/2
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNPhotoModel
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NNPhotoModel : NSObject
/** Image's size */
@property (assign, nonatomic) CGSize size;
/** Image's placeholder */
@property (strong, nonatomic) UIImage *thumbnail;
/** image's path */
@property (copy, nonatomic)   NSString *imagePath;
/** downloaded image from image's path */
@property (strong, nonatomic, nullable, readonly) UIImage *image;

/** image's origin path */
@property (copy, nonatomic, nullable)   NSString *originImagePath;
/** downloaded image from image's origin path */
@property (strong, nonatomic, nullable, readonly) UIImage *originImage;
/** is origin image downloaded. Default NO. */
@property (assign, nonatomic, getter=isOriginDownloaded, readonly) BOOL originDownloaded;

/**
 create a photoModel

 @param imagePath  Image's path
 @param thumbnail  placeholder image
 @return a photoModel
 */
- (instancetype)initWithImagePath:(NSString *)imagePath
                        thumbnail:(nullable UIImage *)thumbnail NS_DESIGNATED_INITIALIZER;

/**
 get a new size which fitting target size
 
 @param imageSize  Image's size
 @param targetSize Target's size
 @return a new size which inside target's size
 */
+ (CGSize)adjustImageSize:(CGSize)imageSize toFittingTargetSize:(CGSize)targetSize;

@end

@interface NNPhotoModel (NNDeprecated)
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
