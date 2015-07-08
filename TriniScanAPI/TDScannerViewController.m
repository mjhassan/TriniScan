//
//  TDScannerViewController.m
//  TriniScan
//
//  Created by Jahid Hassan on 7/7/15.
//  Copyright (c) 2015 Jahid Hassan. All rights reserved.
//

#import "TDScannerViewController.h"

#define iPad UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface TDScannerViewController () {
    AVCaptureDevice*            _device;
    AVCaptureSession*           _session;
    AVCaptureDeviceInput*       _input;
    AVCaptureMetadataOutput*    _output;
    AVCaptureVideoPreviewLayer* _previewLayer;
    AVCaptureDeviceFormat*      _format;
    CMTime                      _minFrame, _maxFrame;
    
    UIView*                     _highlightView;
    UIView*                     laserView;
    CGRect                      _selfBounds;
}

@end

@implementation TDScannerViewController
@synthesize delegate        =_delegate;
@synthesize enableAnimation =_enableAnimation;
@synthesize enableAutoFocus =_enableAutoFocus;
@synthesize enableFlash     =_enableFlash;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(nibNameOrNil.length == 0) {
        nibNameOrNil = [NSStringFromClass([self class]) stringByAppendingString:iPad ? @"~iPad":@"~iPhone"];
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _enableAnimation    = YES;
        _manualControl      = NO;
        _enableAutoFocus    = YES;
        _enableFlash        = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    closeButton.hidden = ![self isModal];
    
    [self configureSetup];
}

- (void)viewDidAppear:(BOOL)animated {
    if(_session) {
        [self calculateBoundsForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        [self autoRotateVideoOrientation];
        if(!_manualControl)
            [self startScaning];
    }else {
        // show alert
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [self close:nil];
    }
}

- (IBAction)close:(__unused id)sender {
    if(!_manualControl)
        [self stopScaning];
    
    if([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)isModal {
    return ![self isMovingToParentViewController];
}

#pragma mark -
- (void)configureSetup {
    if(_session) return;
    
    _highlightView                      =   [UIView new];
    _highlightView.autoresizingMask     =   UIViewAutoresizingFlexibleTopMargin |
                                            UIViewAutoresizingFlexibleLeftMargin|
                                            UIViewAutoresizingFlexibleRightMargin|
                                            UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor    =   [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth    =   3;
    [self.view addSubview:_highlightView];
    
    _device     = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _session    = [AVCaptureSession new];
    
    NSError *error = nil;
    _input      = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    } else {
        [_delegate scanFailedWithError:error];
        [self close:nil];
        return;
    }
    
    _output                     = [AVCaptureMetadataOutput new];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _format   = _device.activeFormat;
    _minFrame = _device.activeVideoMinFrameDuration;
    _maxFrame = _device.activeVideoMaxFrameDuration;

    _previewLayer               = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity  = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_previewLayer];
    
    [self.view bringSubviewToFront:closeButton];
}

- (void)startOrAdjustLeaser {
    [self clearLeaser];
    
    laserView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.25*_selfBounds.size.height, _selfBounds.size.width, 1)];
    laserView.backgroundColor = [UIColor redColor];
    laserView.layer.shadowColor = [UIColor redColor].CGColor;
    laserView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    laserView.layer.shadowOpacity = 0.6;
    laserView.layer.shadowRadius = 1.5;
    laserView.alpha = 0.0;
    if (![self.view.subviews containsObject:laserView])
        [self.view addSubview:laserView];
    
    // Add the line
    [UIView animateWithDuration:0.2 animations:^{
        laserView.alpha = 1.0;
    }];
    
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut animations:^{
        laserView.frame = CGRectMake(0, 0.75*_selfBounds.size.height, _selfBounds.size.width, 1);
    } completion:nil];
}

- (void)clearLeaser {
    [laserView removeFromSuperview];
    laserView = nil;
}

#pragma mark -
- (void)startScaning {
    [_session startRunning];
    
    if(_enableAnimation) {
        [self startOrAdjustLeaser];
    }
}

- (void)stopScaning {
    [_session stopRunning];
    
    
    [UIView animateWithDuration:0.2 animations:^{
        laserView.alpha = 0.0;
    }];
}

- (void)setEnableAnimation:(BOOL)enableAnimation {
    _enableAnimation = enableAnimation;
    
    if(_enableAnimation) {
        [self startOrAdjustLeaser];
    }else {
        [self clearLeaser];
    }
}

- (void)setManualControl:(BOOL)manualControl {
    _manualControl = manualControl;
}

- (void)setEnableAutoFocus:(BOOL)enableAutoFocus {
    // check if device is available
    if(!_device) NSLog(@"Device not found");
    
    // Check if Auto-Focus is supported
    if (![_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {NSLog(@"Auto Focus is not supported"); return;}
    
    // change the property
    _enableAutoFocus = enableAutoFocus;
    
    // Create the error object
    NSError *error;
    
    // Lock the hardware configuration to prevent other apps from changing the configuration
    if ( [_device lockForConfiguration:&error] == YES ) {
        
        // set auto focus
        if(_enableAutoFocus){
            [self resetFrame];
            
            [_device setFocusMode:AVCaptureFocusModeAutoFocus];
        } else {
            [_device setFocusMode:AVCaptureFocusModeLocked];
        }
        
        // Unlock the hardware configuration
        [_device unlockForConfiguration];
    }else {
        NSLog(@"[TriniScan] %@", error);
    }
}

- (void)setEnableFlash:(BOOL)enableFlash {
    // check if device is available
    if(!_device) NSLog(@"Device not found");
    
    // Check if flash is supported
    if (![_device isFlashAvailable] && ![_device isFlashModeSupported:AVCaptureFlashModeOn]) {NSLog(@"Flash not supported"); return;}
    
    // change the property
    _enableFlash = enableFlash;
    
    // Create the error object
    NSError *error;
    
    // Lock the hardware configuration to prevent other apps from changing the configuration
    if ([_device lockForConfiguration:&error]) {
        // Set the camera flash
        [_device setFlashMode:_enableFlash?AVCaptureFlashModeOn:AVCaptureFlashModeOff];
        
        // Unlock the hardware configuration
        [_device unlockForConfiguration];
    } else {
        NSLog(@"[TriniScan] %@", error);
    }
}

- (void)configureCameraForHighestFrameRate {
    AVCaptureDeviceFormat *bestFormat       = nil;
    AVFrameRateRange *bestFrameRateRange    = nil;
    for ( AVCaptureDeviceFormat *format in [_device formats] ) {
        for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
            if ( range.maxFrameRate > bestFrameRateRange.maxFrameRate ) {
                bestFormat          = format;
                bestFrameRateRange  = range;
            }
        }
    }
    if ( bestFormat ) {
        if ( [_device lockForConfiguration:NULL] == YES ) {
            self.enableAutoFocus                = NO;
            
            _device.activeFormat                = bestFormat;
            _device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
            _device.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
            [_device unlockForConfiguration];
        }
    }
}

- (void)resetFrame {
    _device.activeFormat                = _format;
    _device.activeVideoMinFrameDuration = _minFrame;
    _device.activeVideoMaxFrameDuration = _maxFrame;
}

#pragma mark-
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self calculateBoundsForOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self autoRotateVideoOrientation];
}

- (void)calculateBoundsForOrientation:(UIInterfaceOrientation)orientation {
    CGSize size = self.view.bounds.size;
    if(UIInterfaceOrientationIsPortrait(orientation)) {
        size = CGSizeMake(MIN(size.width, size.height), MAX(size.width, size.height));
    }else {
        size = CGSizeMake(MAX(size.width, size.height), MIN(size.width, size.height));
    }
    _selfBounds = (CGRect){(CGPoint){0.f, 0.f}, size};
    
    [_previewLayer setFrame:_selfBounds];
    
    if(_enableAnimation) {
        [self startOrAdjustLeaser];
    }
}

- (void)autoRotateVideoOrientation {
    if(!_previewLayer) return;
    
    UIInterfaceOrientation orientation                = [UIApplication sharedApplication].statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            break;
    }
}

#pragma mark- AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode,
                              AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject       = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect   = barCodeObject.bounds;
                detectionString     = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil) {
            [self stopScaning];
#if DEBUG
            NSLog(@"\n%@", detectionString);
#endif
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_delegate scanDidSucceededWithResult:detectionString];
               [self close:nil];
            });
            
            break;
        }
    }
    _highlightView.frame = highlightViewRect;
    [self.view bringSubviewToFront:_highlightView];
}
@end
