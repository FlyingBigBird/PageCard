//
//  ZCCardView.m
//  TextDemo
//
//  Created by BaoBaoDaRen on 2019/5/21.
//  Copyright © 2019 BaoBao. All rights reserved.
//

#import "ZCCardView.h"
#import "ZCCardItem.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

//控件x坐标
#define boundsEdge 15
//控件y坐标
#define topEdge 10

//高度
#define cardHeight 360

//图片之间间隔距离
#define cardEdge 10

// 视图向右移出屏幕
#define RemoveViewFromRight (SCREEN_WIDTH + _currentItem.frame.size.width + boundsEdge)
//左边移除到中心点
#define RemoveViewFromLeft (-_currentItem.frame.size.width + boundsEdge * 2)

@interface ZCCardView () <UIGestureRecognizerDelegate>
{
//    UIView *_transformView;

    //当前页面的控件个数
    CGFloat showItemNum;
    CGPoint _currentImgCenter;
    CGFloat _beginTimeStamp;
    CGPoint _beginPoint;
    
    UIView *_transformView;

    BOOL _moveYes;
}
@property (nonatomic, strong) NSMutableArray *imgArr;
@property (nonatomic, strong) NSMutableArray * itemArr;
@property (nonatomic, strong) ZCCardItem *currentItem;
@property (nonatomic, assign) NSInteger cardNum;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation ZCCardView

- (instancetype)initWithFrame:(CGRect)frame withComplete:(__nullable CompleteBlock)complete
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.complete = complete;

        self.cardNum = 0;
        self.currentIndex = 0;
        showItemNum = 0;
    }
    return self;
}
- (void)setOriginData:(NSArray *)originData
{
    if (originData.count > 0) {
        
        showItemNum = originData.count;
        [self.imgArr removeAllObjects];
        [self.imgArr addObjectsFromArray:originData];
        
        for (id subV in [self subviews]) {
            
            if ([subV isKindOfClass:[ZCCardItem class]]) {
                
                [subV removeFromSuperview];
            }
        }
        
        [self initCardUi];
    }
}
- (void)initCardUi
{
    [self.itemArr removeAllObjects];

    for (int i = 0; i < showItemNum; i++) {
        
        // 倾斜平铺算法：CGRectMake(boundsEdge + cardEdge * i, topEdge + i * cardEdge, SCREEN_WIDTH - boundsEdge * 2 - cardEdge * (showItemNum - 1), cardHeight - topEdge - cardEdge * (showItemNum - 1))
        // 竖直平铺：ZCCardItem *item = [[ZCCardItem alloc] initWithFrame:CGRectMake(boundsEdge + cardEdge * i, topEdge + i * cardEdge, SCREEN_WIDTH - boundsEdge * 2 - cardEdge * i * 2, cardHeight - topEdge - cardEdge * (showItemNum - 1))];
      
        ZCCardItem *item = [[ZCCardItem alloc] initWithFrame:CGRectMake(boundsEdge + cardEdge * i, topEdge + i * cardEdge, SCREEN_WIDTH - boundsEdge * 2 - cardEdge * (showItemNum - 1), cardHeight - topEdge - cardEdge * (showItemNum - 1))];

        item.cardData = self.imgArr[i];
        [self.itemArr addObject:item];

        [self insertSubview:item atIndex:0];
        
        if (i == 0) {
            
            self.currentItem = item;
            _currentImgCenter = self.currentItem.center;
        }
    }
}

- (NSMutableArray *)imgArr
{
    if (!_imgArr) {
        _imgArr = [NSMutableArray array];
    }
    return _imgArr;
}
- (NSMutableArray *)itemArr
{
    if (!_itemArr) {
        _itemArr = [NSMutableArray array];
    }
    return _itemArr;
}
// 返回自身响应者...
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    // 如果在当前 view 中 直接返回 self 这样自身就成为了第一响应者 subViews 不再能够接受到响应事件
    if ([self pointInside:point withEvent:event]) {

        return self;
    }
    return nil;
}
#pragma mark - 触摸时间...
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 移除已进行了transform的View
    if (_transformView !=nil) {
        [_transformView removeFromSuperview];
        _transformView = nil;
    }
    
    _beginTimeStamp = event.timestamp;
    _beginPoint = [[touches anyObject] locationInView:self];
    
    if (_beginPoint.y > topEdge&&_beginPoint.y < CGRectGetMaxY(_currentItem.frame))
    {
        _moveYes = YES;
    } else {
        _moveYes = NO;
    }
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesMoved:touches withEvent:event];
    CGPoint endPoint = [[touches anyObject] locationInView:self];
    CGFloat x = endPoint.x - _beginPoint.x;
    CGFloat y = endPoint.y - _beginPoint.y;

    //图片范围内响应
    if (_moveYes == YES) {
        
        _currentItem.center = CGPointMake(_currentImgCenter.x + x,_currentImgCenter.y + y);
        _currentItem.transform=CGAffineTransformMakeRotation(x/1000);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.imgArr.count <= 1) {
        
        [self moveViewToX:_currentImgCenter.x toY:_currentImgCenter.y needRemove:NO];
        return;
    }
    
    CGPoint endPoint = [[touches anyObject] locationInView:self];
    CGFloat offsetX = endPoint.x - _beginPoint.x;
    CGFloat timeStamp = _beginTimeStamp - event.timestamp;
    
    // 极小范围拖动默认为点击...
    if (_beginPoint.y > topEdge&&_beginPoint.y < CGRectGetMaxY(_currentItem.frame)&&fabs(offsetX)<10)
    {
        NSInteger itemIndex = self.currentIndex % (self.itemArr.count);
        self.complete(itemIndex);
    }
    
    // 定义快速小范围滑动...
    if (fabs(timeStamp) < 0.12 && fabs(offsetX) > 25) {
        
        if (offsetX > 0) {
            
            // 向右滑动
            [self moveViewToX:RemoveViewFromRight toY:endPoint.y needRemove:YES];
        } else {
            // 左滑...
            [self moveViewToX:RemoveViewFromLeft toY:endPoint.y needRemove:YES];
        }
    } else {
        
        if (offsetX > 0) {
            
            if (offsetX > _currentItem.frame.size.width / 3) {
                
                [self moveViewToX:RemoveViewFromRight toY:endPoint.y needRemove:YES];
            } else {
                [self moveViewToX:_currentImgCenter.x toY:_currentImgCenter.y needRemove:NO];
            }
        } else {
            if (fabs(offsetX) > _currentItem.frame.size.width / 3) {
                
                [self moveViewToX:RemoveViewFromLeft toY:endPoint.y needRemove:YES];
            } else {
                [self moveViewToX:_currentImgCenter.x toY:_currentImgCenter.y needRemove:NO];
            }
        }
    }
}

- (void)moveViewToX:(CGFloat)x toY:(CGFloat)y needRemove:(BOOL)needRemove
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.currentItem.center = CGPointMake(x, y);
        self.currentItem.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        
        [self->_transformView removeFromSuperview];
        self->_transformView = nil;
    }];
 
    if (needRemove == YES) {
    
        [self changeItemLevelConfiguration];
    }
}

- (void)changeItemLevelConfiguration
{
    _currentIndex++;
    
    id model = self.imgArr[0];
    [self.imgArr removeObjectAtIndex:0];
    [self.imgArr addObject:model];
    
    _transformView = _itemArr[0];
//    CGRect itemRect = CGRectMake(boundsEdge + cardEdge * (showItemNum - 1), topEdge + (showItemNum - 1) * cardEdge, SCREEN_WIDTH - boundsEdge * 2 - cardEdge * (showItemNum - 1) * 2, cardHeight - topEdge - cardEdge * (showItemNum - 1));
    int i = (showItemNum - 1);
    CGRect itemRect = CGRectMake(boundsEdge + cardEdge * i, topEdge + i * cardEdge, SCREEN_WIDTH - boundsEdge * 2 - cardEdge * (showItemNum - 1), cardHeight - topEdge - cardEdge * (showItemNum - 1));
    ZCCardItem *item = [[ZCCardItem alloc] initWithFrame:itemRect];
    item.cardData = model;
    
    [_itemArr removeObjectAtIndex:0];
    [_itemArr addObject:item];
    
    [self doChangeLevel];
}
- (void)doChangeLevel
{
    for (int i = 0; i < showItemNum; i++) {
        
        ZCCardItem *item = self.itemArr[i];
        
        [UIView animateWithDuration:0.3 animations:^{
            
//            item.frame = CGRectMake(boundsEdge + cardEdge * i, topEdge + i * cardEdge, SCREEN_WIDTH - boundsEdge * 2 - cardEdge * i * 2, cardHeight - topEdge - cardEdge * (self->showItemNum - 1));
            item.frame = CGRectMake(boundsEdge + cardEdge * i, topEdge + i * cardEdge, SCREEN_WIDTH - boundsEdge * 2 - cardEdge * (self->showItemNum - 1), cardHeight - topEdge - cardEdge * (self->showItemNum - 1));
        } completion:^(BOOL finished) {

        }];

        if (i == (showItemNum - 1)) {

            [UIView animateWithDuration:0.3 animations:^{

                item.alpha = 1;
            } completion:^(BOOL finished) {

            }];
            [self insertSubview:item atIndex:0];
        }
        
        if (i == 0) {
            _currentItem = item;
            _currentImgCenter = _currentItem.center;
        }
    }
}


@end
