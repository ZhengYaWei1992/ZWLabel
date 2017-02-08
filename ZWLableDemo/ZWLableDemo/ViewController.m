//
//  ViewController.m
//  ZWLableDemo
//
//  Created by 郑亚伟 on 2017/2/8.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ViewController.h"
#import "ZWLabel.h"
@interface ViewController ()<ZWLabelDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ZWLabel *label = [[ZWLabel alloc]initWithFrame:CGRectMake(0, 0, 320, 0)];
    label.backgroundColor = [UIColor yellowColor];
    
    label.delegate = self;
    
    NSString *str =  @"请点击http://www.baidu.com 请点😁😂😄😅😇击@郑亚伟 请点击#郑亚伟#请点击http://www.baidu.com  😁😂请点击@郑亚伟 请点击#亚伟#请点击http://www.baidu.com 请点击@郑亚伟 请点击#郑亚伟#请点击http://www.aidu.com 请点击@郑亚伟 请😅😇点击#郑亚伟#请点击http://www.baidu.com 请点击@郑伟 请点击#郑亚伟#请点击http://www.baidu.com 请点击@郑亚伟 请点击#郑亚伟#";
    NSAttributedString *attrStr = [[NSAttributedString alloc]initWithString:str];
    CGFloat height = [str boundingRectWithSize:CGSizeMake(320, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} context:nil].size.height;
    label.frame = CGRectMake(0, 0, 320, height);
    label.center = self.view.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20];
    label.attributedText = attrStr;
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
}

- (void)zwLabel:(UILabel *)label didSelectedLinkText:(NSString *)text{
    NSLog(@"********************%@",text);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
