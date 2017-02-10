//
//  XFBrowerViewController.h
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/20.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALAssetsGroup, XFAssetsModel;

typedef void(^CallBack)(NSArray<XFAssetsModel *> *selectedArray);
typedef void(^GetImageBlock)(NSArray<UIImage *> *selectedImageArray);

@interface XFBrowerViewController : UINavigationController
/**
 *  选择图片的最大数,如果不设置就不作限制
 */
@property (assign, nonatomic) NSInteger maxPhotosNumber;

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (strong, nonatomic) NSArray<XFAssetsModel *> *selectedAssets;

@property (copy, nonatomic) CallBack callback;

@property (nonatomic, copy) GetImageBlock getImageBlock;

+ (instancetype)shareBrowerManagerWithSelectedAssets:(NSArray<XFAssetsModel *> *)selectedAssets;
@end
