//
//  Collections.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "Collections.h"
#import "CollectionsEmptyList.h"
#import "CollectionsEmptyMap.h"
#import "CollectionsEmptySet.h"
#import "CollectionsSingletonMap.h"
#import "CollectionsSingletonList.h"
#import "CollectionsSingletonSet.h"

@implementation Collections

+ (NSArray *)emptyList
{
	return [CollectionsEmptyList array];
}

+ (NSDictionary *)emptyMap
{
	return [CollectionsEmptyMap dictionary];
}

+ (NSSet *)emptySet
{
	return [CollectionsEmptySet set];
}

+ (NSArray *)singletonList:(id)anObject
{
	return [CollectionsSingletonList arrayWithObject:anObject];
}

+ (NSDictionary *)singletonMap:(id<NSCopying>)key forValue:(id)value
{
	return [CollectionsSingletonMap dictionaryWithObject:value forKey:key];
}

+ (NSSet *)singletonSet:(id)anObject
{
	return [CollectionsSingletonSet setWithObject:anObject];
}

@end
