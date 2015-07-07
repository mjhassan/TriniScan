//
//  TDScannerViewController.h
//  TriniScan
//
//  Created by Jahid Hassan on 7/7/15.
//  Copyright (c) 2015 Jahid Hassan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol TDScannerViewControllerDelegate;
@interface TDScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate> {
    IBOutlet UIButton* closeButton;
}
@property (weak, nonatomic) id<TDScannerViewControllerDelegate> delegate;

- (IBAction)close:(id)sender;
@end

@protocol TDScannerViewControllerDelegate <NSObject>

- (void)scanDidSucceededWithResult:(NSString *)stringResult;

@optional
- (void)scanFailedWithError:(NSError*)error;

@end