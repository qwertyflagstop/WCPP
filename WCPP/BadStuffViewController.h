//
//  BadStuffViewController.h
//  WCPP
//
//  Created by Nick Peretti on 5/21/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ingredient.h"
#import "ingredientView.h"
@interface BadStuffViewController : UIViewController

@property (nonatomic) NSMutableArray *badIngredients;
-(void)layoutIngredients;

- (IBAction)dismissThisView:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *ingredientsScroll;

@end
