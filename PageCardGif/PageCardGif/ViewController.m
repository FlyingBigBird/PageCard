//
//  ViewController.m
//  PageCardGif
//
//  Created by BaoBaoDaRen on 2019/5/23.
//  Copyright © 2019 Boris. All rights reserved.
//

#import "ViewController.h"
#import "ZCCardView.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define data @[@"5.gif",@"2.jpg",@"3.jpg",@"4.jpg"]
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {

    } else {
        // Fallback on earlier versions
    }
    
    
    ZCCardView *cardV = [[ZCCardView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) withComplete:^(NSInteger index) {
        
        NSLog(@"index:%ld",(long)index);
    }];
    cardV.originData = data;
    [self.view addSubview:cardV];
    
    
}


@end
