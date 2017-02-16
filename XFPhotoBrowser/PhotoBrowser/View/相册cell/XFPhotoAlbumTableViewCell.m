//
//  XFPhotoAlbumTableViewCell.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFPhotoAlbumTableViewCell.h"
#import "XFAssetsGroupModel.h"
#import <Photos/Photos.h>
#import "UIImageView+XFExtension.h"

@interface XFPhotoAlbumTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *photoNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;

@end

@implementation XFPhotoAlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

- (void)setupModel:(XFAssetsGroupModel *)model {
    
    [self.groupImageView xf_setImageWithAsset:([model.group count] == 0)?nil:[model.group lastObject] containerWidth:CGRectGetWidth(self.groupImageView.frame)];
    self.groupNameLabel.text = model.groupName;
    self.photoNumberLabel.text = [NSString stringWithFormat:@"%@张",model.photosNumber];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
