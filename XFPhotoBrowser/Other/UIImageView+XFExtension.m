//
//  UIImageView+XFExtension.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 17/2/10.
//  Copyright © 2017年 zeroLu. All rights reserved.
//

#import "UIImageView+XFExtension.h"
#import "GCD.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "XFAssetsLibraryManager.h"

@implementation UIImageView (XFExtension)

- (void)xf_setImageWithAsset:(id)asset containerWidth:(CGFloat)containerWidth {
    if ( asset ) {
        [self xf_setupImageWithAsset:asset containerWidth:containerWidth];
    } else {
        
    }
}

- (void)xf_setupImageWithAsset:(id)asset containerWidth:(CGFloat)containerWidth {
    
    XFWeakSelf;
    
    if ( containerWidth > 600 ) {
        containerWidth = 600;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if ( [asset isKindOfClass:[PHAsset class]] ) {
        PHAsset *phAsset = (PHAsset *)asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        
        CGFloat pixelWidth = containerWidth * scale;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        
        PHImageRequestOptions *imageREquestOptions = [[PHImageRequestOptions alloc] init];
        // 异步处理
        imageREquestOptions.synchronous = true;
        //        /*对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。*/
        //        imageREquestOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
        //        /** 图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
        //         这个属性只有在 synchronous 为 true 时有效 */
        //        imageREquestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(pixelWidth,pixelHeight) contentMode:PHImageContentModeAspectFit options:imageREquestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            if ( result ) {
                if ( ![result isEqual:wself.image] ) {
                    [GCDQueue executeInMainQueue:^{
                        XFStrongSelf;
                        sself.image = result;
                    }];
                }
            }
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        [GCDQueue executeInGlobalQueue:^{
            ALAsset *alAsset = (ALAsset *)asset;
            ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
            CGImageRef thumbnailImageRef = alAsset.aspectRatioThumbnail;
            UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef scale:scale orientation:UIImageOrientationUp];
            
            if ( containerWidth == [UIScreen mainScreen].bounds.size.width ) {
                CGImageRef fullScrennImageRef = [assetRep fullScreenImage];
                UIImage *fullScrennImage = [UIImage imageWithCGImage:fullScrennImageRef scale:scale orientation:UIImageOrientationUp];
                
                [GCDQueue executeInMainQueue:^{
                    XFStrongSelf;
                    sself.image = fullScrennImage;
                }];
            } else {
                [GCDQueue executeInMainQueue:^{
                    XFStrongSelf;
                    sself.image = thumbnailImage;
                }];
            }
        }];
    }
}
@end
