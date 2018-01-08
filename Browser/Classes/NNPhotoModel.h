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

@property (assign, nonatomic) CGSize size;

@property (strong, nonatomic) UIImage *thumbnail;

@property (copy, nonatomic)   NSString *imagePath;
@property (strong, nonatomic, nullable, readonly) UIImage *image;

@property (copy, nonatomic, nullable)   NSString *originImagePath;
@property (strong, nonatomic, nullable, readonly) UIImage *originImage;
@property (assign, nonatomic, getter=isOriginDownloaded) BOOL originDownloaded;

- (instancetype)initWithImagePath:(NSString *)imagePath
                        thumbnail:(nullable UIImage *)thumbnail NS_DESIGNATED_INITIALIZER;

+ (CGSize)adjustImageSize:(CGSize)imageSize toFittingTargetSize:(CGSize)targetSize;

@end

@interface NNPhotoModel (NNDeprecated)
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
