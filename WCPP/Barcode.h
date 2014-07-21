//
//  Barcode.h
//  featurebuild
//
//  Created by Jake Widmer on 10/5/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface Barcode : NSObject

@property (nonatomic, strong) AVMetadataMachineReadableCodeObject *metadataObject;
@property (nonatomic, strong) NSString * barcodeType;
@property (nonatomic, strong) NSString * barcodeData;
@property (nonatomic, strong) UIBezierPath *cornersPath;
@property (nonatomic, strong) UIBezierPath *boundingBoxPath;
@property (nonatomic) CGRect box;

+ (Barcode * )processMetadataObject:(AVMetadataMachineReadableCodeObject*) code;
- (NSString *) getBarcodeType;
- (NSString *) getBarcodeData;
- (void) printBarcodeData;
@end
