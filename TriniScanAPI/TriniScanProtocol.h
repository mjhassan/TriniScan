//
//  TriniScanDelegate.h
//  TriniScan-Example
//
//  Created by Jahid Hassan on 7/8/15.
//  Copyright (c) 2015 Jahid Hassan. All rights reserved.
//

#ifndef TriniScan_Example_TriniScanDelegate_h
#define TriniScan_Example_TriniScanDelegate_h

@protocol TriniScanDelegate<NSObject>
@required
- (void)scanDidSucceededWithResult:(NSString *)stringResult;
@optional
- (void)scanFailedWithError:(NSError*)error;
@end

#endif
