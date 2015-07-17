//
//  CollectionsSingletonSet.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsSingletonSet.h"
#import "CollectionsSingletonSetSerializer.h"
#import "CollectionsSingletonList.h"
#import "CollectionsEmptySet.h"

@implementation CollectionsSingletonSet

+ (instancetype)setWithObject:(id)object
{
	CollectionsSingletonSet *aSet = [CollectionsSingletonSet new];
	aSet->_value = object;
	return aSet;
}

+ (NSString *)serializingAlias
{
	return @"java.util.Collections$SingletonSet";
}

+ (Class)defaultSerializer
{
	return [CollectionsSingletonSetSerializer class];
}

- (NSUInteger)count
{
	return 0;
}

- (NSArray *)allObjects
{
	return [CollectionsSingletonList arrayWithObject:_value];
}

- (id)anyObject
{
	return _value;
}

- (BOOL)containsObject:(id)anObject
{
	return [_value isEqual:anObject];
}

- (BOOL)intersectsSet:(NSSet *)otherSet
{
	for (id anObject in otherSet)
	{
		if ([_value isEqual:anObject])
		{
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)isEqualToSet:(NSSet *)otherSet
{
	if (otherSet.count == 1)
	{
		return [_value isEqual:otherSet.anyObject];
	}
	
	return NO;
}

- (BOOL)isSubsetOfSet:(NSSet *)otherSet
{
	return [otherSet containsObject:_value];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[_value performSelector:aSelector];
#pragma clang diagnostic pop
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[_value performSelector:aSelector withObject:argument];
#pragma clang diagnostic pop
}

- (NSSet *)setByAddingObject:(id)anObject
{
	return [NSSet setWithObjects:_value, anObject, nil];
}

- (NSSet *)setByAddingObjectsFromSet:(NSSet *)other
{
	if (other.count == 0)
	{
		return [NSSet setWithObject:_value];
	}
	
	NSMutableSet *aSet = [other mutableCopy];
	[aSet addObject:_value];
	return aSet;
}

- (NSSet *)setByAddingObjectsFromArray:(NSArray *)other
{
	NSMutableSet *aSet = [NSMutableSet setWithArray:other];
	[aSet addObject:_value];
	return aSet;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block
{
	BOOL stop = NO;
	block(_value, &stop);
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, BOOL *stop))block
{
	BOOL stop = NO;
	block(_value, &stop);
}

- (NSSet *)objectsPassingTest:(BOOL (^)(id obj, BOOL *stop))predicate
{
	BOOL stop = NO;
	
	if (predicate(_value, &stop))
	{
		return [NSSet setWithObject:_value];
	}
	
	return [CollectionsEmptySet set];
}

- (NSSet *)objectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, BOOL *stop))predicate
{
	BOOL stop = NO;
	
	if (predicate(_value, &stop))
	{
		return [NSSet setWithObject:_value];
	}
	
	return [CollectionsEmptySet set];
}

@end