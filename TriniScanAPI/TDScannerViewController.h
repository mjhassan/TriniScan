//
//  TDScannerViewController.h
//  TriniScan
//
//  Created by Jahid Hassan on 7/7/15.
//  Copyright (c) 2015 Jahid Hassan. All rights reserved.
//

// Enable module feature if possible; Thanks to iRare Media for this suggestion
// Read more from the Modules documentation: http://clang.llvm.org/docs/Modules.html
#if __has_feature(objc_modules)
    @import UIKit;
    @import AVFoundation;
#else
    #import <UIKit/UIKit.h>
    #import <AVFoundation/AVFoundation.h>
#endif
#import "TriniScanProtocol.h"

//check different compatibility
#if !__has_feature(objc_arc)
    #error TriniScan is built with Objective-C ARC. You must enable ARC for these files.
#endif

#ifndef __IPHONE_7_0
    #error TriniScan is built with iOS SDK 8.0, but it also supports iOS SDK 7.0 and later.
#endif

NS_CLASS_AVAILABLE_IOS(7_0) @interface TDScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate> {IBOutlet UIButton* closeButton;}

// delegate reports scan data, errors, and requests information from the delegate.
@property (weak, nonatomic) id<TriniScanDelegate> delegate;

// animation during scanning; default is YES
@property (nonatomic) BOOL enableAnimation;

// control start/stop scanning menually; default is NO
@property (nonatomic) BOOL manualControl;

// adjust camera focusing automatically; default is YES
@property (nonatomic) BOOL enableAutoFocus;

// turn flash to help on focusing; default is NO
@property (nonatomic) BOOL enableFlash;

// starts the scan process. it has automatic invokation; however only call if you set 'manualControl' to YES
- (void)startScaning;

// stops the scan process;  it has automatic invokation; however only call if you set 'manualControl' to YES
- (void)stopScaning;

// close the scanner view controller; however if manualControl is set ot 'YES' then "stopScaning" should call before it
- (IBAction)close:(id)sender;

// set camera video to highest possible frame rate; auto focus will be set to NO
- (void)configureCameraForHighestFrameRate;

@end