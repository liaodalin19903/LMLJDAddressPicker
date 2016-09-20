//
//  ViewController.m
//  LMLJDAddressPickerDemo
//
//  Created by 优谱德 on 16/9/20.
//  Copyright © 2016年 优谱德. All rights reserved.
//

#import "ViewController.h"

#import "LMLJDAddressPicker.h"

@interface ViewController ()
{
    LMLJDAddressPicker *lml_ad;  // 地址选择
    
    
}

@property (nonatomic, copy) NSString *expLocationStr;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {

    lml_ad = [[LMLJDAddressPicker alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    lml_ad.isOpenState = NO;
    
    /* 设置默认地址 */
//    AMapLocationReGeocode *regeocode = [UserInfoStatic sharedUserInfoStatic].regeocode;
//    //NSString *address_default = [NSString stringWithFormat:@"%@-%@", regeocode.province, regeocode.city];
//    NSString *address_default = [NSString stringWithFormat:@"%@", regeocode.province];
    
    
    
    /*if ([address_default isEqualToString:@"(null)-(null)"]) {
     address_default = @"四川省-成都市";
     }*/
    
    
    NSString *address_default = @"四川省";
    
    if ([address_default isEqualToString:@"(null)"]) {
        address_default = @"四川省";
    }
    
    [lml_ad setDefaultAddress:address_default];
    
    
    __weak typeof(self) weakSelf = self;
    lml_ad.addressBlock = ^(NSString *addressStr) {
        
        if([addressStr isEqualToString:weakSelf.expLocationStr]) {
            
            return ;
        }
        
        NSLog(@"%@", addressStr);
        
        weakSelf.addressLabel.text =  _expLocationStr = addressStr;
      
    };
    
    [self.view addSubview:lml_ad];
}

- (IBAction)pickAddress:(UIButton *)sender {
    
    [lml_ad show];
}


@end
