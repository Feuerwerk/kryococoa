//
//  CollectionsSingletonList.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsSingletonList.h"
#import "CollectionsSingletonListSerializer.h"
#import "CollectionsEmptyList.h"

@implementation CollectionsSingletonList

+ (instancetype)arrayWithObject:(id)anObject
{
	CollectionsSingletonList *aList = [CollectionsSingletonList new];
	aList->_value = anObject;
	return aList;
}

+ (NSString *)serializingAlias
{
	return @"java.util.Collections$SingletonList";
}

+ (Class)defaultSerializer
{
	return [CollectionsSingletonListSerializer class];
}

- (NSUInteger)count
{
	return 1;
}

- (id)objectAtIndex:(NSUInteger)index
{
	if (index != 0)
	{
		[NSException raise:NSRangeException format:@"Parameter index not in range"];
	}
	
	return _value;
}

- (BOOL)containsObject:(id)anObject
{
	return [_value isEqual:anObject];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
	if (state->state == 1)
	{
		return 0;
	}

	state->state = 1;
	state->itemsPtr = buffer;
	state->mutationsPtr = &state->extra[0];
	
	if (len == 0)
	{
		return 0;
	}
	
	buffer[0] = _value;
	
	return 1;
}

- (void)getObjects:(id __unsafe_unretained [])objects range:(NSRange)range
{
	if ((range.location != 0) || (range.length != 1))
	{
		[NSException raise:NSRangeException format:@"Parameter range not in range"];
	}
	
	objects[0] = _value;
}

- (NSUInteger)indexOfObject:(id)anObject
{
	return [_value isEqual:anObject] ? 0 : NSNotFound;
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range
{
	if ((range.location != 0) || (range.length != 1))
	{
		[NSException raise:NSRangeException format:@"Parameter range not in range"];
	}
	
	return [_value isEqual:anObject] ? 0 : NSNotFound;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject
{
	return (_value == anObject) ? 0 : NSNotFound;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range
{
	if ((range.location != 0) || (range.length != 1))
	{
		[NSException raise:NSRangeException format:@"Parameter range not in range"];
	}
	
	return (_value == anObject) ? 0 : NSNotFound;
}

- (BOOL)isEqualToArray:(NSArray *)otherArray
{
	if (otherArray.count != 1)
	{
		return NO;
	}
	
	return [_value isEqual:otherArray.firstObject];
}

- (id)firstObject
{
	return _value;
}

- (id)lastObject
{
	return _value;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:indexes.count];
	
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		if (idx != 0)
		{
			[NSException raise:NSRangeException format:@"Parameter indexes not in range"];
		}
		
		[result addObject:self->_value];
	}];
	
	return result;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
	if (idx != 0)
	{
		[NSException raise:NSRangeException format:@"Parameter idx not in range"];
	}
	
	return _value;
}

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block
{
	BOOL stop = NO;
	block(_value, 0, &stop);
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block
{
	BOOL stop = NO;
	block(_value, 0, &stop);
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block
{
	[indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		if (idx != 0)
		{
			[NSException raise:NSRangeException format:@"Parameter indexSet not in range"];
		}
		
		block(self->_value, 0, stop);
	}];
}

- (NSUInteger)indexOfObjectPassingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	BOOL stop = NO;
	return predicate(_value, 0, &stop) ? 0 : NSNotFound;
}

- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	BOOL stop = NO;
	return predicate(_value, 0, &stop) ? 0 : NSNotFound;
}

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	__block NSUInteger result = NSNotFound;
	
	[indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		if (idx != 0)
		{
			[NSException raise:NSRangeException format:@"Parameter indexSet not in range"];
		}
		
		if (predicate(self->_value, 0, stop))
		{
			result = 0;
			*stop = YES;
		}
	}];
	
	return result;
}

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	BOOL stop = NO;
	
	if (predicate(_value, 0, &stop))
	{
		return [NSIndexSet indexSetWithIndex:0];
	}
	
	return [NSIndexSet indexSet];
}

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	BOOL stop = NO;
	
	if (predicate(_value, 0, &stop))
	{
		return [NSIndexSet indexSetWithIndex:0];
	}
	
	return [NSIndexSet indexSet];
}

- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
	NSMutableIndexSet *result = [NSMutableIndexSet indexSet];
	
	[indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		if (idx != 0)
		{
			[NSException raise:NSRangeException format:@"Parameter indexSet not in range"];
		}
		
		if (predicate(self->_value, 0, stop))
		{
			[result addIndex:0];
		}
	}];
	
	return result;
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
		return [CollectionsEmptyList array];
	}
	
	if ((range.location != 0) || (range.length != 1))
	{
		[NSException raise:NSRangeException format:@"Parameter range not in range"];
	}
	
	return self;
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

@end
