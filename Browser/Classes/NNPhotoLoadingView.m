//  NNPhotoLoadingView.m
//  Pods
//
//  Created by  XMFraker on 2018/1/8
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNPhotoLoadingView
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNPhotoLoadingView.h"

@interface NNPhotoLoadingView ()

@property (strong, nonatomic) CAShapeLayer *circleLayer;
@property (assign, nonatomic) CGFloat circleRadius;
@property (copy, nonatomic)   void(^handler)(void);

@end

@implementation NNPhotoLoadingView

#pragma mark - Life Cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Override
- (void)layoutSubviews {
    [super layoutSubviews];
    self.circleLayer.frame = self.bounds;
    self.circleLayer.path = [self circlePathWithRect:[self circleFrame]].CGPath;
}

#pragma mark - Private

- (void)setupUI {
    
    self.circleRadius = 30.f;
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.frame = CGRectMake(0, 0, 40, 40);
    self.circleLayer.lineWidth = 3.f;
    self.circleLayer.lineCap = kCALineCapRound;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.strokeColor = [UIColor colorWithRed:.92f green:.92f blue:.92f alpha:1.f].CGColor;
    [self.layer addSublayer:self.circleLayer];
    
    self.progress = .0f;
}

- (void)removeAllAnimations {
    
    self.progress = .0f;
    [self.circleLayer removeAnimationForKey:@"strokeEnd"];
    [self.circleLayer removeAnimationForKey:@"strokeWidth"];
    if (!self.circleLayer.superlayer) [self.layer addSublayer:self.circleLayer];
}

- (void)revealAnimation {
    [self revealAnimationWithCompletionHandler:nil];
}

- (void)revealAnimationWithCompletionHandler:(nullable void(^)(void))handler {
    
    self.handler = handler;
    
    self.backgroundColor = [UIColor clearColor];
    self.progress = 1.f;
    [self.circleLayer removeAnimationForKey:@"strokeEnd"];
    [self.circleLayer removeFromSuperlayer];
    
    if (self.superview) self.superview.layer.mask = self.circleLayer;
    
    const CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    const CGFloat finalRadius = sqrt((center.x * center.x) + (center.y * center.y));
    const CGFloat finalInset = finalRadius - self.circleRadius;
    const CGRect  outerRect = CGRectInset([self circleFrame], -finalInset, -finalInset);
    const UIBezierPath *finalPath = [self circlePathWithRect:outerRect];
    
    const UIBezierPath *fromPath =  self.circleLayer.path ? [UIBezierPath bezierPathWithCGPath:self.circleLayer.path] : nil;
    const CGFloat fromWidth = self.circleLayer.lineWidth;
    
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    lineAnimation.fromValue = @(fromWidth);
    lineAnimation.toValue = @(2 * finalRadius);
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge UIBezierPath *)fromPath.CGPath;
    pathAnimation.toValue = (__bridge UIBezierPath *)finalPath.CGPath;
    
    CAAnimationGroup *groupAnimations = [CAAnimationGroup animation];
    groupAnimations.duration = 1.f;
    groupAnimations.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    groupAnimations.animations = @[pathAnimation, lineAnimation];
    groupAnimations.delegate = (id<CAAnimationDelegate>)self;
    [self.circleLayer addAnimation:groupAnimations forKey:@"strokeWidth"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.superview) self.superview.layer.mask = nil;
    if (self.handler) self.handler();
}

- (CGRect)circleFrame {
    CGRect frame = { CGPointZero, CGSizeMake(2 * self.circleRadius, 2 * self.circleRadius) };
    CGRect circlyBounds = self.circleLayer.bounds;
    frame.origin.x = CGRectGetMidX(circlyBounds) - CGRectGetMidX(frame);
    frame.origin.y = CGRectGetMidY(circlyBounds) - CGRectGetMidY(frame);
    return frame;
}

- (UIBezierPath *)circlePathWithRect:(CGRect)rect {
    
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
                                          radius:rect.size.width * .5f
                                      startAngle:-M_PI_2
                                        endAngle:M_PI_2 * 3
                                       clockwise:YES];
    return [UIBezierPath bezierPathWithOvalInRect:[self circleFrame]];
}

#pragma mark - Setter

- (void)setProgress:(CGFloat)progress {
    self.circleLayer.strokeEnd = MAX(MIN(1.f, progress), .0f);
    if (self.circleLayer.strokeEnd >= 1.f) {
        [self.circleLayer removeFromSuperlayer];
    } else if (!self.circleLayer.superlayer) {
        [self.layer addSublayer:self.circleLayer];
    }
}

#pragma mark - Getter

- (CGFloat)progress {
    return self.circleLayer.strokeEnd;
}

@end
