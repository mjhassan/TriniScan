//
//  ViewController.m
//  TriniScan
//
//  Created by Jahid Hassan on 7/7/15.
//  Copyright (c) 2015 Jahid Hassan. All rights reserved.
//

#import "ViewController.h"
#import "TDScannerViewController.h"

@interface ViewController () <TDScannerViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)ShowScanner:(id)sender {
    TDScannerViewController* scan = [[TDScannerViewController alloc] initWithNibName:@"TDScannerViewController~iPad" bundle:nil];
    scan.modalPresentationStyle   = UIModalPresentationFullScreen;
    scan.modalTransitionStyle     = UIModalTransitionStyleCoverVertical;
    [self presentViewController:scan animated:YES completion:nil];
    
    scan.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
- (void)scanDidSucceededWithResult:(NSString *)stringResult {
    /*
    NSArray* infoArray = nil;
    if([stringResult containsString:@"\n"])
        infoArray = [stringResult componentsSeparatedByString:@"\n"];
    else
        infoArray = [stringResult componentsSeparatedByString:@" "];
    
    NSMutableDictionary *contact = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < infoArray.count; i++) {
        if ( [[infoArray objectAtIndex:i] length] > 3 ) {
            NSString *key   = [[infoArray objectAtIndex:i] substringToIndex:3];
            NSString *value = [[infoArray objectAtIndex:i] substringFromIndex:3];

            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ( value.length != 0 ) {
                if ( [[value substringFromIndex:value.length-1] isEqualToString:@","] )
                    value = [value substringToIndex:value.length-1];
                value = [value stringByReplacingOccurrencesOfString:@"," withString:@" "];
            }
            
            NSString *columnName = nil;
            if ( [key isEqualToString:@"DBA"] ) {
                columnName = @"ExpiryDate";
                if ( value.length == 8 )
                    value = [NSString stringWithFormat:@"%@-%@-%@", [value substringToIndex:4],
                                [value substringWithRange:NSMakeRange(4, 2)],
                                [value substringFromIndex:6]];
            }
            else if ( [key isEqualToString:@"DCS"] ) columnName = @"LastName";
            else if ( [key isEqualToString:@"DCT"] ) columnName = @"FirstName";
            else if ( [key isEqualToString:@"DBB"] ) {
                columnName = @"BirthDate";
                if ( value.length == 8 )
                    value = [NSString stringWithFormat:@"%@-%@-%@", [value substringToIndex:4],
                                [value substringWithRange:NSMakeRange(4, 2)],
                                [value substringFromIndex:6]];
            }
            else if ( [key isEqualToString:@"DAG"] ) columnName = @"Street";
            else if ( [key isEqualToString:@"DAI"] ) columnName = @"City";
            else if ( [key isEqualToString:@"DAJ"] ) columnName = @"State";
            else if ( [key isEqualToString:@"DCG"] ) {
                columnName = @"Country";
                if ( [value isEqualToString:@"CAN"] ) value = @"CA";
            }
            else if ( [key isEqualToString:@"DAK"] ) columnName = @"Zip";
            else if ( [key isEqualToString:@"DAQ"] ) columnName = @"ReferenceNumber";
            if ( columnName ) [contact setValue:value forKey:columnName];
        }
    }
    [contact setValue:@"DL" forKey:@"DocumentType"];
    [contact setValue:[contact objectForKey:@"State"] forKey:@"PlaceOfIssue"];
    [contact setValue:[NSString stringWithFormat:@"%@ %@", [contact objectForKey:@"FirstName"], [contact objectForKey:@"LastName"]] forKey:@"NameOnAgreement"];
    
    infoArray = nil;
    */
//    NSLog(@"%@", contact);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Got Information" message:stringResult delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
