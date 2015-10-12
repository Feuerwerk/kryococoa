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

#import "JObjectArraySerializer.h"
#import "Kryo.h"

@implementation JObjectArraySerializer

id wrapNull(id obj)
{
	if (obj == nil)
	{
		return [NSNull null];
	}

	return obj;
}

- (id)init
{
	self = [super init];

	if (self != nil)
	{
		_elementsCanBeNull = YES;
	}

	return self;
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	if (value == nil)
	{
		[output writeByte:IS_NULL];
		return;
	}

	JObjectArray *items = value;
	int itemCount = (int)items.count;

	[output writeInt:itemCount + 1 optimizePositive:YES];

	Class elementClass = items.componentType;

	if ([kryo isFinal:elementClass])
	{
		id<Serializer> elementSerializer = [kryo getSerializer:elementClass];

		for (NSUInteger i = 0; i < itemCount; i++)
		{
			if (_elementsCanBeNull)
			{
				[kryo writeNullableObject:items[i] to:output usingSerializer:elementSerializer];
			}
			else
			{
				[kryo writeObject:items[i] to:output usingSerializer:elementSerializer];
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

- (id)read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	NSUInteger length = (NSUInteger)[input readIntOptimizePositive:YES];

	if (length == IS_NULL)
	{
		return nil;
	}

	length--;
	JObjectArray *items = [[clazz alloc] initWithCapacity:length];

	[kryo reference:items];

	Class elementClass = items.componentType;

	if ([kryo isFinal:elementClass])
	{
		id<Serializer> elementSerializer = [kryo getSerializer:elementClass];

		for (NSUInteger i = 0; i < length; i++)
		{
			id item;

			if (_elementsCanBeNull)
			{
				item = [kryo readNullableObject:input ofClass:elementClass usingSerializer:elementSerializer];
			}
			else
			{
				item = [kryo readObject:input ofClass:elementClass usingSerializer:elementSerializer];
			}

			[items addObject:wrapNull(item)];
		}
	}
	else
	{
		for (NSUInteger i = 0; i < length; i++)
		{
			id item = [kryo readClassAndObject:input];
			[items addObject:wrapNull(item)];
		}
	}

	return items;
}

- (NSString *)getClassName:(Class)type ofObject:(id)obj kryo:(Kryo *)kryo
{
	if (obj == nil)
	{
		return nil; // default handling
	}

	JObjectArray *items = obj;
	return [NSString stringWithFormat:@"[L%@;", [kryo stringFromClass:items.componentType]];
}

@end
