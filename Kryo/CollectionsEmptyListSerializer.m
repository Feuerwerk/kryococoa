//
//  CollectionsEmptyListSerializer.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsEmptyListSerializer.h"
#import "CollectionsEmptyList.h"

@implementation CollectionsEmptyListSerializer

- (NSString *)getClassName:(Class)type
{
	return @"java.util.Collections$EmptyList";
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
}

- (id)read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	return [CollectionsEmptyList array];
}

@end
