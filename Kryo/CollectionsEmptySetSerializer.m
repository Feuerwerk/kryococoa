//
//  CollectionsEmptySetSerializer.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "CollectionsEmptySetSerializer.h"
#import "CollectionsEmptySet.h"

@implementation CollectionsEmptySetSerializer

- (NSString *)getClassName:(Class)type
{
	return @"java.util.Collections$EmptySet";
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
}

- (id)read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	return [CollectionsEmptySet set];
}

@end
