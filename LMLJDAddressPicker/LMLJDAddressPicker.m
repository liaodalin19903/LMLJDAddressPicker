//
//  LMLJDAddressPicker.m
//  仿照京东地址选择器
//
//  Created by 优谱德 on 16/6/29.
//  Copyright © 2016年 优谱德. All rights reserved.
//

#import "LMLJDAddressPicker.h"
#import "LMLJDAdressPickerCell.h"
#import "LML_Util.h"

#define Head_Line_Color [UIColor colorWithWhite:242.0 / 255.0 alpha:1.0]
#define Head_Vertical_Line_Color [UIColor colorWithWhite:242.0 / 255.0 alpha:1.0]
#define HeadLabel_Selected_Color [UIColor colorWithRed:30.0/255.0 green:170.0/255.0 blue:61.0/255.0 alpha:1.0]
#define Trailer_Line_Color [UIColor colorWithWhite:242.0 / 255.0 alpha:1.0]
#define Height_Of_Trailer 20

@interface LMLJDAddressPicker () <UITableViewDelegate, UITableViewDataSource>
{
    
    // 全国地址字典
    NSDictionary *dic_of_china_address;

    // 三个tab的数据源
    NSMutableArray *dataOfProvince;
    NSMutableArray *dataOfCity;
    NSMutableArray *dataOfCountry;
}

@property (nonatomic, assign) CGRect allFrame;  // 自己空间的高度
@property (nonatomic, assign) float headHeight; // 默认
@property (nonatomic, assign) float rowHeight;  // 默认 44
@property (nonatomic, assign) int numberOfRow;  // 默认 6
@property (nonatomic, assign) BOOL needAniLine;  // 默认 6


/* 自己的部分 */
@property (nonatomic, strong) UIView *opacity_back;  // 这个是半透明度的黑色遮罩
@property (nonatomic, strong) UIView *headView;  // 头部
@property (nonatomic, strong) UIView *backOfTabAndTrailer; // table和尾部的back
@property (nonatomic, strong) UIScrollView *scrollView;    // 这个是省市县三个的back
@property (nonatomic, strong) UITableView *tab_province;  // 省份的tableView
@property (nonatomic, strong) UITableView *tab_city;      // 城市的tableView
@property (nonatomic, strong) UITableView *tab_country;   // 县的tableView
@property (nonatomic, strong) UIView *trailerView; // 尾部
@property (nonatomic, strong) UIImageView *trailerImage;  // 尾部的图片
@property (nonatomic, strong) UIView *trail_line;  // 尾部的线
@property (nonatomic, strong) UIButton *trailerButton;   // 尾部的按钮


@end

@implementation LMLJDAddressPicker

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        self.allFrame = frame;
        self.headHeight = 40;
        self.rowHeight = 44;
        self.numberOfRow = 6;
        [self initData];
        [self initUI];
    }
    
    /* 初始化self的状态 */

    self.backOfTabAndTrailer.frame = CGRectMake(_backOfTabAndTrailer.frame.origin.x, _backOfTabAndTrailer.frame.origin.y, _backOfTabAndTrailer.frame.size.width, 0.01);
    self.tab_province.frame = CGRectMake(self.tab_province.frame.origin.x, self.tab_province.frame.origin.y, self.tab_province.frame.size.width, 0.01);
    self.tab_city.frame = CGRectMake(self.tab_city.frame.origin.x, self.tab_city.frame.origin.y, self.tab_city.frame.size.width, 0.01);
    self.tab_country.frame = CGRectMake(self.tab_country.frame.origin.x, self.tab_country.frame.origin.y, self.tab_country.frame.size.width, 0.01);
    self.trailerView.frame = CGRectMake(_backOfTabAndTrailer.frame.origin.x, 0, self.trailerView.frame.size.width, 0.01);
    self.trailerImage.frame = CGRectMake(self.trailerImage.frame.origin.x, 0, self.trailerImage.frame.size.width, 0.01);
    self.trail_line.frame = CGRectMake(self.backOfTabAndTrailer.frame.origin.x, 0, self.trail_line.frame.size.width, 0.01);
    self.trailerButton.frame = CGRectMake(self.backOfTabAndTrailer.frame.origin.x, 0, self.trailerButton.frame.size.width, 0.01);
    
    self.opacity_back.alpha = 0.0;
    self.isOpenState = NO;
    
    self.provinceLabel.userInteractionEnabled = YES;
    self.cityLabel.userInteractionEnabled = NO;
    self.countryLabel.userInteractionEnabled = NO;
    
    self.scrollView.contentSize = CGSizeMake(_allFrame.size.width, 0);
    
    // 隐藏下面的
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.headHeight);
    
    return self;
}

#pragma mark - init

- (void)initData {

    /* 创建省份数据 */
    NSString *areaPlistPath = [[NSBundle mainBundle] pathForResource:@"LMLJDArea" ofType:@"plist"]; //NSString *path = [NSBundle mainBundle];
    dic_of_china_address = [[NSDictionary alloc] initWithContentsOfFile:areaPlistPath];
    
    
    dataOfProvince = [NSMutableArray arrayWithCapacity:0];
    dataOfCity = [NSMutableArray arrayWithCapacity:0];
    dataOfCountry = [NSMutableArray arrayWithCapacity:0];
    
    // 字典的遍历
    [dic_of_china_address enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //NSLog(@"key = %@ and obj = %@", key, obj);
        [dataOfProvince addObject:key];
    }];
    
    [dataOfProvince insertObject:@"全国" atIndex:0];  // 增加全国

}

- (void)initUI {

    /* 0.opacity back */
    self.opacity_back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _allFrame.size.width, _allFrame.size.height)];
    self.opacity_back.backgroundColor = [UIColor blackColor];
    self.opacity_back.alpha = 0.2;
    UITapGestureRecognizer *tapOpcityBack = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToOpacityBack:)];
    [self.opacity_back addGestureRecognizer:tapOpcityBack];
    
    [self addSubview:self.opacity_back];
    
    /* 1.header */
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _allFrame.size.width, self.headHeight)];
    self.headView.backgroundColor = [UIColor whiteColor];
    UIView *head_line = [[UIView alloc] initWithFrame:CGRectMake(0, _headHeight - 1, _allFrame.size.width, 1)];
    head_line.backgroundColor = Head_Line_Color;
    UIView *head_line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _allFrame.size.width, 1)];
    head_line2.backgroundColor = Head_Line_Color;
    
    [self.headView addSubview:head_line];
    [self.headView addSubview:head_line2];
    
    // 给header添加阴影
    [LML_Util addShadowToView:self.headView andShadowOpacity:0.2 shadowColor:[UIColor lightGrayColor] shadowRadius:2 shadowOffset:CGSizeMake(0, 1)];
    
    // 3个label
    self.provinceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _allFrame.size.width / 3, _headHeight)];
    self.provinceLabel.textAlignment = NSTextAlignmentCenter;
    self.provinceLabel.center = CGPointMake(_allFrame.size.width / 6.0, self.headHeight / 2);
    UITapGestureRecognizer *tap_province = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapProvince:)];
    [self.provinceLabel addGestureRecognizer:tap_province];
    self.provinceLabel.userInteractionEnabled = YES;
    self.provinceLabel.textColor = HeadLabel_Selected_Color;
    self.provinceLabel.font = [UIFont systemFontOfSize:16];
    
    
    self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _allFrame.size.width / 3, _headHeight)];
    self.cityLabel.textAlignment = NSTextAlignmentCenter;
    self.cityLabel.center = CGPointMake(_allFrame.size.width / 2.0, self.headHeight / 2);
    UITapGestureRecognizer *tap_city = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapCity:)];
    [self.cityLabel addGestureRecognizer:tap_city];
    self.cityLabel.userInteractionEnabled = YES;
    self.cityLabel.textColor = HeadLabel_Selected_Color;
    self.cityLabel.font = [UIFont systemFontOfSize:16];
    
    
    self.countryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _allFrame.size.width / 3, _headHeight)];
    self.countryLabel.textAlignment = NSTextAlignmentCenter;
    self.countryLabel.center = CGPointMake(_allFrame.size.width * 5 / 6.0, self.headHeight / 2);
    UITapGestureRecognizer *tap_country = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapCountry:)];
    [self.countryLabel addGestureRecognizer:tap_country];
    self.countryLabel.userInteractionEnabled = YES;
    self.countryLabel.textColor = HeadLabel_Selected_Color;
    self.countryLabel.font = [UIFont systemFontOfSize:16];
    
    
    [self.headView addSubview:self.provinceLabel];
    [self.headView addSubview:self.cityLabel];
    [self.headView addSubview:self.countryLabel];
    // 两个竖线
    UIView *vertical_line01 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _headHeight / 3.0)];
    vertical_line01.backgroundColor = Head_Vertical_Line_Color;
    vertical_line01.center = CGPointMake(_allFrame.size.width / 3.0, self.headHeight / 2);
    
    UIView *vertical_line02 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _headHeight / 3.0)];
    vertical_line02.backgroundColor = Head_Vertical_Line_Color;
    vertical_line02.center = CGPointMake(_allFrame.size.width * 2 / 3.0, self.headHeight / 2);
    
    [self.headView addSubview:vertical_line01];
    [self.headView addSubview:vertical_line02];
    
    [self addSubview:_headView];
    /* 2. backOfTabAndTrailer scroll与tabs */
    
    self.backOfTabAndTrailer = [[UIView alloc] initWithFrame:CGRectMake(0, self.headHeight, _allFrame.size.width, _allFrame.size.height - _headHeight)];
    
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _allFrame.size.width, _rowHeight * _numberOfRow )];  // 高度为多少个cell乘以每一个cell的高度
    
    self.tab_province = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _allFrame.size.width, _rowHeight * _numberOfRow)];
    self.tab_province.dataSource = self;
    self.tab_province.delegate = self;
    self.tab_province.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tab_city = [[UITableView alloc] initWithFrame:CGRectMake(_allFrame.size.width, 0, _allFrame.size.width, _rowHeight * _numberOfRow)];
    self.tab_city.dataSource = self;
    self.tab_city.delegate = self;
    self.tab_city.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tab_country = [[UITableView alloc] initWithFrame:CGRectMake(_allFrame.size.width * 2, 0, _allFrame.size.width, _rowHeight * _numberOfRow)];
    self.tab_country.dataSource = self;
    self.tab_country.delegate = self;
    self.tab_country.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.scrollView addSubview:self.tab_province];
    [self.scrollView addSubview:self.tab_city];
    [self.scrollView addSubview:self.tab_country];
    
    self.scrollView.contentSize = CGSizeMake(_allFrame.size.width * 3, _rowHeight * _numberOfRow);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    
    [self.backOfTabAndTrailer addSubview:self.scrollView];
    
    /* 3.trailerView 尾部的弹起 */
    self.trailerView = [[UIView alloc] initWithFrame:CGRectMake(0, _rowHeight * _numberOfRow, _allFrame.size.width, Height_Of_Trailer)];
    self.trailerView.backgroundColor = [UIColor whiteColor];
    self.trailerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Height_Of_Trailer / 6.0, Height_Of_Trailer / 20.0)];
    self.trailerImage.contentMode = UIViewContentModeScaleAspectFit;
    self.trailerImage.clipsToBounds = YES;
    self.trailerImage.center = CGPointMake(_allFrame.size.width / 2.0, Height_Of_Trailer / 2.0);
    self.trailerImage.image = [UIImage imageNamed:@"up_jiantou.png"];
    [self.trailerView addSubview:self.trailerImage];
    self.trailerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.trailerButton addTarget:self action:@selector(respondsToTrailerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.trailerView addSubview:self.trailerButton];
    self.trailerButton.frame = CGRectMake(0, 0, _allFrame.size.width, Height_Of_Trailer);
    
    self.trail_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _allFrame.size.width, 1)];
    self.trail_line.backgroundColor = Trailer_Line_Color;
    
    [self.trailerView addSubview:self.trail_line];
    
    [self.backOfTabAndTrailer addSubview:self.trailerView];
    
    [self addSubview:self.backOfTabAndTrailer];
    
    
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == _tab_province) {
        
        return dataOfProvince.count;
    }else if (tableView == _tab_city) {
    
        return dataOfCity.count;
    }else {
    
        return dataOfCountry.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cell_id = @"LMLJDAdressPickerCell";
    
    LMLJDAdressPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"LMLJDAdressPickerCell" owner:self options:nil].lastObject;
        
    }
    
    /* 配置cell */
    if (tableView == _tab_province) {
        cell.addressName.text = dataOfProvince[indexPath.row];
    }else if (tableView == _tab_city) {
        cell.addressName.text = dataOfCity[indexPath.row];
    }else {
        cell.addressName.text = dataOfCountry[indexPath.row];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == _tab_province) {
        
        // 找到cell
        LMLJDAdressPickerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.provinceLabel.text = cell.addressName.text;
        
        if ([cell.addressName.text isEqualToString:@"全国"]) {
            
            self.cityLabel.text = @"";
            self.cityLabel.userInteractionEnabled = NO;
            self.countryLabel.text = @"";
            self.countryLabel.userInteractionEnabled = NO;
            self.scrollView.contentSize = CGSizeMake(_allFrame.size.width, self.scrollView.bounds.size.height);
            [self dismiss];
            
        }else{
            
            /* 给第二级添加数据 */
            [self parseDataToCities];
            
            self.scrollView.contentSize = CGSizeMake(_allFrame.size.width * 2, self.scrollView.bounds.size.height);
            self.cityLabel.userInteractionEnabled = YES;
           
            self.cityLabel.text = @"请选择";
            self.countryLabel.text = @"";
            self.countryLabel.userInteractionEnabled = NO;
            [self.scrollView setContentOffset:CGPointMake(_allFrame.size.width, 0) animated:YES];
            
        }
        
    }else if (tableView == _tab_city) {
    
        // 找到cell
        LMLJDAdressPickerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.cityLabel.text = cell.addressName.text;
        
        if ([cell.addressName.text isEqualToString:@"不限"]) {
            self.countryLabel.text = @"";
            self.countryLabel.userInteractionEnabled = NO;
            self.scrollView.contentSize = CGSizeMake(_allFrame.size.width * 2, self.scrollView.bounds.size.height);
            [self dismiss];
            
        }else{
            
            /* 给第二级添加数据 */
            [self parseDataToCountries];
            
            self.scrollView.contentSize = CGSizeMake(_allFrame.size.width * 3, self.scrollView.bounds.size.height);
            self.countryLabel.userInteractionEnabled = YES;
            
            self.countryLabel.text = @"请选择";
            [self.scrollView setContentOffset:CGPointMake(_allFrame.size.width * 2, 0) animated:YES];
        
        }

        
    }else {
        
        // 找到cell
        LMLJDAdressPickerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.countryLabel.text = cell.addressName.text;
        [self dismiss];
    }
    
    /* 自己的地址是多少 */
    if ([_cityLabel.text isEqualToString:@"不限"] || [_cityLabel.text isEqualToString:@"请选择"]) {
        
        _address = _provinceLabel.text;
    }
    else if ([_countryLabel.text isEqualToString:@"不限"] || [_countryLabel.text isEqualToString:@"请选择"]) {
        
        _address = [NSString stringWithFormat:@"%@-%@", _provinceLabel.text, _cityLabel.text];
    }else {
    
        _address = [NSString stringWithFormat:@"%@-%@-%@", _provinceLabel.text, _cityLabel.text, _countryLabel.text];
    }
    
    
    
}

#pragma mark - responds event

- (void)respondsToTrailerButton:(UIButton *)button {

    [self dismiss];
}

- (void)respondsToOpacityBack:(UITapGestureRecognizer *)tap {

    [self dismiss];
}


- (void)respondsToTapProvince:(UITapGestureRecognizer *)tap_province {

    if (_isOpenState == NO) {
        
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }else {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    [self show];
}

- (void)respondsToTapCity:(UITapGestureRecognizer *)tap_city {
    
    if (_isOpenState == NO) {
        
        [self.scrollView setContentOffset:CGPointMake(_allFrame.size.width, 0) animated:NO];
    }else {
        [self.scrollView setContentOffset:CGPointMake(_allFrame.size.width, 0) animated:YES];
    }
    [self show];
}

- (void)respondsToTapCountry:(UITapGestureRecognizer *)tap_country {
    
    if (_isOpenState == NO) {
        [self.scrollView setContentOffset:CGPointMake(_allFrame.size.width * 2, 0) animated:NO];
    }else {
        [self.scrollView setContentOffset:CGPointMake(_allFrame.size.width * 2, 0) animated:YES];
    }
    
    [self show];
}


#pragma mark - setter

//// 设置头部的高度
//- (void)setHeadHeight:(float)headHeight {
//
//    self.headHeight = headHeight;
//}
//
//// 设置行高
//- (void)setRowHeight:(float)rowHeight {
//
//    self.rowHeight = rowHeight;
//}
//
//// 设置一个tabview多少行
//- (void)setNumberOfRow:(int)numberOfRow {
//    
//    self.numberOfRow = numberOfRow;
//}
//
//// 设置是否需要可以动画的线（地址labe下面）
//- (void)setNeedAniLine:(BOOL)needAniLine {
//
//    self.needAniLine = needAniLine;
//}

// 设置默认的位置  （经验交流 默认是市：四川省->成都市）
- (void)setDefaultAddress:(NSString *)defaultAddress {

    NSArray *addressArr = [defaultAddress componentsSeparatedByString:@"-"];
    
    
    // 省-市
    if (addressArr.count == 2) {
        
        self.provinceLabel.text = addressArr[0];
        self.cityLabel.text = addressArr[1];
        self.countryLabel.text = @"不限";
        
        self.cityLabel.userInteractionEnabled = YES;
        self.countryLabel.userInteractionEnabled = YES;
        /* 给第二级添加数据 */
        [self parseDataToCities];
        /* 给第三级添加数据 */
        [self parseDataToCountries];
        
    }
    // 省市县
    else if (addressArr.count == 3) {
    
        self.provinceLabel.text = addressArr[0];
        self.cityLabel.text = addressArr[1];
        self.countryLabel.text = addressArr[2];
        self.cityLabel.userInteractionEnabled = YES;
        self.countryLabel.userInteractionEnabled = YES;
        
        /* 给第二级添加数据 */
        [self parseDataToCities];
        
        /* 给第三级添加数据 */
        [self parseDataToCountries];
    }
    // 省
    else {
    
        self.provinceLabel.text = addressArr[0];
        self.cityLabel.text = @"不限";
        self.cityLabel.userInteractionEnabled = YES;
        
        /* 给第二级添加数据 */
        [self parseDataToCities];
    }
}

#pragma mark - update 

// 更新scrollView的contentSize
- (void)updateScrollViewContentSize {

    
}

#pragma mark - 解析数据

- (void)parseDataToCities {
    
    [dataOfCity removeAllObjects];
    
    NSString *province_str = self.provinceLabel.text;
    NSDictionary *dic_cities = [dic_of_china_address objectForKey:province_str];
    
    NSMutableArray *mut_arr = [NSMutableArray arrayWithCapacity:0];
    [dic_cities enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        [mut_arr addObject:key];
    }];
    [mut_arr insertObject:@"不限" atIndex:0];
    
    dataOfCity = mut_arr;
    
    [self.tab_city reloadData];
    
}

- (void)parseDataToCountries {

    [dataOfCountry removeAllObjects];
    NSString *province_str = self.provinceLabel.text;
    NSDictionary *dic_cities = [dic_of_china_address objectForKey:province_str];
    
    __block NSMutableArray *mut_arr = [NSMutableArray arrayWithCapacity:0];
    [dic_cities enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([key isEqualToString:self.cityLabel.text]) {
            
            mut_arr = [(NSArray *)obj mutableCopy];
        }
    }];
    [mut_arr insertObject:@"不限" atIndex:0];
    
    dataOfCountry = mut_arr;
    
    [self.tab_country reloadData];
}

#pragma mark - show and dismiss

- (void)show{
    
    if (self.isOpenState == YES ) {
        return;
    }
    
    // 隐藏scrollView 不然其下不能点击
    //self.scrollView.hidden = NO;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _allFrame.size.height);
   
    
    [UIView animateWithDuration:0.3 animations:^{
        
        //CGRect frame = self.backOfTabAndTrailer.frame;
        self.opacity_back.alpha = 0.2;
        
        //frame.size.height = _rowHeight * _numberOfRow;
        //[self.backOfTabAndTrailer setFrame:frame];
        
        self.backOfTabAndTrailer.frame = CGRectMake(_backOfTabAndTrailer.frame.origin.x, _backOfTabAndTrailer.frame.origin.y, _backOfTabAndTrailer.frame.size.width, _rowHeight * _numberOfRow);
        self.tab_province.frame = CGRectMake(self.tab_province.frame.origin.x, self.tab_province.frame.origin.y, self.tab_province.frame.size.width, _rowHeight * _numberOfRow);
        self.tab_city.frame = CGRectMake(self.tab_city.frame.origin.x, self.tab_city.frame.origin.y, self.tab_city.frame.size.width, _rowHeight * _numberOfRow);
        self.tab_country.frame = CGRectMake(self.tab_country.frame.origin.x, self.tab_country.frame.origin.y, self.tab_country.frame.size.width, _rowHeight * _numberOfRow);
        self.trailerView.frame = CGRectMake(_backOfTabAndTrailer.frame.origin.x, _rowHeight * _numberOfRow, self.trailerView.frame.size.width, Height_Of_Trailer);
        self.trailerImage.frame = CGRectMake(_allFrame.size.width / 2 - Height_Of_Trailer / 2, 0, Height_Of_Trailer, Height_Of_Trailer);
        self.trail_line.frame = CGRectMake(self.backOfTabAndTrailer.frame.origin.x, 0, self.trail_line.frame.size.width, 1);
        self.trailerButton.frame = CGRectMake(self.backOfTabAndTrailer.frame.origin.x, 0, self.trailerButton.frame.size.width, 1);
        
    } completion:^(BOOL finished){
        
        self.isOpenState = YES;
        
        /* 让tabview滚到被选中的地方 */
        if (![self.provinceLabel.text isEqualToString:@""] && dataOfProvince.count != 0) {
            for (int i = 0; i < dataOfProvince.count; i ++) {
                
                if ([dataOfProvince[i] isEqualToString:self.provinceLabel.text]) {
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [_tab_province selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                }
            }
            
        }
        if (![self.cityLabel.text isEqualToString:@""] && dataOfCity.count != 0) {
            for (int i = 0; i < dataOfCity.count; i ++) {
                
                if ([dataOfCity[i] isEqualToString:self.cityLabel.text]) {
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [_tab_city selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                }
            }
            
        }
        if (![self.countryLabel.text isEqualToString:@""] && dataOfCountry.count != 0) {
            for (int i = 0; i < dataOfCountry.count; i ++) {
                
                if ([dataOfCountry[i] isEqualToString:self.countryLabel.text]) {
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [_tab_country selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                }
            }
            
        }
        
        
        
    }];
    
    
    
}

// 弹起tab
- (void)dismiss {
    
    if (self.isOpenState == NO ) {
        return;
    }
    
    if ([self.cityLabel.text isEqualToString:@"请选择"]) {
        
        self.cityLabel.userInteractionEnabled = YES;
        self.cityLabel.text = @"不限";
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        LMLJDAdressPickerCell *cell = [self.tab_city cellForRowAtIndexPath:indexPath];
        [cell setSelected:YES];
        
        
    }
    if ([self.countryLabel.text isEqualToString:@"请选择"]) {
        
        self.countryLabel.userInteractionEnabled = YES;
        self.countryLabel.text = @"不限";
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        LMLJDAdressPickerCell *cell = [self.tab_country cellForRowAtIndexPath:indexPath];
        [cell setSelected:YES];
    }
    
    
    /* 选择后的地址str */
    NSString *addressStr; //
    
    if ([self.cityLabel.text isEqualToString:@"不限"]) {
        addressStr = self.provinceLabel.text;
    }else if ([self.countryLabel.text isEqualToString:@"不限"]) {
    
        addressStr = [NSString stringWithFormat:@"%@-%@", self.provinceLabel.text, self.cityLabel.text];
    }else if ([self.provinceLabel.text isEqualToString:@"全国"]){
    
        addressStr = @"all";  // 所有
    }
    
    else {
    
        addressStr = [NSString stringWithFormat:@"%@-%@-%@", self.provinceLabel.text, self.cityLabel.text, self.countryLabel.text];
    }
    
    self.addressBlock(addressStr);
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = self.backOfTabAndTrailer.frame;
        self.opacity_back.alpha = 0.0;
        
        //frame.size.height=0.1;
        //[self.backOfTabAndTrailer setFrame:frame];
        
        self.backOfTabAndTrailer.frame = CGRectMake(_backOfTabAndTrailer.frame.origin.x, _backOfTabAndTrailer.frame.origin.y, _backOfTabAndTrailer.frame.size.width, 0.01);
        self.tab_province.frame = CGRectMake(self.tab_province.frame.origin.x, self.tab_province.frame.origin.y, self.tab_province.frame.size.width, 0.01);
        self.tab_city.frame = CGRectMake(self.tab_city.frame.origin.x, self.tab_city.frame.origin.y, self.tab_city.frame.size.width, 0.01);
        self.tab_country.frame = CGRectMake(self.tab_country.frame.origin.x, self.tab_country.frame.origin.y, self.tab_country.frame.size.width, 0.01);
        self.trailerView.frame = CGRectMake(_backOfTabAndTrailer.frame.origin.x, 0, self.trailerView.frame.size.width, 0.01);
        self.trailerImage.frame = CGRectMake(self.trailerImage.frame.origin.x, 0, self.trailerImage.frame.size.width, 0.01);
        self.trail_line.frame = CGRectMake(self.backOfTabAndTrailer.frame.origin.x, 0, self.trail_line.frame.size.width, 0.01);
        self.trailerButton.frame = CGRectMake(self.backOfTabAndTrailer.frame.origin.x, 0, self.trailerButton.frame.size.width, 0.01);
        
        
    } completion:^(BOOL finished){
        
        self.isOpenState = NO;
        
        // 隐藏
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.headHeight);
    }];
    
}

#pragma mark - getter

- (NSString *)address {

    /* 自己的地址是多少 */
    if ([_cityLabel.text isEqualToString:@"不限"] || [_cityLabel.text isEqualToString:@"请选择"]) {
        
        _address = _provinceLabel.text;
    }
    else if ([_countryLabel.text isEqualToString:@"不限"] || [_countryLabel.text isEqualToString:@"请选择"]) {
        
        _address = [NSString stringWithFormat:@"%@-%@", _provinceLabel.text, _cityLabel.text];
    }else {
        
        _address = [NSString stringWithFormat:@"%@-%@-%@", _provinceLabel.text, _cityLabel.text, _countryLabel.text];
    }
    
    return _address;
}

@end
