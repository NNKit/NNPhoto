//  NNPhotoBrowserController.m
//  Pods
//
//  Created by  XMFraker on 2018/1/2
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNPhotoBrowserController
//  @version    <#class version#>
//  @abstract   <#class description#>

CGFloat kNNPhotoBrowserPadding = 16.f;

#import "NNPhotoBrowserController.h"
#import "NNPhotoBrowserTransition.h"
#import "NNPhotoBrowserCell.h"
#import "NNPhotoModel.h"

#import <YYWebImage/YYWebImage.h>

@interface NNPhotoBrowserController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) NSInteger firstBrowserIndex;

@property (copy, nonatomic)   NSDictionary *storedBarInfo;

@end

@implementation NNPhotoBrowserController
@synthesize photos = _photos;

#pragma mark - Life Cycle

- (instancetype)initWithPhotos:(NSArray<NNPhotoModel *> *)photos {
    
    NSAssert(photos.count, @"photos should not be empty");
    if (self = [super initWithNibName:nil bundle:nil]) {
        _photos = [photos copy];
        _firstBrowserIndex = NSNotFound;
    }
    return self;
}

- (void)dealloc {
    
#if DEBUG
    NSLog(@"%@ is %@ing", self, NSStringFromSelector(_cmd));
#endif
}

#pragma mark - Override

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.storedBarInfo = @{ @"hidden" : @(self.navigationController.isNavigationBarHidden) };
    [self.navigationController setNavigationBarHidden:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.storedBarInfo && !self.presentingViewController) {
        BOOL navigationBarHidden = [[self.storedBarInfo objectForKey:@"hidden"] boolValue];
        [self.navigationController setNavigationBarHidden:navigationBarHidden animated:animated];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    const NSInteger index = self.currentIndex;
    const NSIndexPath *indexPath = [NSIndexPath indexPathForItem:MAX(index, 0) inSection:0];
    const NSArray <NSIndexPath *> *indexPaths = [NSArray arrayWithObject:indexPath];
    NNPhotoBrowserCell *browserCell = (NNPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:indexPaths.firstObject];
    const CGSize itemSize = CGSizeMake(size.width + kNNPhotoBrowserPadding, size.height);
    UIView *snapshotView = [[UIImageView alloc] initWithImage:browserCell.imageView.image];
    snapshotView.frame = CGRectMake(0, 0, browserCell.imageView.superview.bounds.size.width * browserCell.imageView.superview.transform.a, browserCell.imageView.superview.bounds.size.height * browserCell.imageView.superview.transform.d);
    snapshotView.center = self.view.center;
    [[UIApplication sharedApplication].keyWindow addSubview:snapshotView];
    self.collectionView.hidden = YES;

    NNPhotoModel *photo = [self.photos objectAtIndex:indexPath.item];
    const CGSize  lastSize = [NNPhotoModel adjustImageSize:photo.size toFittingTargetSize:size];
    const CGPoint lastCenter = CGPointMake((size.width - lastSize.width) * .5f, (size.height - lastSize.height) * .5f);
    const CGRect  lastFrame = { lastCenter, lastSize };
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        snapshotView.frame = lastFrame;
        snapshotView.transform = CGAffineTransformIdentity;
        [self.collectionView setCollectionViewLayout:[NNPhotoBrowserController browserCollectionViewLayoutWithItemSize:itemSize]];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [UIView setAnimationsEnabled:NO];
        [self.collectionView reloadItemsAtIndexPaths:[indexPaths copy]];
        [self.collectionView scrollToItemAtIndexPath:indexPaths.firstObject atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        [UIView setAnimationsEnabled:YES];
        [snapshotView removeFromSuperview];
        self.collectionView.hidden = NO;
    }];
}

#pragma mark - Public

- (void)showFromParentController:(__kindof UIViewController *)controller {
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    nav.transitioningDelegate = (id<UIViewControllerTransitioningDelegate>)self;
    [controller presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Private

- (void)setupUI {

    self.transitioningDelegate = (id<UIViewControllerTransitioningDelegate>)self;
    self.navigationController.transitioningDelegate = (id<UIViewControllerTransitioningDelegate>)self;
    self.view.backgroundColor = [UIColor blackColor];
    // 关闭contentInsets自动计算, 解决图片无法全屏显示问题
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    const CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width + kNNPhotoBrowserPadding, [UIScreen mainScreen].bounds.size.height);
    UICollectionViewLayout *layout = [NNPhotoBrowserController browserCollectionViewLayoutWithItemSize:size];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) collectionViewLayout:layout];
    self.collectionView.delegate = (id<UICollectionViewDelegate>)self;
    self.collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.scrollsToTop = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[NNPhotoBrowserCell class] forCellWithReuseIdentifier:@"NNPhotoBrowserCell"];
    
    // 首次进入
    if (self.firstBrowserIndex != NSNotFound && self.firstBrowserIndex < self.photos.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.firstBrowserIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"collectionView" : self.collectionView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]-margin-|" options:NSLayoutFormatAlignAllLeft metrics:@{@"margin" : @(-kNNPhotoBrowserPadding)} views:@{@"collectionView" : self.collectionView}]];
}

- (void)viewControllerBack {

    if (self.presentingViewController) [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.navigationController) [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentIndex = ceil(scrollView.contentOffset.x / scrollView.frame.size.width);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentIndex = ceil(scrollView.contentOffset.x / scrollView.frame.size.width);
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[NNPhotoBrowserPresentTransition alloc] init];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[NNPhotoBrowserDismissTransition alloc] init];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NNPhotoBrowserCell *browserCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NNPhotoBrowserCell" forIndexPath:indexPath];
    [browserCell configCellWithItem:[self.photos objectAtIndex:indexPath.item]];
    __weak typeof(self) wSelf = self;
    browserCell.handler = ^(NNPhotoBrowserCell *cell, NNPhotoBrowserCellHandlerMode mode) {
        __strong typeof(wSelf) self = wSelf;
        if (mode == NNPhotoBrowserCellHandlerModeSingleTap) [self viewControllerBack];
    };
    return browserCell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    if (![cell isKindOfClass:[NNPhotoBrowserCell class]]) return;
    NNPhotoBrowserCell *browserCell = (NNPhotoBrowserCell *)cell;
    [browserCell.imageView yy_cancelCurrentImageRequest];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![cell isKindOfClass:[NNPhotoBrowserCell class]]) return;
    NNPhotoBrowserCell *browserCell = (NNPhotoBrowserCell *)cell;
    [browserCell configCellWithItem:[self.photos objectAtIndex:indexPath.item]];
}

#pragma mark - Setter

- (void)setCurrentIndex:(NSUInteger)currentIndex {

    _currentIndex = MAX(0, currentIndex);
    if (self.firstBrowserIndex == NSNotFound) self.firstBrowserIndex = MAX(0, currentIndex);
}

#pragma mark - Class

+ (UICollectionViewLayout *)browserCollectionViewLayoutWithItemSize:(CGSize)itemSize {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = itemSize;
    layout.minimumInteritemSpacing = CGFLOAT_MIN;
    layout.minimumLineSpacing = CGFLOAT_MIN;
    return layout;
}

@end
