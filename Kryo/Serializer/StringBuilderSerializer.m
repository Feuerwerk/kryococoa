//
//  StringBuilderSerializer.m
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import "StringBuilderSerializer.h"
#import "Kryo.h"

@implementation StringBuilderSerializer

- (BOOL)acceptsNull
{
	return YES;
}

- (BOOL)isFinal:(Class)type
{
	return YES;
}

- (NSString *)getClassName:(Class)type
{
	return @"java.lang.StringBuilder";
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	[output writeString:value];
}

- (id)read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	return [input readMutableString];
}

@end
