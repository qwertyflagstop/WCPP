//
//  BadStuffViewController.m
//  WCPP
//
//  Created by Nick Peretti on 5/21/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import "BadStuffViewController.h"

@interface BadStuffViewController ()

@end


@implementation BadStuffViewController
@synthesize badIngredients,ingredientsScroll;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


-(void)layoutIngredients{
    int i =0;
    [ingredientsScroll setContentSize:CGSizeMake(badIngredients.count*320, ingredientsScroll.frame.size.height)];
    for (Ingredient *ing in badIngredients) {
        ingredientView *inView = [[ingredientView alloc]initWithFrame:CGRectMake(i*320+5, 5, self.ingredientsScroll.frame.size.width-10, self.ingredientsScroll.frame.size.height-10) andIngredient:ing];
        [self.ingredientsScroll addSubview:inView];
        i++;
    }
}


- (IBAction)dismissThisView:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"doneWithView" object:nil];
}
@end
