// ======================================================================================
// Copyright (c) 2013, Christian Fruth, Boxx IT Solutions e.K.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// Neither the name of the Boxx IT Solutions e.K. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ======================================================================================

#import "ListReferenceResolver.h"
#import "SerializationAnnotation.h"
#import <objc/runtime.h>

@implementation ListReferenceResolver

- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		_seenObjects = [NSMutableArray new];
	}
	
	return self;
}

- (void) reset
{
	[_seenObjects removeAllObjects];
}

- (BOOL) useReferences:(Class)type
{
	if (class_conformsToProtocol(type, @protocol(SerializationAnnotation)))
	{
		if ([type respondsToSelector:@selector(primitiveType)])
		{
			return ![type primitiveType];
		}
	}

	return YES;
}

- (int) nextReadId:(Class)type
{
	return (int)_seenObjects.count;
}

- (id) getReadObject:(Class)type forKey:(int)key
{
	if (key < _seenObjects.count)
	{
		return [_seenObjects objectAtIndex:key];
	}

	return nil;
}

- (void) addReadObject:(id)obj forKey:(int)key
{
	if (key == _seenObjects.count)
	{
		[_seenObjects addObject:obj];
	}
	else
	{
		while (key >= _seenObjects.count)
		{
			[_seenObjects addObject:nil];
		}

		[_seenObjects replaceObjectAtIndex:key withObject:obj];
	}
}

- (int) getWrittenId:(id)obj
{
	for (int i = 0, objCount = (int)_seenObjects.count; i < objCount; i++)
	{
		if ([_seenObjects objectAtIndex:i] == obj)
		{
			return i;	
		}
	}

	return -1;
}

- (int) addWrittenObject:(id)obj
{
	int key = (int)_seenObjects.count;
	[_seenObjects addObject:obj];
	return key;
}

@end
