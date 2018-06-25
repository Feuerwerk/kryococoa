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

#import "MapSerializer.h"
#import "Kryo.h"

@implementation MapSerializer

- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		self.keysCanBeNull = YES;
		self.valuesCanBeNull = YES;
	}
	
	return self;
}

- (void)setGenerics:(NSArray *)generics kryo:(Kryo *)kryo
{
	Class newKeyGenericType = [generics objectAtIndex:0];
	Class newValueGenericType = [generics objectAtIndex:1];
	
	if ([kryo isFinal:newKeyGenericType])
	{
		_keyGenericType = newKeyGenericType;
	}

	if ([kryo isFinal:newValueGenericType])
	{
		_valueGenericType = newValueGenericType;
	}
}

- (BOOL) acceptsNull
{
	return NO;
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	NSDictionary *items = value;
	int itemCount = (int)items.count;
	
	[output writeInt:itemCount optimizePositive:YES];
	
	id<Serializer> keySerializer = self.keySerializer;
	id<Serializer> valueSerializer = self.valueSerializer;

	if (_keyGenericType != nil)
	{
		if (keySerializer == nil)
		{
			keySerializer = [kryo getSerializer:_keyGenericType];
		}

		_keyGenericType = nil;
	}
	
	if (_valueGenericType != nil)
	{
		if (valueSerializer == nil)
		{
			valueSerializer = [kryo getSerializer:_valueGenericType];
		}
		
		_valueGenericType = nil;
	}
	
	[items enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
	 {
		if (keySerializer != nil)
		{
			if (self->_keysCanBeNull)
			{
				[kryo writeNullableObject:key to:output usingSerializer:keySerializer];
			}
			else
			{
				[kryo writeObject:key to:output usingSerializer:keySerializer];
			}
		}
		else
		{
			[kryo writeClassAndObject:key to:output];
		}
		 
		if (obj == [NSNull null])
		{
			obj = nil;
		}
		 
		if (valueSerializer != nil)
		{
			if (self->_valuesCanBeNull)
			{
				[kryo writeNullableObject:obj to:output usingSerializer:valueSerializer];
			}
			else
			{
				[kryo writeObject:obj to:output usingSerializer:keySerializer];
			}
		}
		else
		{
			[kryo writeClassAndObject:obj to:output];
		}
	 }];
}

- (id)read:(Kryo *)kryo withClass:(Class)clazz from:(KryoInput *)input
{
	//Map map = create(kryo, input, type);
	NSMutableDictionary *map = [NSMutableDictionary new];
	NSUInteger length = [input readIntOptimizePositive:YES];
	
	Class keyClass = self.keyClass;
	Class valueClass = self.valueClass;
	id<Serializer> keySerializer = self.keySerializer;
	id<Serializer> valueSerializer = self.valueSerializer;

	if (_keyGenericType != nil)
	{
		keyClass = _keyGenericType;

		if (keySerializer == nil)
		{
			keySerializer = [kryo getSerializer:keyClass];
		}

		_keyGenericType = nil;
	}
	
	if (_valueGenericType != nil)
	{
		valueClass = _valueGenericType;

		if (valueSerializer == nil)
		{
			valueSerializer = [kryo getSerializer:valueClass];
		}

		_valueGenericType = nil;
	}
	
	[kryo reference:map];
	
	for (NSUInteger i = 0; i < length; i++)
	{
		id key;
		id value;

		if (keySerializer != nil)
		{
			if (_keysCanBeNull)
			{
				key = [kryo readNullableObject:input ofClass:keyClass usingSerializer:keySerializer];
			}
			else
			{
				key = [kryo readObject:input ofClass:keyClass usingSerializer:keySerializer];
			}
		}
		else
		{
			key = [kryo readClassAndObject:input];
		}

		if (valueSerializer != nil)
		{
			if (_valuesCanBeNull)
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

		if (value != nil)
		{
			[map setObject:value forKey:key];
		}
		else
		{
			NSLog(@"Warning: Map-Element %@ is nil", key);
		}
	}

	return map;
}

- (NSString *)getClassName:(Class)type
{
	return @"java.util.HashMap";
}

@end
