//
//  CollectionsSingletonMap.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsSingletonMap.h"
#import "CollectionsSingletonMapSerializer.h"
#import "CollectionsEmptyList.h"
#import "CollectionsEmptySet.h"
#import "CollectionsSingletonList.h"
#import "CollectionsSingletonSet.h"

@implementation CollectionsSingletonMap

+ (instancetype)dictionaryWithObject:(id)object forKey:(id <NSCopying>)key
{
	CollectionsSingletonMap *aMap = [CollectionsSingletonMap new];
	aMap->_key = key;
	aMap->_value = object;
	return aMap;
}

+ (NSString *)serializingAlias
{
	return @"java.util.Collections$SingletonMap";
}

+ (Class)defaultSerializer
{
	return [CollectionsSingletonMapSerializer class];
}

- (NSUInteger)count
{
	return 1;
}

- (id)key
{
	return _key;
}

- (id)value
{
	return _value;
}

- (id)objectForKey:(id)aKey
{
	return [aKey isEqual:_key] ? _value : nil;
}

- (NSArray *)allKeys
{
	return [CollectionsSingletonList arrayWithObject:_key];
}

- (NSArray *)allKeysForObject:(id)anObject
{
	return [_value isEqual:anObject] ? [CollectionsSingletonList arrayWithObject:_key] : [CollectionsEmptyList array];
}

- (NSArray *)allValues
{
	return [CollectionsSingletonList arrayWithObject:_value];
}

- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary
{
	if (otherDictionary.count < 1)
	{
		return NO;
	}
	
	__block BOOL result = YES;
	
	[otherDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (![key isEqual:_key] || ![obj isEqual:_value])
		{
			result = NO;
			*stop = YES;
		}
	}];
	
	return result;
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:keys.count];
	
	for (id key in keys)
	{
		[result addObject:[key isEqual:_key] ? _value : marker];
	}
	
	return result;
}

- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator
{
	return [CollectionsSingletonList arrayWithObject:_key];
}

- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys
{
	keys[0] = _key;
	objects[0] = _value;
}

- (id)objectForKeyedSubscript:(id)key
{
	return [key isEqual:_key] ? _value : nil;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
	BOOL stop = NO;
	block(_key, _value, &stop);
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
	BOOL stop = NO;
	block(_key, _value, &stop);
}

- (NSArray *)keysSortedByValueUsingComparator:(NSComparator)cmptr
{
	return [CollectionsEmptyList array];
}

- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr
{
	return [CollectionsSingletonList arrayWithObject:_key];
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate
{
	BOOL stop = NO;
	return predicate(_key, _value, &stop) ? [CollectionsSingletonSet setWithObject:_key] : [CollectionsEmptySet set];
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate
{
	BOOL stop = NO;
	return predicate(_key, _value, &stop) ? [CollectionsSingletonSet setWithObject:_key] : [CollectionsEmptySet set];
}

@end