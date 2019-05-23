//
//  ZCCardView.h
//  TextDemo
//
//  Created by BaoBaoDaRen on 2019/5/21.
//  Copyright © 2019 BaoBao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCCardView : UIView

typedef void (^CompleteBlock)(NSInteger index);
@property (nonatomic, copy) CompleteBlock complete;

@property (nonatomic, strong) NSArray *originData;

- (instancetype)initWithFrame:(CGRect)frame withComplete:(__nullable CompleteBlock)complete;

@end

NS_ASSUME_NONNULL_END
