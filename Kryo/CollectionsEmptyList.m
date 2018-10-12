//
//  CollectionsEmptyList.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsEmptyList.h"
#import "CollectionsEmptyListSerializer.h"

@implementation CollectionsEmptyList

+ (instancetype)array
{
	static CollectionsEmptyList *singleton = nil;
	static dispatch_once_t once = 0;
	dispatch_once(&once, ^{ singleton = [CollectionsEmptyList new]; });
	return singleton;
}

+ (NSString *)serializingAlias
{
	return @"java.util.Collections$EmptyList";
}

+ (Class)defaultSerializer
{
	return [CollectionsEmptyListSerializer class];
}

- (NSUInteger)count
{
	return 0;
}

- (id)objectAtIndex:(NSUInteger)index
{
	[NSException raise:NSRangeException format:@"Parameter index not in range"];
	return nil;
}

- (BOOL)containsObject:(id)anObject
{
	return NO;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
	return 0;
}

- (void)getObjects:(id __unsafe_unretained [])objects range:(NSRange)range
{
	if (range.length == 0)
	{
		return;
	}
	
	[NSException raise:NSRangeException format:@"Parameter range not in range"];
}

- (NSUInteger)indexOfObject:(id)anObject
{
	return NSNotFound;
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range
{
	return NSNotFound;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject
{
	return NSNotFound;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range
{
	return NSNotFound;
}

- (BOOL)isEqualToArray:(NSArray *)otherArray
{
	return otherArray.count == 0;
}

- (id)firstObject
{
	return nil;
}

- (id)lastObject
{
	return nil;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
	[NSException raise:NSRangeException format:@"Parameter indexes not in range"];
	return nil;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
	[NSException raise:NSRangeException format:@"Parameter idx not in range"];
	return nil;
}

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block
{
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block
{
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block
{
}

- (NSUInteger)indexOfObjectPassingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	return NSNotFound;
}

- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	return NSNotFound;
}

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	return NSNotFound;
}

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	return [NSIndexSet indexSet];
}

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	return [NSIndexSet indexSet];
}

- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	return [NSIndexSet indexSet];
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(id, id, void *))comparator context:(void *)context
{
	return self;
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint
{
	return self;
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator
{
	return self;
}

- (NSArray *)subarrayWithRange:(NSRange)range
{
	if (range.length == 0)
	{
		return self;
	}
	
	[NSException raise:NSRangeException format:@"Parameter range not in range"];
	return nil;
}

- (void)makeObjectsPerformSelector:(SEL)aSelector
{
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument
{
}

@end
