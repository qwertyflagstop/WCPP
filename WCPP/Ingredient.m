//
//  Ingredient.m
//  WCPP
//
//  Created by Nick Peretti on 5/18/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import "Ingredient.h"

@implementation Ingredient

@synthesize weight,names,source;

-(id)initWithNames:(NSMutableArray *)ingredientNames weight:(int)waght source:(NSString *)sourceUrl{
    self = [super init];
    if (self) {
        weight = waght;
        names = [ingredientNames copy] ;
        source = sourceUrl;
     
    }
    return self;
    
}


@end
