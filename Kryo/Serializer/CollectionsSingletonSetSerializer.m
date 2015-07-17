//
//  CollectionsSingletonSetSerializer.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsSingletonSetSerializer.h"
#import "CollectionsSingletonSet.h"
#import "Kryo.h"

@implementation CollectionsSingletonSetSerializer

- (NSString *)getClassName:(Class)type
{
	return @"java.util.Collections$SingletonSet";
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	CollectionsSingletonSet *set = value;
	[kryo writeClassAndObject:set.anyObject to:output];
}

- (id)read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	id value = [kryo readClassAndObject:input];
	return [CollectionsSingletonSet setWithObject:value];
}

@end
