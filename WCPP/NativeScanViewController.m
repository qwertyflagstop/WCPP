//
//  NativeScanViewController.m
//  WCPP
//
//  Created by Nick Peretti on 5/6/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import "NativeScanViewController.h"
#import "Barcode.h"
@interface NativeScanViewController () <AVCaptureMetadataOutputObjectsDelegate,FactualAPIDelegate,UIAlertViewDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    MBProgressHUD *mbProgress;

    
    NSMutableArray *ingredients;
    
    UIImageView *barcodeTemplate;
    
    NSString *currentBarcode;
    FactualAPI *apiObject;

    BOOL scanning;
    BadStuffViewController *time;
    CGRect originalFrame;
}



@end

@implementation NativeScanViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentBarcode = @"";
    scanning = YES;
    
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor colorWithRed:0.936 green:0.699 blue:0.417 alpha:1.000]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doneWithChemicals) name:@"doneWithView" object:nil];
    
    
    NSDictionary *configureSetting =  [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIColor whiteColor], UITextAttributeTextColor,
                                       [UIFont fontWithName:@"Futura" size:22.0], UITextAttributeFont,nil];
    [self.navigationController.navigationBar setTitleTextAttributes:configureSetting];
    
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor colorWithRed:0.908 green:0.497 blue:0.196 alpha:1.000] highlightedColor:[UIColor colorWithRed:0.480 green:0.406 blue:1.000 alpha:1.000] cornerRadius:3.0];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor whiteColor], UITextAttributeTextColor,
                                                                   [UIFont fontWithName:@"Futura" size:16.0], UITextAttributeFont,nil] forState:UIControlStateNormal];
    
    [self.navigationItem.rightBarButtonItem configureFlatButtonWithColor:[UIColor colorWithRed:0.908 green:0.497 blue:0.196 alpha:1.000] highlightedColor:[UIColor colorWithRed:0.480 green:0.406 blue:1.000 alpha:1.000] cornerRadius:3.0];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIColor whiteColor], UITextAttributeTextColor,
                                                                    [UIFont fontWithName:@"Futura" size:16.0], UITextAttributeFont,nil] forState:UIControlStateNormal];
    
    
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    apiObject = [[FactualAPI alloc]initWithAPIKey:@"WlZN9QGlqTUz7vhjZlziU2JtPZ9Gha4mYdYpLRqF" secret:@"a0kApLAcVb3TGkjr0EpSC9fIhs56NQxq8CTs1KMW"];
    
    ingredients = [[NSMutableArray alloc]init];
    NSString *filurl = [[NSBundle mainBundle]pathForResource:@"data" ofType:@"json"];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filurl] options:kNilOptions error:nil];
    
    for (NSDictionary *dict in jsonArray) {
        NSMutableArray *names = [[NSMutableArray alloc]init];
        [names addObject:[dict objectForKey:@"Ingredient Name"]];
        [names addObject:[dict objectForKey:@"Alt Name 1"]];
        [names addObject:[dict objectForKey:@"Alt Name 2"]];
        [names addObject:[dict objectForKey:@"Alt Name 3"]];
        NSMutableArray *goodNames = [[NSMutableArray alloc]init];
        for (NSString *name in names) {
            if (![name isEqualToString:@""]) {
                [goodNames addObject:[name lowercaseString]];
            }
        }
        int wate = [(NSString *)[dict objectForKey:@"Weight"] intValue];
        NSString *src = [dict objectForKey:@"Source"];
        Ingredient *greedy = [[Ingredient alloc]initWithNames:goodNames weight:wate source:src];
        [ingredients addObject:greedy];
    }
    
    
     
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    if ([_device respondsToSelector:@selector(isAutoFocusRangeRestrictionSupported)] && _device.autoFocusRangeRestrictionSupported) {
        if ([_device lockForConfiguration:nil]) {
            _device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
            [_device unlockForConfiguration];
        }
    }
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    

    UIImage *overlay = [UIImage imageNamed:@"overlay.png"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:overlay];
    [imageView setFrame:CGRectMake(0, self.view.frame.size.height/3.0, 320, 200)];
    [self.view addSubview:imageView];
    barcodeTemplate = imageView;
    
    mbProgress = [[MBProgressHUD alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2.0-16, self.view.frame.size.height/2.0-16, 38, 38)];
    originalFrame = barcodeTemplate.frame;
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (scanning) {
        
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                Barcode *b = [Barcode processMetadataObject:barCodeObject];
                [UIView animateWithDuration:0.2 animations:^{
                    barcodeTemplate.frame = CGRectMake((barcodeTemplate.frame.origin.x+b.box.origin.x)/2.0, (barcodeTemplate.frame.origin.y+b.box.origin.y)/2.0, (barcodeTemplate.frame.size.width+b.box.size.width)/2.0, (barcodeTemplate.frame.size.height+b.box.size.height)/2.0);
                }];
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            if (detectionString!=currentBarcode) {
                scanning = NO;
                currentBarcode = detectionString;
                
                [self requestIngredients];
              
            }
            break;
        }
        
         
    }
    
    }
}
-(void)requestIngredients{
    mbProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [mbProgress setTaskInProgress:YES];
    [mbProgress setLabelText:@"Fetching Ingredients"];
    [mbProgress setLabelFont:[UIFont fontWithName:@"Futura" size:12.0]];
    FactualQuery *query = [FactualQuery query];
    [query addFullTextQueryTerm:currentBarcode];
    [apiObject queryTable:@"products-cpg-nutrition" optionalQueryParams:query withDelegate:self];
    
   
}

-(void)requestComplete:(FactualAPIRequest *)request failedWithError:(NSError *)error{
    if (error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        FUIAlertView *alert = [[FUIAlertView alloc]initWithTitle:@"Ooops!" message:@"An error occured while fetching the ingredients. Are you connected to the internet?" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert setAlertViewStyle:FUIAlertViewStyleDefault];
        alert.titleLabel.textColor = [UIColor whiteColor];
        alert.titleLabel.font = [UIFont fontWithName:@"Futura" size:18.0];
        alert.alertContainer.layer.cornerRadius = 17.0;
        alert.messageLabel.textColor = [UIColor whiteColor];
        alert.messageLabel.font = [UIFont fontWithName:@"Futura" size:14.0];
        alert.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        alert.alertContainer.backgroundColor = [UIColor colorWithRed:0.908 green:0.497 blue:0.196 alpha:1.000];
        alert.defaultButtonColor = [UIColor colorWithRed:0.954 green:0.289 blue:0.263 alpha:1.000];
        alert.defaultButtonShadowColor = [UIColor colorWithRed:0.716 green:0.216 blue:0.196 alpha:1.000];
        alert.defaultButtonFont = [UIFont fontWithName:@"Futura" size:16.0];
        alert.defaultButtonTitleColor = [UIColor whiteColor];
        alert.defaultButtonCornerRadius = 14.0;
        [alert setOnDismissAction:^{
            [UIView animateWithDuration:0.2 animations:^{
                barcodeTemplate.frame = originalFrame;
            }];
            currentBarcode = @"0";
            scanning = YES;
        }];
        [alert show];
        
    } else {
   
    }
}
-(void)requestComplete:(FactualAPIRequest *)request receivedMatchResult:(NSString *)factualId{
    //NSLog(@"2");
}
-(void)requestComplete:(FactualAPIRequest *)request receivedQueryResult:(FactualQueryResult *)queryResult{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    FactualRow *row = queryResult.rows[0];
    NSArray *rawIngredients = [row.namesAndValues objectForKey:@"ingredients"];
    NSString *productName = [row.namesAndValues objectForKey:@"product_name"];
    //NSLog(@"%@",productName);
    if (rawIngredients.count==0) {
        FUIAlertView *alert = [[FUIAlertView alloc]initWithTitle:@"Darn" message:@"We could not find the ingredients for this product" delegate:nil cancelButtonTitle:@"OK ):" otherButtonTitles:nil];
        [alert setAlertViewStyle:FUIAlertViewStyleDefault];
        alert.titleLabel.textColor = [UIColor whiteColor];
        alert.titleLabel.font = [UIFont fontWithName:@"Futura" size:18.0];
        alert.alertContainer.layer.cornerRadius = 17.0;
        alert.messageLabel.textColor = [UIColor whiteColor];
        alert.messageLabel.font = [UIFont fontWithName:@"Futura" size:14.0];
        alert.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        alert.alertContainer.backgroundColor = [UIColor colorWithRed:0.908 green:0.497 blue:0.196 alpha:1.000];
        alert.defaultButtonColor = [UIColor colorWithRed:0.954 green:0.289 blue:0.263 alpha:1.000];
        alert.defaultButtonShadowColor = [UIColor colorWithRed:0.716 green:0.216 blue:0.196 alpha:1.000];
        alert.defaultButtonFont = [UIFont fontWithName:@"Futura" size:16.0];
        alert.defaultButtonTitleColor = [UIColor whiteColor];
        alert.defaultButtonCornerRadius = 14.0;
        [alert setOnDismissAction:^{
            [UIView animateWithDuration:0.2 animations:^{
                barcodeTemplate.frame = originalFrame;
            }];
            currentBarcode = @"0";
            scanning = YES;
        }];
        [alert show];

    } else {
    
    NSMutableArray *productIngredients = [[NSMutableArray alloc]init];
    
    
    for (int i = 0;i<rawIngredients.count;i++){
        NSString *curentingredient = rawIngredients[i];
        curentingredient = [curentingredient lowercaseString];
        [productIngredients addObject:curentingredient];
    }
    
    NSMutableArray *badIngredientszz = [[NSMutableArray alloc]init];
    for (NSString *currentIngredient in productIngredients) {
        for (Ingredient *ing in ingredients) {
            for (NSString *name in ing.names) {
                if ([name isEqualToString:currentIngredient]) {
                    [badIngredientszz addObject:ing];
                }
            }
        }
    }
    if (badIngredientszz.count>0) {
        time = [self.storyboard instantiateViewControllerWithIdentifier:@"gg"];;
        [self presentViewController:time animated:YES completion:^{
            time.badIngredients = badIngredientszz;
           [time layoutIngredients];
       }];
    }else{
        FUIAlertView *alert = [[FUIAlertView alloc]initWithTitle:@"All Clear" message:[NSString stringWithFormat:@"All clear, %@ contains no harmful ingredients",productName] delegate:nil cancelButtonTitle:@"Great" otherButtonTitles:nil];
        [alert setAlertViewStyle:FUIAlertViewStyleDefault];
        alert.titleLabel.textColor = [UIColor whiteColor];
        alert.titleLabel.font = [UIFont fontWithName:@"Futura" size:18.0];
        alert.alertContainer.layer.cornerRadius = 17.0;
        alert.messageLabel.textColor = [UIColor whiteColor];
        alert.messageLabel.font = [UIFont fontWithName:@"Futura" size:14.0];
        alert.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        alert.alertContainer.backgroundColor = [UIColor colorWithRed:0.160 green:0.773 blue:0.411 alpha:1.000];
        alert.defaultButtonColor = [UIColor colorWithRed:0.132 green:0.635 blue:0.337 alpha:1.000];
        alert.defaultButtonShadowColor = [UIColor colorWithRed:0.105 green:0.510 blue:0.271 alpha:1.000];
        alert.defaultButtonFont = [UIFont fontWithName:@"Futura" size:16.0];
        alert.defaultButtonTitleColor = [UIColor whiteColor];
        alert.defaultButtonCornerRadius = 14.0;
        [alert setOnDismissAction:^{
            [UIView animateWithDuration:0.2 animations:^{
                barcodeTemplate.frame = originalFrame;
            }];
            currentBarcode = @"0";
            scanning = YES;
        }];
        [alert show];
    }
    }
}
-(void)requestComplete:(FactualAPIRequest *)request receivedRawResult:(NSDictionary *)result{
   
}
-(void)requestDidReceiveData:(FactualAPIRequest *)request{
    NSLog(@"5");
}
-(void)requestDidReceiveInitialResponse:(FactualAPIRequest *)request{
    NSLog(@"6");
}

-(void)viewDidAppear:(BOOL)animated{
    scanning = YES;
}
-(void)doneWithChemicals{
    [time dismissViewControllerAnimated:YES
                            completion:^{
                                [UIView animateWithDuration:0.2 animations:^{
                                    barcodeTemplate.frame = originalFrame;
                                }];
                                scanning = YES;
                            }];
}
@end