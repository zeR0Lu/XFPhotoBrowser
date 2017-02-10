//
//  XFBrowerViewController.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/20.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFBrowerViewController.h"
#import "XFPhotoAlbumViewController.h"
#import "XFAssetsPhotoViewController.h"
#import "XFAssetsLibraryManager.h"
#import "XFAssetsLibraryAccessFailureView.h"
#import "SDAutoLayout.h"

@interface XFBrowerViewController ()

@end

@implementation XFBrowerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = RGB(48, 48, 48);
    NSDictionary *titleTextAttributesDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.f],NSFontAttributeName,nil];
    self.navigationBar.titleTextAttributes = titleTextAttributesDict;
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    
}

- (void)didCancelBarButtonAction {
    [self.parentViewController dismissViewControllerAnimated:true completion:nil];
}

+ (instancetype)shareBrowerManagerWithSelectedAssets:(NSArray<XFAssetsModel *> *)selectedAssets {
    
    XFPhotoAlbumViewController *alumbVC = [XFPhotoAlbumViewController new];
    
    XFBrowerViewController *nav = [[self alloc] initWithRootViewController:alumbVC];
    nav.selectedAssets = selectedAssets;
    
    XFAssetsPhotoViewController *photoVC = [XFAssetsPhotoViewController new];
    photoVC.browerViewController = nav;
    
    [[XFAssetsLibraryManager shareManager] getCameraGroupWithSuccess:^(XFAssetsGroupModel *model) {
        photoVC.assetsGroupModel = model;
        
        [nav pushViewController:photoVC animated:NO];
    } failBlcok:^{
        XFAssetsLibraryAccessFailureView *view = [XFAssetsLibraryAccessFailureView makeView];
        [alumbVC.view addSubview:view];
        view.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    }];
    
    return nav;
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
