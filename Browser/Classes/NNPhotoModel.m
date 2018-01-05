//  NNPhotoModel.m
//  Pods
//
//  Created by  XMFraker on 2018/1/2
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNPhotoModel
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNPhotoModel.h"

#import <YYWebImage/YYWebImage.h>

@implementation NNPhotoModel
@synthesize image = _image;
@synthesize originImage = _originImage;

#pragma mark - Life Cycle

- (instancetype)init {
    
    NSAssert(NO, @"use initWithImagePath:thumbnail: insteaded");
    return [self initWithImagePath:@"" thumbnail:nil];
}

- (instancetype)initWithImagePath:(NSString *)imagePath
                        thumbnail:(UIImage *)thumbnail {
    
    if (self = [super init]) {
        _thumbnail = thumbnail ? : [YYImage yy_imageWithColor:[UIColor blackColor] size:CGSizeMake([UIScreen mainScreen].bounds.size.width, 400)];
        _imagePath = [imagePath copy];
    }
    return self;
}

#pragma mark - Getter

- (CGSize)size {
    
    if (CGSizeEqualToSize(_size, CGSizeZero)) {
        if (_originImage) return _originImage.size;
        if (_image) return _image.size;
        if (_thumbnail) return _thumbnail.size;
    }
    return _size;
}

- (UIImage *)image {
    
    if (_image) return _image;
    if (!self.imagePath.length) return nil;
    if ([self.imagePath hasPrefix:@"http"]) {
        NSString *cacheKey = [[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:self.imagePath]];
        _image = [[YYWebImageManager sharedManager].cache getImageForKey:cacheKey];
    } else {
        _image = [UIImage imageWithContentsOfFile:self.imagePath];
    }
    return _image;
}

- (UIImage *)originImage {
    
    if (_originImage) return _originImage;
    if (!self.originImagePath.length) return nil;
    if ([self.originImagePath hasPrefix:@"http"]) {
        NSString *cacheKey = [[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:self.originImagePath]];
        _originImage = [[YYWebImageManager sharedManager].cache getImageForKey:cacheKey];
    } else {
        _originImage = [UIImage imageWithContentsOfFile:self.originImagePath];
    }
    return _originImage;
}

- (BOOL)isOriginDownloaded {
    
    return self.originImage != nil;
}

#pragma mark - Class

+ (CGSize)adjustImageSize:(CGSize)imageSize toFittingTargetSize:(CGSize)targetSize {
    
    CGSize result = imageSize;
    const CGFloat wPercent = imageSize.width / targetSize.width;
    const CGFloat hPercent = imageSize.height / targetSize.height;
    if (wPercent > 1.f && hPercent > 1.f) {
        if (wPercent > hPercent) {
            // 处理图片宽度 > 屏幕高度情况, 宽度撑满, 高度等比适应
            result.width = targetSize.width;
            result.height = targetSize.width * imageSize.height / imageSize.width;
        } else {
            // 处理图片高度 > 屏幕高度情况, 高度撑满, 宽度等比适应
            result.width = targetSize.height * imageSize.width / imageSize.height;
            result.height = targetSize.height;
        }
    } else if (wPercent > 1.f && hPercent < 1.f) {
        // 处理图片宽度 > 屏幕高度情况, 宽度撑满, 高度等比适应
        result.width = targetSize.width;
        result.height = targetSize.width * imageSize.height / imageSize.width;
    } else if (wPercent < 1.f && hPercent > 1.f) {
        // 处理图片高度 > 屏幕高度情况, 高度撑满, 宽度等比适应
        result.width = targetSize.height * imageSize.width / imageSize.height;
        result.height = targetSize.height;
    }
    return result;
}

@end
