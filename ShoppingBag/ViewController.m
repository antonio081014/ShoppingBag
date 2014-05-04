//
//  ViewController.m
//  ShoppingBag
//
//  Created by Antonio081014 on 5/2/14.
//  Copyright (c) 2014 Antonio081014.com. All rights reserved.
//

#import "ViewController.h"
@import AVFoundation;

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *photoModeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *brandSegmentedControl;

@property (weak, nonatomic) IBOutlet UILabel *productOriginalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *productMarkedDownPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *productColor;
@property (weak, nonatomic) IBOutlet UILabel *productStyleNo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *recognizationInProgress;

@property (nonatomic) NSInteger brand;
@property (nonatomic) NSInteger photoMode;

@property (nonatomic) CGFloat productDiscount;
@property (weak, nonatomic) IBOutlet UILabel *productDiscountLabel;

@property (nonatomic) CGFloat originalPrice;
@property (nonatomic) CGFloat markedDownPrice;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialize];
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
//    tesseract.progress;
    return NO;
}

const static int PHOTO_MODE_SNAP = 0;
const static int PHOTO_MODE_SCAN = 1;
- (IBAction)choosePhotoMode:(UISegmentedControl *)sender
{
    self.photoMode = sender.selectedSegmentIndex;
}

const static int BRAND_COACH = 0;
const static int BRAND_COACH_SERIAL_LENGTH = 5;
const static int BRAND_MICHAELKORS = 1;
const static int BRAND_MICHAELKORS_SERIAL_LENGTH = 7;
- (IBAction)chooseBrand:(UISegmentedControl *)sender
{
    self.brand = sender.selectedSegmentIndex;
}

- (IBAction)takeThePhoto:(UITapGestureRecognizer *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)changePhotoMode:(UISwipeGestureRecognizer *)sender
{
    NSLog(@"Swiped");
}

- (IBAction)discountChanged:(UISlider *)sender
{
    CGFloat newStep = roundf((sender.value) / 1.f);
    
    sender.value = newStep;
    self.productDiscount = 5.f * newStep;
    
    self.productDiscountLabel.text = [NSString stringWithFormat:@"%.0f %% OFF", self.productDiscount];
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    switch (self.photoMode) {
        case PHOTO_MODE_SCAN:
            [self processText:[self recognizeImage:chosenImage]];
            break;
        case PHOTO_MODE_SNAP:
            if (chosenImage) {
                self.productImage.image = chosenImage;
            }
            break;
        default:
            break;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];

}

#pragma mark - OCR, from Image to Text.
- (NSString *)recognizeImage:(UIImage *)image
{
    if (!image) return @"";
    [self.recognizationInProgress startAnimating];
    // language are used for recognition. Ex: eng. Tesseract will search for a eng.traineddata file in the dataPath directory; eng+ita will search for a eng.traineddata and ita.traineddata.
    
    // Like in the Template Framework Project:
    // Assumed that .traineddata files are in your "tessdata" folder and the folder is in the root of the project.
    // Assumed, that you added a folder references "tessdata" into your xCode project tree, with the ‘Create folder references for any added folders’ options set up in the «Add files to project» dialog.
    // Assumed that any .traineddata files is in the tessdata folder, like in the Template Framework Project
    
    //Create your tesseract using the initWithLanguage method:
    // Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita"];
    
    // set up the delegate to recieve tesseract's callback
    // self should respond to TesseractDelegate and implement shouldCancelImageRecognitionForTesseract: method
    // to have an ability to recieve callback and interrupt Tesseract before it finishes
    
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;
    
    [tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.$" forKey:@"tessedit_char_whitelist"]; //limit search
    [tesseract setImage:image]; //image to check
    [tesseract recognize];
    
    [self.recognizationInProgress stopAnimating];
    NSString *ret = [tesseract recognizedText];
    tesseract = nil; //deallocate and free all memory
    return ret;
}

- (void)processText:(NSString *)text
{
    NSLog(@"Process the text received from image");
    if (!text || !text.length) return;
}

- (void)initialize
{
    switch (self.brandSegmentedControl.selectedSegmentIndex) {
        case BRAND_COACH:
            self.brand = BRAND_COACH;
            break;
        case BRAND_MICHAELKORS:
            self.brand = BRAND_MICHAELKORS;
        default:
            break;
    }
    
    switch (self.photoModeSegmentedControl.selectedSegmentIndex) {
        case PHOTO_MODE_SNAP:
            self.photoMode = PHOTO_MODE_SNAP;
            break;
        case PHOTO_MODE_SCAN:
            self.photoMode = PHOTO_MODE_SCAN;
        default:
            break;
    }
    
    self.originalPrice = -1.f;
    self.markedDownPrice = -1.f;
    self.productDiscount = 0.f;
    
    self.productOriginalPriceLabel.text = @"原价";
    self.productMarkedDownPriceLabel.text = @"现价";
    self.productStyleNo.text = @"Style No.";
    self.productColor.text = @"Color";
    self.productDiscountLabel.text = @"折扣";
    self.subtotalLabel.text = @"包邮稅价格";
    
    self.productImage.image = nil;
    
    [self.recognizationInProgress stopAnimating];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}
@end
