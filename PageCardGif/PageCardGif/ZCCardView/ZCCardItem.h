//
//  ZCCardItem.h
//  TextDemo
//
//  Created by BaoBaoDaRen on 2019/5/21.
//  Copyright © 2019 BaoBao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCCardItem : UIView

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titLab;
@property (nonatomic, strong) NSString *picUrl;

@property (nonatomic, strong) id cardData;

@end

NS_ASSUME_NONNULL_END
