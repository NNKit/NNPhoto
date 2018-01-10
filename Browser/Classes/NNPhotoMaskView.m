//  NNPhotoMaskView.m
//  Pods
//
//  Created by  XMFraker on 2018/1/9
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNPhotoMaskView
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNPhotoMaskView.h"
#import "NNPhotoModel.h"
#import "NNPhotoBrowserController.h"

@interface NNPhotoMaskView () <NNPhotoBrowserControllerDelegate>
@property (strong, nonatomic) UIButton *checkOriginButton;
@property (strong, nonatomic) UIButton *downloadButton;
@end

@implementation NNPhotoMaskView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Override

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    for (UIView *subview in self.subviews) {
        if (CGRectContainsPoint(subview.frame, point)) return subview;
    }
    return nil;
}

#pragma mark - Private

- (void)setupUI {
    
    self.backgroundColor = [UIColor clearColor];
    self.checkOriginButton = [self buttonWithTitle:@"查看原图"];
    self.checkOriginButton.alpha = .0f;
    [self.checkOriginButton addTarget:self action:@selector(handleCheckOriginAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.downloadButton = [self buttonWithTitle:@"下"];
    [self.downloadButton addTarget:self action:@selector(handleDownloadAction) forControlEvents:UIControlEventTouchUpInside];

    self.checkOriginButton.layer.cornerRadius = self.downloadButton.layer.cornerRadius = 2.f;
    self.checkOriginButton.layer.masksToBounds = self.downloadButton.layer.masksToBounds = YES;
    
    [self addSubview:self.checkOriginButton];
    [self addSubview:self.downloadButton];
    
    self.checkOriginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkOriginButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.f
                                                      constant:-20.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkOriginButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.f
                                                      constant:.0f]];
    
    self.downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.downloadButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.f
                                                      constant:-20.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.downloadButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.f
                                                      constant:-20.0f]];
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:13.f];
    button.contentEdgeInsets = UIEdgeInsetsMake(4.f, 4.f, 4.f, 4.f);
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:.15f green:.15f blue:.15f alpha:.7f];
    button.layer.borderColor = [UIColor colorWithRed:.25f green:.25f blue:.25f alpha:1.f].CGColor;
    button.layer.borderWidth = .5f;
    return button;
}

#pragma mark - NNPhotoBrowserControllerDelegate

- (void)browser:(NNPhotoBrowserController *)browser willDisplayPhoto:(NNPhotoModel *)photo {
    [UIView animateWithDuration:.3f animations:^{
        self.checkOriginButton.alpha = .0f;
    }];
}

- (void)browser:(NNPhotoBrowserController *)browser didDisplayPhoto:(NNPhotoModel *)photo {
    if (!photo.isOriginDownloaded && photo.originImagePath.length) {
        [UIView animateWithDuration:.3f animations:^{
            self.checkOriginButton.alpha = 1.0f;
        }];
    }
}

#pragma mark - IBEvents

- (void)handleCheckOriginAction {
    if (self.handler) self.handler(NNPhotoMaskViewHandlerModeDownloadOrigin);
}

- (void)handleDownloadAction {
    if (self.handler) self.handler(NNPhotoMaskViewHandlerModeSaveAlbum);
}

@end
