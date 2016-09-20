//
//  LML_Util.m
//  LMLJDAddressPickerDemo
//
//  Created by 优谱德 on 16/9/20.
//  Copyright © 2016年 优谱德. All rights reserved.
//

#import "LML_Util.h"

@implementation LML_Util

+ (void)addShadowToView:(UIView *)view andShadowOpacity:(float)shadowOpacity shadowColor:(UIColor *)shadowColor shadowRadius:(float)shadowRadius shadowOffset:(CGSize)shadowOffset {
    
    view.layer.shadowOpacity = shadowOpacity;// 阴影透明度
    
    view.layer.shadowColor = shadowColor.CGColor;// 阴影的颜色
    
    view.layer.shadowRadius = shadowRadius;// 阴影扩散的范围控制
    
    view.layer.shadowOffset = shadowOffset;// 阴影的范围
}

@end
