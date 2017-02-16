//
//  XFPreviewCollectionViewCell.h
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/20.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XFAssetsModel;

typedef void(^TapImageViewBlock)();

static NSString *ReuseIdentifier = @"XFPreviewCollectionViewCell";

@interface XFPreviewCollectionViewCell : UICollectionViewCell <UIScrollViewDelegate>

@property (copy, nonatomic) TapImageViewBlock tapImageViewBlock;

@property (nonatomic, strong) XFAssetsModel *model;

@end
