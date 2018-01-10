//  NNLoadingViewController.m
//  NNPhoto
//
//  Created by  XMFraker on 2018/1/8
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNLoadingViewController
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNLoadingViewController.h"
#import <NNPhoto/NNPhotoBrowser.h>
//#import <NNPhoto/NNPhotoLoadingView.h>

@interface NNLoadingViewController ()
//@property (strong, nonatomic) NNPhotoLoadingView *loadingView;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation NNLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    NSURL *URL = [NSURL URLWithString:@"https://koenig-media.raywenderlich.com/uploads/2015/02/mac-glasses.jpeg"];
//    NSString *key = [[YYWebImageManager sharedManager] cacheKeyForURL:URL];
//    [[YYWebImageManager sharedManager].cache removeImageForKey:key];
//
//    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
//    self.imageView.center = self.view.center;
//
//    self.loadingView = [[NNPhotoLoadingView alloc] initWithFrame:self.imageView.bounds];
//    [self.imageView addSubview:self.loadingView];
//
//    [self.imageView yy_setImageWithURL:URL
//                           placeholder:nil
//                               options:kNilOptions
//                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                  self.loadingView.progress = ((CGFloat)receivedSize / (CGFloat)expectedSize);
//                              } transform:nil
//                            completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
//                                [self.loadingView revealAnimation];
//                            }];
//
//    [self.view addSubview:self.imageView];
//    [self.imageView addSubview:self.loadingView];
//    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
