//
//  JPErrorView.m
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "JPErrorView.h"



@implementation JPErrorView

- (instancetype)initError:(NSString *)errMsg
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        
        UITextView *text = [[UITextView alloc]initWithFrame:self.bounds];
        text.backgroundColor = [UIColor redColor];
        text.textColor = [UIColor whiteColor];
        text.font = [UIFont systemFontOfSize:20];
        text.userInteractionEnabled = NO;
        
        text.text = errMsg;
        
        [self addSubview:text];
        
    }
    return self;
}

@end
