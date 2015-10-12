// ======================================================================================
// Copyright (c) 2013, Christian Fruth, Boxx IT Solutions e.K.
// Based on Kryo for Java, Nathan Sweet
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this list
// of conditions and the following disclaimer.
// Redistributions in binary form must reproduce the above copyright notice, this list
// of conditions and the following disclaimer in the documentation and/or other materials
// provided with the distribution.
// Neither the name of the Boxx IT Solutions e.K. nor the names of its contributors may
// be used to endorse or promote products derived from this software without specific
// prior written permission.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
// SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
// TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
// DAMAGE.
// ======================================================================================

#import "ArraySerializer.h"
#import "Kryo.h"

@implementation ArraySerializer

- (id)init
{
	self = [super init];

	if (self != nil)
	{
		_elementsCanBeNull = YES;
	}

	return self;
}

- (BOOL)acceptsNull
{
	return NO;
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	NSArray *items = value;
	int itemCount = (int)items.count;
	id<Serializer> valueSerializer = self.valueSerializer;

	[output writeInt:itemCount optimizePositive:YES];

	if (_valueGenericType != nil)
	{
		if (valueSerializer == nil)
		{
			valueSerializer = [kryo getSerializer:_valueGenericType];
		}

		_valueGenericType = nil;
	}

	if (valueSerializer != nil)
	{
		if (_elementsCanBeNull)
		{
			for (NSUInteger i = 0; i < itemCount; i++)
			{
				[kryo writeNullableObject:items[i] to:output usingSerializer:valueSerializer];
			}
		}
		else
		{
			for (NSUInteger i = 0; i < itemCount; i++)
			{
				[kryo writeObject:items[i] to:output usingSerializer:valueSerializer];
			}
		}
	}
	else
	{
		for (NSUInteger i = 0; i < itemCount; i++)
		{
			[kryo writeClassAndObject:items[i] to:output];
		}
	}
}

- (void)setGenerics:(NSArray *)generics kryo:(Kryo *)kryo
{
	Class newValueGenericType = [generics objectAtIndex:0];

	if ([kryo isFinal:newValueGenericType])
	{
		_valueGenericType = newValueGenericType;
	}
}

- (id)read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	NSUInteger length = (NSUInteger)[input readIntOptimizePositive:YES];
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:length];
	Class valueClass = self.valueClass;
	id<Serializer> valueSerializer = self.valueSerializer;

	if (_valueGenericType != nil)
	{
		valueClass = _valueGenericType;

		if (valueSerializer == nil)
		{
			valueSerializer = [kryo getSerializer:valueClass];
		}

		_valueGenericType = nil;
	}

	[kryo reference:items];

	for (int i = 0; i < length; i++)
	{
		id value;

		if (valueSerializer != nil)
		{
			if (_elementsCanBeNull)
			{
				value = [kryo readNullableObject:input ofClass:valueClass usingSerializer:valueSerializer];
			}
			else
			{
				value = [kryo readObject:input ofClass:valueClass usingSerializer:valueSerializer];
			}
		}
		else
		{
			value = [kryo readClassAndObject:input];
		}

		if (value == nil)
		{
			value = [NSNull null];
		}

		[items addObject:value];
	}

	return items;
}

- (NSString *)getClassName:(Class)type
{
	return @"java.util.ArrayList";
}

@end
