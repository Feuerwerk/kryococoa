//
//  CollectionsEmptyMap.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsEmptyMap.h"
#import "CollectionsEmptyMapSerializer.h"
#import "CollectionsEmptyList.h"
#import "CollectionsEmptySet.h"

@implementation CollectionsEmptyMap

+ (instancetype)dictionary
{
	static CollectionsEmptyMap *singleton = nil;
	static dispatch_once_t once = 0;
	dispatch_once(&once, ^{ singleton = [CollectionsEmptyMap new]; });
	return singleton;
}

+ (NSString *)serializingAlias
{
	return @"java.util.Collections$EmptyMap";
}

+ (Class)defaultSerializer
{
	return [CollectionsEmptyMapSerializer class];
}

- (NSUInteger)count
{
	return 0;
}

- (id)objectForKey:(id)aKey
{
	return nil;
}

- (NSArray *)allKeys
{
	return [CollectionsEmptyList array];
}

- (NSArray *)allKeysForObject:(id)anObject
{
	return [CollectionsEmptyList array];
}

- (NSArray *)allValues
{
	return [CollectionsEmptyList array];
}

- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary
{
	return otherDictionary.count == 0;
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:keys.count];
	
	for (NSUInteger i = 0; i < keys.count; ++i)
	{
		[result addObject:marker];
	}
	
	return result;
}

- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator
{
	return [CollectionsEmptyList array];
}

- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys
{
}

- (id)objectForKeyedSubscript:(id)key
{
	return nil;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block
{
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block
{
}

- (NSArray *)keysSortedByValueUsingComparator:(NS_NOESCAPE NSComparator)cmptr
{
	return [CollectionsEmptyList array];
}

- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NS_NOESCAPE NSComparator)cmptr
{
	return [CollectionsEmptyList array];
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))predicate
{
	return [CollectionsEmptySet set];
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))predicate
{
	return [CollectionsEmptySet set];
}

@end
