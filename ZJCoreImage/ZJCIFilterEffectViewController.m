//
//  ZJCIFilterEffectViewController.m
//  ZJCoreImage
//
//  Created by YunTu on 15/9/9.
//  Copyright (c) 2015年 YunTu. All rights reserved.
//

#import "ZJCIFilterEffectViewController.h"
#import "ZJSliderView.h"
#import "UIViewExt.h"

@interface ZJCIFilterEffectViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, ZJSliderValueChangeDelegate> {
    NSArray *_filterNames;
    NSMutableArray *_inputKeys, *_zjSliderViews;
    UIImageView *_effectIV;
    
    UIScrollView *_scrollView;
    UIView *_pickerBgView;
    UIPickerView *_pickerView;
    BOOL _isFirstInit;
    NSInteger _selectRow;
    UITapGestureRecognizer *_tapGesture;
}

@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) CIImage *inputImage;
@end

@implementation ZJCIFilterEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initAry];
    [self loadSubviews];
    [self initSetting];
}

- (void)initAry {
    _filterNames = [CIFilter filterNamesInCategory:self.category];
    _inputKeys = [NSMutableArray array];
    _zjSliderViews = [NSMutableArray array];
    
    NSLog(@"_filterNames = %@", _filterNames);
}

- (void)loadSubviews {
    self.title = self.category;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换滤镜" style:UIBarButtonItemStylePlain target:self action:@selector(showPickerView)];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height - 64)];
    [self.view addSubview:_scrollView];
    
    for (int i = 0; i < 2; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 250*i, _scrollView.width, 240)];
        iv.image = [UIImage imageNamed:@"1.jpg"];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        if (i == 1) {
            _effectIV = iv;
        }
        [_scrollView addSubview:iv];
    }

    // pickerView
    _pickerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bottom, self.view.width, 260)];
    _pickerBgView.backgroundColor = [UIColor whiteColor];
    _pickerBgView.hidden = YES;
    [self.view addSubview:_pickerBgView];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, _pickerBgView.width, 216)];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    _pickerView.layer.borderWidth = 0.8;
    _pickerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_pickerBgView addSubview:_pickerView];
    
    UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, _pickerView.bottom + 5, 200, 35)];
    selectBtn.center = CGPointMake(_pickerBgView.center.x, selectBtn.center.y);
    selectBtn.backgroundColor = [UIColor greenColor];
    [selectBtn setTitle:@"选择" forState:UIControlStateNormal];
    [selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(selectFilterEffect) forControlEvents:UIControlEventTouchUpInside];
    [_pickerBgView addSubview:selectBtn];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:_tapGesture];
}

- (void)tap {
    [self hiddenPickerViewAndCreateFilter];
}

- (void)selectFilterEffect {
    [self hiddenPickerViewAndCreateFilter];
}

- (void)showPickerView {
    if (_pickerBgView.isHidden) {
        _pickerBgView.hidden = NO;
        _tapGesture.enabled = YES;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = _pickerBgView.frame;
            frame.origin.y -= _pickerBgView.height;
            _pickerBgView.frame = frame;
        }];
    }
}

- (void)hiddenPickerViewAndCreateFilter {
    if (!_pickerBgView.isHidden) {
        _tapGesture.enabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _pickerBgView.frame;
            frame.origin.y += _pickerBgView.height;
            _pickerBgView.frame = frame;
        } completion:^(BOOL finished) {
            _pickerBgView.hidden = YES;
            
            NSInteger row = [_pickerView selectedRowInComponent:0];
            if (_selectRow != row) {
                [self createFilterWithName:_filterNames[row]];
                _selectRow = row;
            }
        }];
    }
}

- (void)initSetting {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];
    
    self.context = [CIContext contextWithOptions:nil];
    self.inputImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
    
    [self createFilterWithName:_filterNames.firstObject];
}

- (void)createFilterWithName:(NSString *)name {
    self.filter = nil;
    [_inputKeys removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.filter = [CIFilter filterWithName:name keysAndValues:kCIInputImageKey, self.inputImage, nil];
        NSLog(@"inputKeys = %@", self.filter.inputKeys);
        for (NSString *str in self.filter.inputKeys) {
            if (![str isEqualToString:@"inputImage"]) {
                [_inputKeys addObject:@{str : [self.filter valueForKey:str]}];
            }
            NSLog(@"key = %@, value = %@, class = %@", str, [self.filter valueForKey:str], [[self.filter valueForKey:str] class]);
        }
        
        CIImage *outputImage = [self.filter outputImage];

        CGImageRef cgImg = [self.context createCGImage:outputImage fromRect:[outputImage extent]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            _effectIV.image = [UIImage imageWithCGImage:cgImg];
            CGImageRelease(cgImg);
            
            if (!_isFirstInit) {
                [self initSettingSliderView];
                _isFirstInit = YES;
            }else {
                [self resettingSliderValue];
            }
        });
    });
}

- (void)resettingSliderValue {
    NSInteger addKeyCount = _inputKeys.count - _zjSliderViews.count;
    if (addKeyCount > 0) {
        
    }else if (addKeyCount < 0) {
        
    }
    
    for (int i = 0; i < _zjSliderViews.count; i++) {
        NSDictionary *dic = _inputKeys[i];
        NSString *key = dic.allKeys.firstObject;
        
        ZJSliderView *zjSliderView = _zjSliderViews[i];
        zjSliderView.titleLabel.text = key;
        if ([dic[key] floatValue] < FLT_EPSILON) {  // 如果值为0
            zjSliderView.slider.maximumValue = 10;
        }else {
            zjSliderView.slider.maximumValue = [dic[key] floatValue] * 3;
        }
        zjSliderView.slider.value = [dic[key] floatValue];
        zjSliderView.valueLabel.text = [NSString stringWithFormat:@"%@", dic[key]];
    }
}

- (void)initSettingSliderView {
    for (int i = 0; i < _inputKeys.count; i++) {
        NSDictionary *dic = _inputKeys[i];
        NSString *key = dic.allKeys.firstObject;
        
        ZJSliderView *zjSliderView = [[ZJSliderView alloc] initWithFrame:CGRectMake(0, _effectIV.bottom + 5 + 80 * i, self.view.width, 70)];
        zjSliderView.slider.tag = i;
        zjSliderView.titleLabel.text = key;
        zjSliderView.slider.maximumValue = [dic[key] floatValue] * 3;
        zjSliderView.slider.value = [dic[key] floatValue];
        zjSliderView.valueLabel.text = [NSString stringWithFormat:@"%@", dic[key]];
        zjSliderView.delegate = self;
        [_zjSliderViews addObject:zjSliderView];
        [_scrollView addSubview:zjSliderView];
        
        if (i == _inputKeys.count - 1) {
            _scrollView.contentSize = CGSizeMake(0, zjSliderView.bottom);
        }
    }
}

- (UIImage *)createUIImagewithCIImage:(CIImage *)inputImage {
    /*
    self.filter = [CIFilter filterWithName:@"CIZoomBlur" keysAndValues:kCIInputImageKey, self.inputImage, nil];
    NSLog(@"inputKeys = %@", self.filter.inputKeys);
    for (NSString *str in self.filter.inputKeys) {
        if (![str isEqualToString:@"inputImage"]) {
            [_inputKeys addObject:@{str : [self.filter valueForKey:str]}];
        }
        NSLog(@"key = %@, value = %@, class = %@", str, [self.filter valueForKey:str], [[self.filter valueForKey:str] class]);
    }
    
    CIImage *outputImage = [self.filter outputImage];
    NSLog(@"extent = %@", NSStringFromCGRect(outputImage.extent));
    NSLog(@"outimage = %@, properties = %@", outputImage, outputImage.properties);
    CGImageRef cgImg = [self.context createCGImage:outputImage fromRect:[outputImage extent]];
    _effectIV.image = [UIImage imageWithCGImage:cgImg];
    CGImageRelease(cgImg);
    
    */
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    //  @"CIGaussianBlur" is OK.
    /*  but @"CIZoomBlur" crashed:
            Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[CIVector floatValue]: unrecognized selector sent to instance 0x156210a0'
     */
    CIFilter *filter = [CIFilter filterWithName:@"CIZoomBlur" keysAndValues:kCIInputImageKey, inputImage, nil];
    CIImage *outputImage = [filter outputImage];

    CGImageRef cgImg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *image = [UIImage imageWithCGImage:cgImg];
    CGImageRelease(cgImg);
    
    return image;
}

#pragma mark - ZJSliderValueChangeDelegate

- (void)zjSliderValueDidChange:(ZJSliderView *)sliderView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *dic = _inputKeys[sliderView.tag];
        [self.filter setValue:@(sliderView.slider.value) forKey:dic.allKeys.firstObject];
        
        CIImage *outputImage = [self.filter outputImage];
        CGImageRef cgImg = [self.context createCGImage:outputImage fromRect:[outputImage extent]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            sliderView.valueLabel.text = @(sliderView.slider.value).stringValue;
            _effectIV.image = [UIImage imageWithCGImage:cgImg];
            CGImageRelease(cgImg);
        });
    });
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _filterNames.count;
}

#pragma mark - UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _filterNames[row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
