//
//  CollectionsEmptyMapSerializer.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsEmptyMapSerializer.h"
#import "CollectionsEmptyMap.h"

@implementation CollectionsEmptyMapSerializer

- (NSString *)getClassName:(Class)type
{
	return @"java.util.Collections$EmptyMap";
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
}

- (id)read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	return [CollectionsEmptyMap dictionary];
}

@end
