//
//  CollectionsEmptySet.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsEmptySet.h"
#import "CollectionsEmptySetSerializer.h"
#import "CollectionsEmptyList.h"

@implementation CollectionsEmptySet

+ (instancetype)set
{
	static CollectionsEmptySet *singleton = nil;
	static dispatch_once_t once = 0;
	dispatch_once(&once, ^{ singleton = [CollectionsEmptySet new]; });
	return singleton;
}

+ (NSString *)serializingAlias
{
	return @"java.util.Collections$EmptySet";
}

+ (Class)defaultSerializer
{
	return [CollectionsEmptySetSerializer class];
}

- (NSUInteger)count
{
	return 0;
}

- (NSArray *)allObjects
{
	return [CollectionsEmptyList array];
}

- (id)anyObject
{
	return nil;
}

- (BOOL)containsObject:(id)anObject
{
	return NO;
}

- (BOOL)intersectsSet:(NSSet *)otherSet
{
	return NO;
}

- (BOOL)isEqualToSet:(NSSet *)otherSet
{
	return otherSet.count == 0;
}

- (BOOL)isSubsetOfSet:(NSSet *)otherSet
{
	return YES;
}

- (void)makeObjectsPerformSelector:(SEL)aSelector
{
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument
{
}

- (NSSet *)setByAddingObject:(id)anObject
{
	return [NSSet setWithObject:anObject];
}

- (NSSet *)setByAddingObjectsFromSet:(NSSet *)other
{
	return [other copy];
}

- (NSSet *)setByAddingObjectsFromArray:(NSArray *)other
{
	return [NSSet setWithArray:other];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block
{
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, BOOL *stop))block
{
}

- (NSSet *)objectsPassingTest:(BOOL (^)(id obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0)
{
	return self;
}

- (NSSet *)objectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, BOOL *stop))predicate
{
	return self;
}

@end