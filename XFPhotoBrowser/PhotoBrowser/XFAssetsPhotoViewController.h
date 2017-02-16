//
//  XFAssetsPhotoViewController.h
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XFAssetsGroupModel,XFBrowerViewController;

@interface XFAssetsPhotoViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

/** 导航栏 */
@property (strong, nonatomic) XFBrowerViewController *browerViewController;

@property (nonatomic, strong) XFAssetsGroupModel *assetsGroupModel;

@end
