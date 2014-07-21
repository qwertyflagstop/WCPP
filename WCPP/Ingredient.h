//
//  Ingredient.h
//  WCPP
//
//  Created by Nick Peretti on 5/18/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ingredient : NSObject

@property (nonatomic) NSArray *names;
@property (nonatomic) int weight;
@property (nonatomic) NSString *source;

-(id)initWithNames:(NSMutableArray *)ingredientNames weight:(int)waght source:(NSString *)sourceUrl;


@end
