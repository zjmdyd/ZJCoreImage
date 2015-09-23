//
//  ZJCIFilterCategoryViewController.m
//  ZJCoreImage
//
//  Created by YunTu on 15/9/9.
//  Copyright (c) 2015年 YunTu. All rights reserved.
//

#import "ZJCIFilterCategoryViewController.h"

#import "ZJCIFilterEffectViewController.h"

@interface ZJCIFilterCategoryViewController ()<UITableViewDataSource, UITableViewDelegate> {
    NSArray *_titles;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

static NSString *CELLID = @"filterCellID";

@implementation ZJCIFilterCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initAry];
}

/***********/

- (void)initAry {
    _titles = @[kCICategoryBlur, kCICategoryColorAdjustment, kCICategoryColorEffect, kCICategoryCompositeOperation, kCICategoryDistortionEffect, kCICategoryGenerator, kCICategoryGeometryAdjustment, kCICategoryGradient, kCICategoryHalftoneEffect, kCICategoryReduction, kCICategorySharpen, kCICategoryStylize, kCICategoryTileEffect, kCICategoryTransition];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELLID];
    }
    cell.textLabel.text = _titles[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZJCIFilterEffectViewController *vc = [[ZJCIFilterEffectViewController alloc] init];
    vc.category = _titles[indexPath.row];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
