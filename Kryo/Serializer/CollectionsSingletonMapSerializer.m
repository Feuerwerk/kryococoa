//
//  CollectionsSingletonMapSerializer.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsSingletonMapSerializer.h"
#import "CollectionsSingletonMap.h"
#import "Kryo.h"

@implementation CollectionsSingletonMapSerializer

- (NSString *)getClassName:(Class)type
{
	return @"java.util.Collections$SingletonMap";
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	CollectionsSingletonMap *map = value;
	[kryo writeClassAndObject:map.key to:output];
	[kryo writeClassAndObject:map.value to:output];
}

- (id)read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	id key = [kryo readClassAndObject:input];
	id value = [kryo readClassAndObject:input];
	return [CollectionsSingletonMap dictionaryWithObject:value forKey:key];
}

@end
