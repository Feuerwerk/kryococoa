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

#import "CompatibleFieldSerializer.h"
#import "Field.h"
#import "Kryo.h"
#import "ObjectMap.h"
#import "KryoInputChunked.h"
#import "KryoOutputChunked.h"

@implementation CompatibleFieldSerializer

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	ObjectMap *context = kryo.graphContext;
	NSUInteger fieldCount = _fields.count;

	if (![context containsKey:self])
	{
		[context setObject:self forKey:self];
		[output writeInt:(SInt32)fieldCount optimizePositive:YES];

		for (NSUInteger i = 0; i < fieldCount; i++)
		{
			Field *field = [_fields objectAtIndex:i];
			[output writeString:field.name];
		}
	}
	
	KryoOutputChunked *outputChunked = [KryoOutputChunked outputWithOutput:output usingBufferSize:1024];

	for (NSUInteger i = 0; i < fieldCount; i++)
	{
		Field *field = [_fields objectAtIndex:i];
		[field write:value to:outputChunked usingKryo:kryo];
		[outputChunked endChunks];
	}
}

- (id)read:(Kryo *)kryo withClass:(Class)type from:(KryoInput *)input
{
	id object = [self create:type from:input usingKryo:kryo];
	[kryo reference:object];
    ObjectMap *context = kryo.graphContext;
	NSArray *fields = [context objectForKey:self];

	if (fields == nil)
	{
		NSUInteger fieldCount = [input readIntOptimizePositive:YES];
		NSMutableArray *fieldNames = [NSMutableArray arrayWithCapacity:fieldCount];
		
		for (int i = 0; i < fieldCount; i++)
		{
			NSString *fieldName = [input readString];
			[fieldNames addObject:fieldName];
		}
        
        NSMutableArray *newFields = [NSMutableArray arrayWithCapacity:fieldCount];

		for (NSUInteger i = 0; i < fieldCount; i++)
		{
			NSString *fieldName = [fieldNames objectAtIndex:i];

			for (NSUInteger j = 0, thisCount = _fields.count; j < thisCount; j++)
			{
				Field *field = [_fields objectAtIndex:j];

				if ([field.name isEqualToString:fieldName])
				{
					[newFields addObject:field];
					break;
				}
			}
		}

		fields = [NSArray arrayWithArray:newFields];
		[context setObject:fields forKey:self];
    }
	
	KryoInputChunked *inputChunked = [KryoInputChunked inputWithInput:input];
	
	for (NSUInteger i = 0, fieldCount = fields.count; i < fieldCount; i++)
	{
		Field *field = [fields objectAtIndex:i];
		
		if (field == nil)
		{
			[inputChunked nextChunks];
			continue;
		}

		[field read:object from:inputChunked usingKryo:kryo];
		[inputChunked nextChunks];
	}

    return object;
}

@end
