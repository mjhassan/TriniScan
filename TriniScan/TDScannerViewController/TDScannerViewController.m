//
//  TDScannerViewController.m
//  TriniScan
//
//  Created by Jahid Hassan on 7/7/15.
//  Copyright (c) 2015 Jahid Hassan. All rights reserved.
//

#import "TDScannerViewController.h"

@interface TDScannerViewController () {
    AVCaptureDevice*            _device;
    AVCaptureSession*           _session;
    AVCaptureDeviceInput*       _input;
    AVCaptureMetadataOutput*    _output;
    AVCaptureVideoPreviewLayer* _previewLayer;
    
    UIView*                     _highlightView;
}

@end

@implementation TDScannerViewController
@synthesize delegate=_delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    [self configureSetup];
}

- (void)viewDidAppear:(BOOL)animated {
    if(_session) {
        [self autoRotateVideoOrientation];
        [_session startRunning];
    }else {
        // show alert
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
//    [self configureCameraForHighestFrameRate:_device];
    
    _session    = [AVCaptureSession new];
    
    NSError *error = nil;
    _input      = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    } else {
//        NSLog(@"Error: %@", error);
        // show alert
        [_delegate scanFailedWithError:error];
        [self close:nil];
        return;
    }
    
    _output                     = [AVCaptureMetadataOutput new];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    

    _previewLayer               = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity  = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_previewLayer];
    
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:closeButton];
}



- (void)configureCameraForHighestFrameRate:(AVCaptureDevice *)device {
    AVCaptureDeviceFormat *bestFormat = nil;
    AVFrameRateRange *bestFrameRateRange = nil;
    for ( AVCaptureDeviceFormat *format in [device formats] ) {
        for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
            if ( range.maxFrameRate > bestFrameRateRange.maxFrameRate ) {
                bestFormat = format;
                bestFrameRateRange = range;
            }
        }
    }
    if ( bestFormat ) {
        if ( [device lockForConfiguration:NULL] == YES ) {
            if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
            }else {
                NSLog(@"Auto Focus is not supported");
            }
            
            device.activeFormat = bestFormat;
            device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
            device.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
            [device unlockForConfiguration];
        }
    }
}

#pragma mark-
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self autoRotateVideoOrientation];
}

- (void)autoRotateVideoOrientation {
    if(!_previewLayer) return;
    
    [_previewLayer setFrame:self.view.bounds];
    
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
            [_session stopRunning];
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
}
@end
