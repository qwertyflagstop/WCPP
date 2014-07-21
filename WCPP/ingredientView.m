//
//  ingredientView.m
//  WCPP
//
//  Created by Nick Peretti on 5/21/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import "ingredientView.h"
#import "FlatUIKit.h"

#define kUP 20
@implementation ingredientView {
    Ingredient *ingreed;
}

- (id)initWithFrame:(CGRect)frame andIngredient:(Ingredient *)ingredient
{
    self = [super initWithFrame:frame];
    if (self) {
        ingreed = ingredient;
        switch (ingredient.weight) {
            case 1:
                self.backgroundColor = [UIColor colorWithRed:0.933 green:0.778 blue:0.238 alpha:1.000];
                break;
            case 2:
                self.backgroundColor = [UIColor colorWithRed:0.869 green:0.408 blue:0.170 alpha:1.000];
                break;
            case 3:
                self.backgroundColor = [UIColor colorWithRed:0.881 green:0.198 blue:0.201 alpha:1.000];
                break;
            case 4:
                self.backgroundColor = [UIColor colorWithRed:0.085 green:0.120 blue:0.155 alpha:1.000];
                break;
                
            default:
                
                break;
        }
        UILabel *chemicalNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
        chemicalNameLabel.font = [UIFont fontWithName:@"Futura" size:38.0];
        chemicalNameLabel.textAlignment = NSTextAlignmentCenter;
        chemicalNameLabel.textColor = [UIColor whiteColor];
        chemicalNameLabel.text = ingredient.names[0];
        chemicalNameLabel.backgroundColor = [UIColor colorWithWhite:0.495 alpha:0.270];
        [self addSubview:chemicalNameLabel];
        
        UILabel *hazard = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2.0-40, 145-kUP, 80, 40)];
        hazard.font = [UIFont fontWithName:@"Futura" size:18.0];
        hazard.textAlignment = NSTextAlignmentCenter;
        hazard.textColor = [UIColor whiteColor];
        hazard.text = @"Hazard";
        hazard.backgroundColor = [UIColor colorWithRed:0.985 green:0.317 blue:0.328 alpha:0.000];
        [self addSubview:hazard];
        
        UILabel *rating = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2.0-40, 264-kUP, 80, 40)];
        rating.font = [UIFont fontWithName:@"Futura" size:18.0];
        rating.textAlignment = NSTextAlignmentCenter;
        rating.textColor = [UIColor whiteColor];
        rating.text = @"Rating";
        rating.backgroundColor = [UIColor colorWithRed:0.985 green:0.317 blue:0.328 alpha:0.000];
        [self addSubview:rating];
        
        UILabel *weight = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2.0-75, 150-kUP, 150, 150)];
        weight.font = [UIFont fontWithName:@"Futura" size:110.0];
        weight.textAlignment = NSTextAlignmentCenter;
        weight.textColor = [UIColor whiteColor];
        weight.text = [NSString stringWithFormat:@"%i",ingredient.weight];
        weight.backgroundColor = [UIColor clearColor];
        weight.layer.cornerRadius = 18.0;
        weight.layer.borderColor = ([UIColor whiteColor].CGColor);
        weight.layer.borderWidth = 4.0;
        [self addSubview:weight];

        FUIButton *moreInfo = [[FUIButton alloc]initWithFrame:CGRectMake(frame.size.width/2.0-125, frame.size.height-40-40, 250, 70)];
        moreInfo.buttonColor = [UIColor colorWithRed:0.954 green:0.289 blue:0.263 alpha:1.000];
        moreInfo.shadowColor = [UIColor colorWithRed:0.832 green:0.251 blue:0.228 alpha:1.000];
        moreInfo.shadowHeight = 3.0f;
        moreInfo.cornerRadius = 8.0f;
        moreInfo.titleLabel.font = [UIFont fontWithName:@"Futura" size:32.0];
        [moreInfo setTitle:@"More Info" forState:UIControlStateNormal];
        [moreInfo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [moreInfo setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [moreInfo addTarget:self action:@selector(loadInfo) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreInfo];
        
    }
    return self;
}
-(void)loadInfo{
    NSURL *url = [NSURL URLWithString:ingreed.source];
    
    if (![[UIApplication sharedApplication] openURL:url]){
        FUIAlertView *alert = [[FUIAlertView alloc]initWithTitle:@"Ooops!" message:@"Could not load more info." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
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
    }
        
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
