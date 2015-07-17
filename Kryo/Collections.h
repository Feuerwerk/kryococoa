//
//  Collections.h
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Collections : NSObject

+ (NSArray *)emptyList;
+ (NSDictionary *)emptyMap;
+ (NSSet *)emptySet;

+ (NSArray *)singletonList:(id)anObject;
+ (NSDictionary *)singletonMap:(id<NSCopying>)key forValue:(id)value;
+ (NSSet *)singletonSet:(id)anObject;

@end
