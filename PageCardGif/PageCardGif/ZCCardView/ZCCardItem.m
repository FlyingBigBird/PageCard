//
//  ZCCardItem.m
//  TextDemo
//
//  Created by BaoBaoDaRen on 2019/5/21.
//  Copyright © 2019 BaoBao. All rights reserved.
//

#import "ZCCardItem.h"

@implementation ZCCardItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
        self.layer.shadowColor = [UIColor blackColor].CGColor;//阴影颜色
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.1;//阴影透明度
        self.layer.shadowRadius = 10;//阴影直径
        self.layer.borderColor = [[UIColor blackColor] CGColor];
        [self addSubview:self.imgView];
        [self addSubview:self.titLab];

    }
    return self;
}

- (void)setCardData:(id)cardData
{
    NSString *imgType = [NSString stringWithFormat:@"%@",cardData];
    if ([imgType hasSuffix:@"gif"]) {
        
        // 播放gif...
        [self getImgPath];
    } else {
        
        self.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",cardData]];
    }
}
- (void)getImgPath
{
    // 从cardData取,这里不做演示了...
    NSString *dataPath = [[NSBundle mainBundle]pathForResource:@"5" ofType:@"gif"];
    // gif数据
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:dataPath], NULL);
    // gif图片个数
    size_t count = CGImageSourceGetCount(source);
    // 播放一轮的时间
//    float allTime = 0;
    
    // 存图片组
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    
    // 存每一帧播放的时间
    NSMutableArray *timeArray = [[NSMutableArray alloc] init];
    
    // 图片宽度
    NSMutableArray *widthArray = [[NSMutableArray alloc] init];
    
    // 图片的高度
    NSMutableArray *heightArray = [[NSMutableArray alloc] init];
    // 遍历gif
    for (size_t i=0; i < count; i++) {
        
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        [imageArray addObject:(__bridge UIImage *)(image)];
        CGImageRelease(image);
        
        //获取图片信息
        NSDictionary *info = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
        NSLog(@"info---%@",info);
        
        //获取宽度
        CGFloat width = [[info objectForKey:(__bridge NSString *)kCGImagePropertyPixelWidth] floatValue];
        
        //获取高度
        CGFloat height = [[info objectForKey:(__bridge NSString *)kCGImagePropertyPixelHeight] floatValue];
        
        [widthArray addObject:[NSNumber numberWithFloat:width]];
        [heightArray addObject:[NSNumber numberWithFloat:height]];
        
        //统计时间
        NSDictionary *timeDic = [info objectForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
        CGFloat time = [[timeDic objectForKey:(__bridge NSString *)kCGImagePropertyGIFDelayTime] floatValue];
        [timeArray addObject:[NSNumber numberWithFloat:time]];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    NSMutableArray *times = [[NSMutableArray alloc] init];
    float currentTime = 0;
    //设置每一帧的时间占比
    
    for (int i=0; i<imageArray.count; i++) {
        
        [times addObject:[NSNumber numberWithFloat:currentTime]];
        currentTime += ([timeArray[i] floatValue]);
    }
    
    [animation setKeyTimes:times];
    [animation setValues:imageArray];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    
    //设置循环
    animation.repeatCount = MAXFLOAT;

    //设置播放总时长
    animation.duration = currentTime;
    
    //Layer层添加
    [[self.imgView layer] addAnimation:animation forKey:@"gifAnimation"];

}
- (void)dealloc
{
    CFTimeInterval pausedTime = [self.imgView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 让CALayer的时间停止走动
    self.imgView.layer.speed = 0.0;
    // 让CALayer的时间停留在pausedTime这个时刻
    self.imgView.layer.timeOffset = pausedTime;
    [self.imgView stopAnimating];
    [[self.imgView layer] removeAnimationForKey:@"gifAnimation"];

}

- (void)setPicUrl:(NSString *)picUrl
{
    if (_picUrl != picUrl) {
        _picUrl = picUrl;
    }
    _imgView.image = [UIImage imageNamed:_picUrl];
}

- (UILabel *)titLab
{
    if (!_titLab) {
        _titLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30)];
        _titLab.font = [UIFont systemFontOfSize:14];
        _titLab.textColor = [UIColor whiteColor];
    }
    return _titLab;
}
- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.clipsToBounds = YES;
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.layer.masksToBounds = YES;
        _imgView.layer.cornerRadius = 10;
    }
    return _imgView;
}
- (void)layoutSubviews
{
    self.imgView.frame = self.bounds;
    self.titLab.frame = CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30);
}

@end
