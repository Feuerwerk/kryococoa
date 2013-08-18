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

#import "DefaultClassResolver.h"
#import "Registration.h"
#import "Kryo.h"

@interface DefaultClassResolver ()

- (Registration *)readName:(KryoInput *)input;
- (void)writeName:(Registration *)registration withClass:(Class)type to:(KryoOutput *)output;

@end

@implementation DefaultClassResolver

const int NAME = -1;


- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		_classToRegistration = [NSMutableDictionary new];
		_idToRegistration = [NSMutableDictionary new];
		_nextNameId = 0;
	}
	
	return self;
}

- (void)setKryo:(Kryo *)kryo
{
	_kryo = kryo;
}

- (void) reset
{
	if (_classToNameId != nil)
	{
		[_classToNameId removeAllObjects];
	}

	if (_nameIdToClass != nil)
	{
		[_nameIdToClass removeAllObjects];
	}
	_nextNameId = 0;
}

- (Registration *)addRegistration:(Registration *)registration
{
	NSString *key = NSStringFromClass(registration.type);
	[_classToRegistration setObject:registration forKey:key];
	[_idToRegistration setObject:registration forKey:[NSNumber numberWithInt:registration.ident]];
	
	//if (registration.getType().isPrimitive()) classToRegistration.put(getWrapperClass(registration.getType()), registration);
	return registration;
}

- (Registration *)getRegistration:(Class)type
{
	NSString *key = NSStringFromClass(type);
	return [_classToRegistration objectForKey:key];
}

- (Registration *)getRegistrationById:(SInt32)ident
{
	return [_idToRegistration objectForKey:[NSNumber numberWithInt:ident]];
}

- (Registration *)registerImplicit:(Class)type
{
	Registration *newRegistration = [Registration new];

	newRegistration.type = type;
	newRegistration.serializer = [_kryo getDefaultSerializer:type];
	newRegistration.ident = NAME;

	[self addRegistration:newRegistration];
	
	// The Serializer will be seted up after the class is registered to avoid recursion problems
	if ([newRegistration.serializer respondsToSelector:@selector(setup:)])
	{
		[newRegistration.serializer setup:_kryo];
	}
	
	return newRegistration;
}

- (Registration *)readClass:(KryoInput *)input
{
	SInt32 classID = [input readIntOptimizePositive:YES];

	switch (classID)
	{
		case IS_NULL:
			return nil;

		case NAME + 2: // Offset for NAME and NULL.
			return [self readName:input];
	}

	if (classID == _memoizedClassId)
	{
		return _memoizedClassIdValue;
	}

	Registration *registration = [_idToRegistration objectForKey:[NSNumber numberWithInt:classID - 2]];

	if (registration == nil)
	{
		[NSException raise:@"unregistered" format:@"Encountered unregistered class ID: %ld", classID - 2];
	}

	_memoizedClassId = classID;
	_memoizedClassIdValue = registration;

	return registration;
}

- (Registration *)writeClass:(Class)type to:(KryoOutput *)output
{
	if (type == nil)
	{
		[output writeByte:IS_NULL];
		return nil;
	}
	
	Registration *registration = [_kryo getRegistration:type];

	if (registration.ident == NAME)
	{
		[self writeName:registration withClass:type to:output];
	}
	else
	{
		[output writeInt:registration.ident + 2 optimizePositive:YES];
	}

	return registration;
}

- (Registration *)readName:(KryoInput *)input
{
	SInt32 nameId = [input readIntOptimizePositive:YES];

	if (_nameIdToClass == nil)
	{
		_nameIdToClass = [NSMutableDictionary new];
	}

	NSNumber *nameKey = [NSNumber numberWithInt:nameId];
	Class type = [_nameIdToClass objectForKey:nameKey];

	if (type == nil)
	{
		// Only read the class name the first time encountered in object graph.
		NSString *className = [input readString];
		
		if (_nameToClass != nil)
		{
			type = [_nameToClass objectForKey:className];
		}

		if (type == nil)
		{
			type = [_kryo classFromString:className];
			
			if (type == nil)
			{
				[NSException raise:@"class" format:@"Unable to find class: %@", className];
			}

			if (_nameToClass == nil)
			{
				_nameToClass = [NSMutableDictionary new];
			}

			[_nameToClass setObject:type forKey:className];
		}

		[_nameIdToClass setObject:type forKey:nameKey];
	}

	return [_kryo getRegistration:type];
}

- (void)writeName:(Registration *)registration withClass:(Class)type to:(KryoOutput *)output
{
	[output writeByte:NAME + 2];
	
	NSNumber *nameId;
	NSString *typeName = nil;
	
	if ([registration.serializer respondsToSelector:@selector(getClassName:)])
	{
		typeName = [registration.serializer getClassName:type];
	}

	if (typeName == nil)
	{
		typeName = [_kryo stringFromClass:type];
	}

	if (_classToNameId != nil)
	{
		nameId = [_classToNameId objectForKey:typeName];
		
		if (nameId != nil)
		{
			[output writeInt:nameId.intValue optimizePositive:YES];
			return;
		}
	}

	// Only write the class name the first time encountered in object graph.
	nameId = [NSNumber numberWithInt:_nextNameId++];

	if (_classToNameId == nil)
	{
		_classToNameId = [NSMutableDictionary new];
	}

	[_classToNameId setObject:nameId forKey:typeName];
	[output writeByte:nameId.intValue];
	[output writeString:typeName];
}

@end
