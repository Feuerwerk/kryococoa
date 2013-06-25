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

#import "TaggedFieldSerializer.h"
#import "KryoOutput.h"
#import "KryoInput.h"
#import "Field.h"
#import "Kryo.h"
#import "KryoException.h"
#import "../TagAnnotation.h"
#import <objc/runtime.h>

@implementation TaggedFieldSerializer

- (id)initWithType:(Class)type usingKryo:(Kryo *)kryo
{
	return [super initWithType:type usingKryo:kryo];
}

- (void)initializeCachedFields
{
	if (class_conformsToProtocol(_type, @protocol(TagAnnotation)))
	{
		[KryoException raise:[NSString stringWithFormat:@"Class %@ must conform to protocol TagAnnotation", NSStringFromClass(_type)]];
	}

	NSDictionary *tags = [_type taggedProperties];
	NSMutableArray *newFields = _fields.mutableCopy;
	NSUInteger i = 0;
	NSUInteger fieldCount = newFields.count;
	
	while (i < fieldCount)
	{
		Field *field = [newFields objectAtIndex:i];
		NSNumber *tag = [tags objectForKey:field.name];
		
		if ((tag == nil) || (tag.intValue <= 0)) // a negative value means deprecated
		{
			[newFields removeObjectAtIndex:i];
			fieldCount--;
		}
		else
		{
			field.tag = tag.intValue;
			i++;
		}
	}
	
	_fields = [NSArray arrayWithArray:newFields];
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	[output writeInt:_fields.count optimizePositive:YES];
	
	for (NSUInteger i = 0, fieldCount = _fields.count; i < fieldCount; i++)
	{
		Field *field = [_fields objectAtIndex:i];
		[output writeInt:field.tag optimizePositive:YES];
		[field write:value to:output usingKryo:kryo];
	}
}

- (id)read:(Kryo *)kryo withClass:(Class)type from:(KryoInput *)input
{
	id object = [self create:type from:input usingKryo:kryo];
	[kryo reference:object];
	
	NSUInteger availCount = [input readIntOptimizePositive:YES];
	
	for (NSUInteger i = 0; i < availCount; i++)
	{
		Field *field = nil;
		SInt32 tag = [input readIntOptimizePositive:YES];
		
		for (NSUInteger j = 0, fieldCount = _fields.count; j < fieldCount; j++)
		{
			Field *tempField = [_fields objectAtIndex:i];
			
			if (tag == tempField.tag)
			{
				field = tempField;
				break;
			}
		}
		
		if (field == nil)
		{
			[KryoException raise:[NSString stringWithFormat:@"Unknown field tag: %d (%@)", (int)tag, _className]];
		}
		
		[field read:object from:input usingKryo:kryo];
	}

	return object;
}

@end
