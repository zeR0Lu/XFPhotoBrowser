//
//  XFAssetsCollectionViewCell.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFAssetsCollectionViewCell.h"
#import "XFAssetsModel.h"
#import "UIImageView+XFExtension.h"

@interface XFAssetsCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIImageView *assetsImageView;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation XFAssetsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

- (void)setModel:(XFAssetsModel *)model {
    _model = model;
    
    self.statusImageView.hidden = !model.selected;
    [self.assetsImageView xf_setImageWithAsset:model.asset containerWidth:CGRectGetWidth(self.frame)];
}

- (IBAction)didImageAction:(UIButton *)sender {
    
//    self.model.selected = !self.model.selected;
//    self.statusImageView.hidden = !self.model.selected;
    
    if ( self.didSelectImageBlock ) {
        
        self.didSelectImageBlock();
    }
}

- (void)refreshState {
    self.statusImageView.hidden = !self.model.selected;
}
@end
