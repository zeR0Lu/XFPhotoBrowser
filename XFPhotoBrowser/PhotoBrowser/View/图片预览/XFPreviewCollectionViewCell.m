//
//  XFPreviewCollectionViewCell.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/20.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFPreviewCollectionViewCell.h"
#import "UIImageView+XFExtension.h"
#import "XFAssetsModel.h"

@interface XFPreviewCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation XFPreviewCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
    [self.imageView addGestureRecognizer:tapGesture];

}

- (void)tapImageView:(UITapGestureRecognizer *)recognizer {
    if ( self.tapImageViewBlock ) {
        self.tapImageViewBlock();
    }
}

- (void)setModel:(XFAssetsModel *)model {
    [self.imageView xf_setImageWithAsset:model.asset containerWidth:[UIScreen mainScreen].bounds.size.width];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
