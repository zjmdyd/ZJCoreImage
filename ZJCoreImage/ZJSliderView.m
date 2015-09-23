//
//  ZJSliderView.m
//  ZJCoreImage
//
//  Created by YunTu on 15/9/9.
//  Copyright (c) 2015年 YunTu. All rights reserved.
//

#import "ZJSliderView.h"

@implementation ZJSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSetting];
    }
    return self;
}

- (void)initSetting {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(self.titleLabel.frame.size.width, 0, self.frame.size.width - self.titleLabel.frame.size.width, self.frame.size.height * 0.5)];
    [self.slider addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.slider];
    
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.slider.frame.origin.y + self.slider.frame.size.height, 100, self.frame.size.height * 0.5)];
    self.valueLabel.center = CGPointMake(self.center.x, self.valueLabel.center.y);
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.valueLabel];
}

- (void)sliderValueChange {
    [self.delegate zjSliderValueDidChange:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
