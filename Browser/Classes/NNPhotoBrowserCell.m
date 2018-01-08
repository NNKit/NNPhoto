//  NNPhotoBrowserCell.m
//  Pods
//
//  Created by  XMFraker on 2018/1/2
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNPhotoBrowserCell
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNPhotoBrowserCell.h"
#import "NNPhotoLoadingView.h"
#import "NNPhotoModel.h"
#import <YYWebImage/YYWebImage.h>

FOUNDATION_EXTERN CGFloat kNNPhotoBrowserPadding;

static const CGFloat kNNPhotoBrowserMaxZoomScale = 5.f;

@implementation UIImageView (NNWebImage)

- (void)nn_setImageWithPath:(nullable NSString *)imagePath
                placeholder:(nullable UIImage *)placeholder
                   progress:(nullable YYWebImageProgressBlock)progress
                 completion:(nullable YYWebImageCompletionBlock)completion {
    
    if (![imagePath hasPrefix:@"http"]) {
        // 处理本地图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(image, [NSURL fileURLWithPath:imagePath], YYWebImageFromDiskCache, YYWebImageStageFinished, nil);
            });
        });
        return;
    }
    [self yy_setImageWithURL:[NSURL URLWithString:imagePath] placeholder:placeholder options:YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionAvoidSetImage manager:nil progress:progress transform:nil completion:completion];
}
@end


@interface NNPhotoBrowserCell () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (strong, nonatomic) NNPhotoLoadingView *loadingView;
@end

@implementation NNPhotoBrowserCell

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Override

- (void)prepareForReuse {
    
    [super prepareForReuse];
    [self.imageView yy_cancelCurrentImageRequest];
    [self.scrollView setZoomScale:1.f animated:NO];
    [self.loadingView removeAllAnimations];
}

#pragma mark - Private

- (void)setupUI {
    
    self.backgroundColor = self.contentView.backgroundColor = [UIColor blackColor];
    self.loadingView = [[NNPhotoLoadingView alloc] initWithFrame:self.bounds];
    
    [self.imageView addSubview:self.loadingView];
    [self.containerView addSubview:self.imageView];
    [self.scrollView addSubview:self.containerView];
    [self.contentView addSubview:self.scrollView];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = .3f;

    [singleTap requireGestureRecognizerToFail:doubleTap];
    [singleTap requireGestureRecognizerToFail:longPress];
    [doubleTap requireGestureRecognizerToFail:longPress];

    [self.contentView addGestureRecognizer:singleTap];
    [self.contentView addGestureRecognizer:doubleTap];
    [self.contentView addGestureRecognizer:longPress];
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"scrollView" : self.scrollView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"scrollView" : self.scrollView}]];
}

- (void)layoutSubviewsAdaptToImageSize:(CGSize)imageSize {
    
    [self layoutSubviewsAdaptToImageSize:imageSize animated:NO];
}

- (void)layoutSubviewsAdaptToImageSize:(CGSize)imageSize animated:(BOOL)animated {

    const CGSize containerSize = CGSizeMake(self.bounds.size.width - kNNPhotoBrowserPadding, self.bounds.size.height);
    const CGSize targetSize = [NNPhotoModel adjustImageSize:imageSize toFittingTargetSize:containerSize];
    const CGRect targetFrame = CGRectMake((self.bounds.size.width - kNNPhotoBrowserPadding - targetSize.width) * .5f, (self.bounds.size.height - targetSize.height) * .5f, targetSize.width, targetSize.height);
    const BOOL needUpdate = !CGRectEqualToRect(targetFrame, self.containerView.frame)
                            || !CGSizeEqualToSize(targetSize, self.scrollView.contentSize);
    if (!needUpdate) return;

    const CGFloat maxWidth = MAX(self.bounds.size.width - kNNPhotoBrowserPadding, targetSize.width);
    const CGFloat maxHeight = MAX(self.bounds.size.height, targetSize.height);
    self.scrollView.contentSize = CGSizeMake(maxWidth, maxHeight);
    [self.scrollView setZoomScale:1.f];
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.scrollView.alwaysBounceVertical = self.containerView.bounds.size.height > self.bounds.size.height;
    self.scrollView.maximumZoomScale = MAX(kNNPhotoBrowserMaxZoomScale, MAX((maxWidth / targetSize.width), (maxHeight / targetSize.height)));

    if (animated) {
        [UIView beginAnimations:@"layoutSubviews" context:nil];
        [UIView setAnimationDelegate:self];
    }
    self.containerView.frame = targetFrame;
    self.imageView.frame = self.loadingView.frame = self.containerView.bounds;
    if (animated) [UIView commitAnimations];
}

#pragma mark - IBEvents

- (void)handleSingleTap {
    if (self.handler) self.handler(self, NNPhotoBrowserCellHandlerModeSingleTap);
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap {
    
    if (self.scrollView.zoomScale > 1.0f) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [doubleTap locationInView:self.imageView];
        CGFloat xsize = (self.scrollView.bounds.size.width / self.scrollView.maximumZoomScale);
        CGFloat ysize = (self.scrollView.bounds.size.height / self.scrollView.maximumZoomScale);
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)handleLongPress:(UIGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateBegan) {
        if (self.handler) self.handler(self, NNPhotoBrowserCellHandlerModeLongPress);
    }
}

#pragma mark - Public

- (void)configCellWithItem:(NNPhotoModel *)item {
    
    [self configCellWithItem:item displayOriginal:NO];
}

- (void)configCellWithItem:(NNPhotoModel *)item displayOriginal:(BOOL)original {
    
    NSString *imagePath = item.imagePath;
    if ((original && item.originImagePath.length) || item.isOriginDownloaded) imagePath = item.originImagePath;
    
    __weak typeof(item) wItem = item;
    __weak typeof(self) wSelf = self;
    [self layoutSubviewsAdaptToImageSize:item.size];
    [self.imageView nn_setImageWithPath:imagePath
                            placeholder:item.thumbnail
                               progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                   __strong typeof(wSelf) self = wSelf;
                                   self.loadingView.progress = ((CGFloat)receivedSize / (CGFloat)expectedSize);
                               }
                             completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                 __strong typeof(wSelf) self = wSelf;
                                 BOOL animated = NO;
                                 if (!error && image) {
                                     animated = !CGSizeEqualToSize(wItem.size, image.size);
                                     wItem.size = image.size;
                                     self.imageView.image = image;
                                 }
                                 [self layoutSubviewsAdaptToImageSize:wItem.size animated:animated];
//                                 if (from == YYWebImageFromRemote) {
//                                     [self.loadingView revealAnimationWithCompletionHandler:^{
//                                         __strong typeof(wSelf) self = wSelf;
//                                         [self layoutSubviewsAdaptToImageSize:wItem.size animated:animated];
//                                     }];
//                                 } else {
//                                     [self layoutSubviewsAdaptToImageSize:wItem.size animated:animated];
//                                 }
                             }];
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.containerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Getters

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - kNNPhotoBrowserPadding, self.bounds.size.height)];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = kNNPhotoBrowserMaxZoomScale;
        _scrollView.minimumZoomScale = 1.0f;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
    }
    return _scrollView;
}


- (UIView *)containerView {
    
    if (!_containerView) {
        
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}

- (UIImageView *)imageView {
    
    if (!_imageView) {
        
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

@end
