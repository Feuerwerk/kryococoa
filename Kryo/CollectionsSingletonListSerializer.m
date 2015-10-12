//
//  CollectionsSingletonListSerializer.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsSingletonListSerializer.h"
#import "CollectionsSingletonList.h"
#import "Kryo.h"

@implementation CollectionsSingletonListSerializer

- (NSString *)getClassName:(Class)type
{
	return @"java.util.Collections$SingletonList";
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	CollectionsSingletonList *list = value;
	[kryo writeClassAndObject:list.firstObject to:output];
}

- (id)read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	id value = [kryo readClassAndObject:input];
	return [CollectionsSingletonList arrayWithObject:value];
}

@end
