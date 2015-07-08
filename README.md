<p align="center" >
  <img src="https://avatars0.githubusercontent.com/u/4034940?v=3&u=a28131520ea991ad3e961c727329dd73cbb29bb9&s=140" alt="TriniScan for iOS" title="TriniScan for iOS">
</p>

`TriniScan` for iOS is a easy and powerful tool to enable barcode scanning feature to your iOS application. It scans popular barcodes, in real-time, very efficiently using device's buildin camera. It is fast, most acurate and customizable. It has implemented user interface, therefore inntergration is so quick.

Please [star it](https://github.com/mjhassan/TriniScan) on GitHub! If you found any bug or want to extend/modify some of it's feature then drop me a line @[my email](mailto:jahid_sust@hotmail.com). If you found it useful or already used in your app please let us know on Twitter @posaidon ( :) 'e' wasn't available, hence 'a' ). Enjoy.

## <a name="0100"></a> Integration
###Requirements:
    iOS: 7.0 or later
    ARC: YES
    Framework:  - AVFoundation
            	- CoreGraphics
	            - QuartzCore
### <a name="0101"></a> Cocoapods
Not available right now. I'll try to add a `podspec` ASAP.
### <a name="0102"></a> Manual
- Copy the `TriniScanAPI` directory to your project.
- import `TDScannerViewController.h` file.
- implement it as:
   
 ```objective-c
    TDScannerViewController* scanner = [[TDScannerViewController alloc] init];
    scanner.modalPresentationStyle   = UIModalPresentationFullScreen;
    scanner.modalTransitionStyle     = UIModalTransitionStyleCoverVertical;
    scanner.delegate                 = self;
    [self presentViewController:scanner animated:YES completion:nil];
```
- implemente delegate methods to get the data. 
         
##Supported Format:
    UPC-E
    EAN-8 and EAN-13
    Code 39
    Code 39 Mod 43
    Code 93
    Code 128
    QR Code
    PDF 417
