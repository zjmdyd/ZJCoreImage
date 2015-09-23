//
//  ZJSliderView.h
//  ZJCoreImage
//
//  Created by YunTu on 15/9/9.
//  Copyright (c) 2015年 YunTu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJSliderView;

@protocol ZJSliderValueChangeDelegate <NSObject>

@required

- (void)zjSliderValueDidChange:(ZJSliderView *)sliderView;

@end

@interface ZJSliderView : UIView

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@property (nonatomic, weak) id <ZJSliderValueChangeDelegate> delegate;

@end
