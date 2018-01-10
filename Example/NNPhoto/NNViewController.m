//
//  NNViewController.m
//  NNPhoto
//
//  Created by ws00801526 on 01/02/2018.
//  Copyright (c) 2018 ws00801526. All rights reserved.
//

#import "NNViewController.h"
#import "NNLoadingViewController.h"
#import <NNPhoto/NNPhotoBrowser.h>

@interface NNViewController ()

@property (strong, nonatomic) NSArray<UIImageView *> *imageViews;
@property (strong, nonatomic) NSArray<NSString *> *imageURLs;
@property (weak, nonatomic) IBOutlet UIStackView *leftStackView;
@property (weak, nonatomic) IBOutlet UIStackView *centerStackView;
@property (weak, nonatomic) IBOutlet UIStackView *rightStackView;

@end

@implementation NNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.imageURLs  = @[
                        @"http://g.hiphotos.baidu.com/image/pic/item/42166d224f4a20a4183ddbaa9a529822720ed0b8.jpg",
                        @"http://a.hiphotos.baidu.com/image/pic/item/dbb44aed2e738bd4a37270d2ab8b87d6267ff986.jpg",
                        @"http://f.hiphotos.baidu.com/image/pic/item/377adab44aed2e73be6f62418d01a18b86d6fadd.jpg",
                        @"http://d.hiphotos.baidu.com/image/pic/item/c2fdfc039245d68827a656c9aec27d1ed21b2433.jpg",
                        @"http://f.hiphotos.baidu.com/image/pic/item/ca1349540923dd54db2b998cdb09b3de9d8248fd.jpg",
                        @"http://d.hiphotos.baidu.com/image/pic/item/5882b2b7d0a20cf4ba3b17b27c094b36acaf9930.jpg",
                        @"http://f.hiphotos.baidu.com/image/pic/item/738b4710b912c8fc26ab19a0f6039245d6882107.jpg",
                        @"http://c.hiphotos.baidu.com/image/pic/item/adaf2edda3cc7cd91f52dc3d3301213fb90e91d3.jpg",
                        @"http://e.hiphotos.baidu.com/image/pic/item/54fbb2fb43166d22db56ba704c2309f79052d235.jpg"
                        ];
    
    
}

#pragma mark - Private

- (void)setupUI {
    
    NSMutableArray<UIImageView *> *views = [NSMutableArray array];
    [views addObjectsFromArray:self.leftStackView.subviews];
    [views addObjectsFromArray:self.centerStackView.subviews];
    [views addObjectsFromArray:self.rightStackView.subviews];
    
    self.imageViews = [views copy];
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.tag = idx;
        obj.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",(int)(idx + 1)]];
        obj.contentMode = UIViewContentModeScaleAspectFill;
        obj.clipsToBounds = YES;
        obj.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        [obj addGestureRecognizer:tapGes];
    }];
}

#pragma mark - IBEvents

- (void)handleTapAction:(UITapGestureRecognizer *)tap {

    NSMutableArray<NNPhotoModel *> *photos = [NSMutableArray array];
    [self.imageURLs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIImage *thumb = idx % 2 ? [UIImage imageNamed:[NSString stringWithFormat:@"%d",(int)(idx + 1)]] : nil;
        NNPhotoModel *photo = [[NNPhotoModel alloc] initWithImagePath:obj
                                                            thumbnail:thumb];
        if (idx == 5) photo.originImagePath = @"http://h.hiphotos.baidu.com/image/pic/item/dbb44aed2e738bd4a4577722ab8b87d6277ff9ab.jpg";
        [photos addObject:photo];
    }];
    NNPhotoBrowserController *browserC = [[NNPhotoBrowserController alloc] initWithPhotos:photos];
    browserC.sourceView = arc4random() % 2 ? tap.view : nil;
    browserC.currentIndex = tap.view.tag;
    [browserC showFromParentController:self];

//    [self.navigationController presentViewController:browserC animated:YES completion:nil];
//    [self.navigationController pushViewController:browserC animated:YES];
}
- (IBAction)testLoadingView:(UIButton *)sender {
    
    [[YYWebImageManager sharedManager].cache.diskCache removeAllObjects];
    [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
    NNLoadingViewController *loadingVC = [[NNLoadingViewController alloc] init];
    [self.navigationController pushViewController:loadingVC animated:YES];
}

@end
