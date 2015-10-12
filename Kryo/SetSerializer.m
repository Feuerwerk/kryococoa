//
//  SetSerializer.m
//  Kryo
//
//  Created by Christian Fruth on 26.07.13.
//  Copyright (c) 2013 Boxx IT Solutions e.K. All rights reserved.
//

#import "SetSerializer.h"
#import "Kryo.h"
#import "KryoInput.h"
#import "KryoOutput.h"

@implementation SetSerializer

- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		self.elementsCanBeNull = YES;
	}
	
	return self;
}

- (void)setGenerics:(NSArray *)generics kryo:(Kryo *)kryo
{
	Class newGenericType = [generics objectAtIndex:0];
	
	if ([kryo isFinal:newGenericType])
	{
		_genericType = newGenericType;
	}
}

- (BOOL) acceptsNull
{
	return NO;
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	NSSet *set = value;

	[output writeInt:(SInt32)set.count optimizePositive:YES];
	
	id<Serializer> serializer = self.serializer;
	
	if (_genericType != nil)
	{
		if (serializer == nil)
		{
			serializer = [kryo getSerializer:_genericType];
		}
		
		_genericType = nil;
	}

	if (serializer != nil)
	{
		if (_elementsCanBeNull)
		{
			for (id item in set)
			{
				[kryo writeNullableObject:item to:output usingSerializer:serializer];
			}
		}
		else
		{
			for (id item in set)
			{
				[kryo writeObject:item to:output usingSerializer:serializer];
			}
		}
	}
	else
	{
		for (id item in set)
		{
			[kryo writeClassAndObject:item to:output];
		}
	}
}

- (id) read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	NSMutableSet *set = [NSMutableSet new];
	NSUInteger length = [input readIntOptimizePositive:YES];
	
	[kryo reference:set];
	
	Class elementClass = _elementClass;
	id<Serializer> serializer = _serializer;

	if (_genericType != nil)
	{
		if (serializer == nil)
		{
			elementClass = _genericType;
			serializer = [kryo getSerializer:_genericType];
		}

		_genericType = nil;
	}

	if (serializer != nil)
	{
		if (_elementsCanBeNull)
		{
			for (int i = 0; i < length; i++)
			{
				id item = [kryo readNullableObject:input ofClass:elementClass usingSerializer:serializer];
				[set addObject:item];
			}
		}
		else
		{
			for (int i = 0; i < length; i++)
			{
				id item = [kryo readObject:input ofClass:elementClass usingSerializer:serializer];
				[set addObject:item];
			}
		}
	}
	else
	{
		for (int i = 0; i < length; i++)
		{
			id item = [kryo readClassAndObject:input];
			[set addObject:item];
		}
	}

	return set;
}

- (NSString *)getClassName:(Class)type
{
	return @"java.util.HashSet";
}

@end
