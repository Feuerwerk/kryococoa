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

#import "Kryo.h"
#import "ReferenceResolver.h"
#import "ListReferenceResolver.h"
#import "ClassResolver.h"
#import "DefaultClassResolver.h"
#import "ObjectMap.h"
#import "Serializer/JBooleanSerializer.h"
#import "Serializer/JByteSerializer.h"
#import "Serializer/JCharacterSerializer.h"
#import "Serializer/JShortSerializer.h"
#import "Serializer/JIntegerSerializer.h"
#import "Serializer/JLongSerializer.h"
#import "Serializer/JFloatSerializer.h"
#import "Serializer/JDoubleSerializer.h"
#import "Serializer/FieldSerializer.h"
#import "Serializer/DateSerializer.h"
#import "Serializer/StringSerializer.h"
#import "Serializer/SetSerializer.h"
#import "Serializer/MapSerializer.h"
#import "Serializer/ArraySerializer.h"
#import "Serializer/DataSerializer.h"
#import "Serializer/EnumSerializer.h"
#import "Registration.h"
#import "Enum.h"
#import "SerializationAnnotation.h"
#import <objc/runtime.h>

@interface DefaultSerializerEntry : NSObject

@property (nonatomic) Class type;
@property (nonatomic) Class serializerClass;
@property (nonatomic) id<Serializer> serializer;

@end


@implementation DefaultSerializerEntry


@end


@interface Kryo()

- (BOOL) writeReferenceOrNull:(id)obj to:(KryoOutput *)output mayBeNull:(BOOL)mayBeNull;
- (int)readReferenceOrNull:(KryoInput *)input withClass:(Class)type mayBeNull:(BOOL)mayBeNull;
- (void)reset;
- (void)beginObject;
- (id<Serializer>)newDefaultSerializer:(Class)type;
- (id<Serializer>)newSerializer:(Class)serializerClass forType:(Class)type;
- (SInt32)nextRegistrationId;

@end


@implementation Kryo

const int REF = -1;
const int NO_REF = -2;

BOOL acceptsNull(id<Serializer> serializer)
{
	if ([serializer respondsToSelector:@selector(acceptsNull)])
	{
		return [serializer acceptsNull];
	}
	
	return NO;
}

- (id) init
{
	self = [super init];
	
	if (self != nil)
	{
		_nextRegisterID = 0;
		_autoReset = YES;
		_maxDepth = INT_MAX;
		_defaultSerializers = [NSMutableArray new];
		_readReferenceIds = [NSMutableArray new];
		_classAliases = [NSMutableDictionary new];
		_reverseAliases = [NSMutableDictionary new];
		_defaultSerializer = [FieldSerializer class];
		_referenceResolver = [ListReferenceResolver new];
		_classResolver = [DefaultClassResolver new];
		_null = [NSNull null];
		[_classResolver setKryo:self];
		
		// Default-Registrations
		[self registerClass:[JInteger class] usingSerializer:[JIntegerSerializer new]];
		[self registerClass:[NSString class] usingSerializer:[StringSerializer new]];
		[self registerClass:[JFloat class] usingSerializer:[JFloatSerializer new]];
		[self registerClass:[JBoolean class] usingSerializer:[JBooleanSerializer new]];
		[self registerClass:[JByte class] usingSerializer:[JByteSerializer new]];
		[self registerClass:[JCharacter class] usingSerializer:[JCharacterSerializer new]];
		[self registerClass:[JShort class] usingSerializer:[JShortSerializer new]];
		[self registerClass:[JLong class] usingSerializer:[JLongSerializer new]];
		[self registerClass:[JDouble class] usingSerializer:[JDoubleSerializer new]];

		// Default-Serializer
		[self registerDefaultSerializer:[MapSerializer new] forClass:[NSDictionary class]];
		[self registerDefaultSerializer:[ArraySerializer new] forClass:[NSArray class]];
		[self registerDefaultSerializer:[DateSerializer new] forClass:[NSDate class]];
		[self registerDefaultSerializer:[DataSerializer new] forClass:[NSData class]];
		[self registerDefaultSerializer:[StringSerializer new] forClass:[NSString class]];
		[self registerDefaultSerializerClass:[EnumSerializer class] forClass:[Enum class]];
		
		// Default Aliases
		[self registerAlias:@"java.util.TreeMap" forClass:[NSDictionary class]];
		[self registerAlias:@"java.util.HashMap" forClass:[NSDictionary class]];
		[self registerAlias:@"java.util.HashSet" forClass:[NSSet class]];
		[self registerAlias:@"java.util.ArrayList" forClass:[NSArray class]];
		[self registerAlias:@"java.util.Date" forClass:[NSDate class]];
		
		// Resolve Aliases
		Class *classes = NULL;
		int numClasses = objc_getClassList(NULL, 0);

		if (numClasses > 0 )
		{
			classes = (Class *)malloc(sizeof(Class) * numClasses);
			numClasses = objc_getClassList(classes, numClasses);

			for (int index = 0; index < numClasses; index++)
			{
				Class nextClass = classes[index];

				if (class_conformsToProtocol(nextClass, @protocol(SerializationAnnotation)))
				{
					if ([nextClass respondsToSelector:@selector(serializingAlias)])
					{
						NSString *alias = [nextClass serializingAlias];
						[self registerAlias:alias forClass:nextClass];
					}
					
					if ([nextClass respondsToSelector:@selector(defaultSerializer)])
					{
						Class serializerClass = [nextClass defaultSerializer];
						
						[self registerDefaultSerializerClass:serializerClass forClass:nextClass];
					}
				}
			}

			free(classes);
		}
	}
	
	return self;
}

- (ObjectMap *)graphContext
{
	if (_graphContext == nil)
	{
		_graphContext = [ObjectMap new];
	}
	
	return _graphContext;
}

- (void) setClassResolver:(id<ClassResolver>)newClassResolver
{
	_classResolver = newClassResolver;
	[_classResolver setKryo:self];
}

- (void)registerDefaultSerializerClass:(Class)serializerClass forClass:(Class)type
{
	DefaultSerializerEntry *newEntry = [DefaultSerializerEntry new];
	newEntry.type = type;
	newEntry.serializerClass = serializerClass;
	newEntry.serializer = nil;
	[_defaultSerializers addObject:newEntry];
}

- (void)registerDefaultSerializer:(id<Serializer>)serializer forClass:(Class)type
{
	DefaultSerializerEntry *newEntry = [DefaultSerializerEntry new];
	newEntry.type = type;
	newEntry.serializer = serializer;
	newEntry.serializerClass = nil;
	[_defaultSerializers addObject:newEntry];
}

- (void)registerAlias:(NSString *)alias forClass:(Class)type
{
	NSString *typeKey = NSStringFromClass(type);
	[_classAliases setObject:type forKey:alias];
	[_reverseAliases setObject:alias forKey:typeKey];
}

- (void)registerClass:(Class)type usingSerializer:(id<Serializer>)serializer
{
	[self registerClass:type usingSerializer:serializer andIdent:self.nextRegistrationId];
}

- (void)registerClass:(Class)type andIdent:(NSInteger)ident
{
	[self registerClass:type usingSerializer:[self getDefaultSerializer:type] andIdent:ident];
}

- (void)registerClass:(Class)type usingSerializer:(id<Serializer>)serializer andIdent:(NSInteger)ident
{
	Registration *registration = [Registration new];
	
	registration.type = type;
	registration.serializer = serializer;
	registration.ident = ident;
	
	[_classResolver addRegistration:registration];
	
	if ([serializer respondsToSelector:@selector(getClassName:)])
	{
		NSString *alias = [serializer getClassName:type];
		[self registerAlias:alias forClass:type];
	}
}

- (id)newInstance:(Class)type
{
	return [type new];
}

- (void)writeObject:(id)obj to:(KryoOutput *)output
{
	if (output == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"output cannot be nil."];
	}
	
	if (obj == _null)
	{
		obj = nil;
	}

	if (obj == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"obj cannot be nil."];
	}
	
	[self beginObject];
	
	@try
	{
		if ((_referenceResolver != nil) && [self writeReferenceOrNull:obj to:output mayBeNull:NO])
		{
			return;
		}

		id<Serializer> serializer = [self getRegistration:[obj class]].serializer;
		[serializer write:self value:obj to:output];
	}
	@finally
	{
		if ((--_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (void) writeObject:(id)obj to:(KryoOutput *)output usingSerializer:(id<Serializer>)serializer
{
	if (output == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"output cannot be nil."];
	}
	
	if (obj == _null)
	{
		obj = nil;
	}
	
	if (obj == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"obj cannot be nil."];
	}
	
	[self beginObject];
	
	@try
	{
		if ((_referenceResolver != nil) && [self writeReferenceOrNull:obj to:output mayBeNull:NO])
		{
			return;
		}

		[serializer write:self value:obj to:output];
	}
	@finally
	{
		if ((--_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (void)writeNullableObject:(id)obj withClass:(Class)type to:(KryoOutput *)output
{
	if (output == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"output cannot be nil."];
	}
	
	if (obj == _null)
	{
		obj = nil;
	}
	
	[self beginObject];
	
	@try
	{
		if ((_referenceResolver != nil) && [self writeReferenceOrNull:obj to:output mayBeNull:NO])
		{
			return;
		}
	
		id<Serializer> serializer = [self getRegistration:type].serializer;

		if (_referenceResolver != nil)
		{
			if ([self writeReferenceOrNull:obj to:output mayBeNull:YES])
			{
				return;
			}
		}
		else if (!acceptsNull(serializer))
		{
			if (obj == nil)
			{
				[output writeByte:IS_NULL];
				return;
			}

			[output writeByte:NOT_NULL];
		}

		[serializer write:self value:obj to:output];
	}
	@finally
	{
		if ((--_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (void) writeNullableObject:(id)obj to:(KryoOutput *)output usingSerializer:(id<Serializer>)serializer
{
	if (output == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"output cannot be nil."];
	}
	
	if (serializer == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"serializer cannot be nil."];
	}
	
	if (obj == _null)
	{
		obj = nil;
	}
	
	[self beginObject];
	
	@try
	{
		if (_referenceResolver != nil)
		{
			if ([self writeReferenceOrNull:obj to:output mayBeNull:YES])
			{
				return;
			}
		}
		else if (!acceptsNull(serializer))
		{
			if (obj == nil)
			{
				[output writeByte:IS_NULL];
				return;
			}
			
			[output writeByte:NOT_NULL];
		}
		
		[serializer write:self value:obj to:output];
	}
	@finally
	{
		if ((--_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (void) writeClassAndObject:(id)obj to:(KryoOutput *)output
{
	if (output == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"output cannot be nil."];
	}
	
	if (obj == _null)
	{
		obj = nil;
	}

	[self beginObject];
	
	@try
	{
		if (obj == nil)
		{
			[self writeClass:nil to:output];
			return;
		}

		Registration *registration = [self writeClass:[obj class] to:output];
		
		if ((_referenceResolver != nil) && [self writeReferenceOrNull:obj to:output mayBeNull:NO])
		{
			return;
		}

		[registration.serializer write:self value:obj to:output];
	}
	@finally
	{
		if ((--_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (Registration *) writeClass:(Class)type to:(KryoOutput *)output
{
	if (output == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"output cannot be nil."];
	}

	@try
	{
		return [_classResolver writeClass:type to:output];
	}
	@finally
	{
		if ((_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (id)readObject:(KryoInput *)input ofClass:(Class)type
{
	if (input == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"input cannot be nil."];
	}
	
	if (type == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"type cannot be nil."];
	}
	
	[self beginObject];

	@try
	{
		id object;

		if (_referenceResolver != nil)
		{
			int stackSize = [self readReferenceOrNull:input withClass:type mayBeNull:NO];

			if (stackSize == REF)
			{
				return _readObject;
			}

			id<Serializer> serializer = [self getRegistration:type].serializer;
			object = [serializer read:self withClass:type from:input];

			if (stackSize == _readReferenceIds.count)
			{
				[self reference:object];
			}
		}
		else
		{
			id<Serializer> serializer = [self getRegistration:type].serializer;
			object = [serializer read:self withClass:type from:input];
		}

		return object;
	}
	@finally
	{
		if ((--_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (id) readObject:(KryoInput *)input ofClass:(Class)type usingSerializer:(id<Serializer>)serializer
{
	if (input == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"input cannot be nil."];
	}
	
	if (type == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"type cannot be nil."];
	}
	
	if (serializer == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"serializer cannot be nil."];
	}

	[self beginObject];
	
	@try
	{
		id object;

		if (_referenceResolver != nil)
		{
			int stackSize = [self readReferenceOrNull:input withClass:type mayBeNull:NO];
			
			if (stackSize == REF)
			{
				return _readObject;
			}
			
			object = [serializer read:self withClass:type from:input];
			
			if (stackSize == _readReferenceIds.count)
			{
				[self reference:object];
			}
		}
		else
		{
			object = [serializer read:self withClass:type from:input];
		}
		
		return object;
	}
	@finally
	{
		if ((--_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (id)readNullableObject:(KryoInput *)input ofClass:(Class)type
{
	if (input == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"input cannot be nil."];
	}
	
	if (type == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"type cannot be nil."];
	}
	
	[self beginObject];

	@try
	{
		id object;

		if (_referenceResolver != nil)
		{
			int stackSize = [self readReferenceOrNull:input withClass:type mayBeNull:YES];

			if (stackSize == REF)
			{
				return _readObject;
			}

			id<Serializer> serializer = [self getRegistration:type].serializer;
			object = [serializer read:self withClass:type from:input];
			
			if (stackSize == _readReferenceIds.count)
			{
				[self reference:object];
			}
		}
		else
		{
			id<Serializer> serializer = [self getRegistration:type].serializer;

			if (!acceptsNull(serializer) && ([input readByte] == IS_NULL))
			{
				return nil;
			}

			object = [serializer read:self withClass:type from:input];
		}

		return object;
	}
	@finally
	{
		if ((--_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (id) readNullableObject:(KryoInput *)input ofClass:(Class)type usingSerializer:(id<Serializer>)serializer
{
	if (input == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"input cannot be nil."];
	}
	
	if (type == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"type cannot be nil."];
	}
	
	if (serializer == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"serializer cannot be nil."];
	}
	
	[self beginObject];
	
	@try
	{
		id object;
		
		if (_referenceResolver != nil)
		{
			int stackSize = [self readReferenceOrNull:input withClass:type mayBeNull:YES];
			
			if (stackSize == REF)
			{
				return _readObject;
			}
			
			object = [serializer read:self withClass:type from:input];
			
			if (stackSize == _readReferenceIds.count)
			{
				[self reference:object];
			}
		}
		else
		{
			if (!acceptsNull(serializer) && ([input readByte] == IS_NULL))
			{
				return nil;
			}
			
			object = [serializer read:self withClass:type from:input];
		}
		
		return object;
	}
	@finally
	{
		if ((--_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (id) readClassAndObject:(KryoInput *)input
{
	if (input == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"input cannot be nil."];
	}

	[self beginObject];
	
	@try
	{
		Registration *registration = [self readClass:input];

		if (registration == nil)
		{
			return nil;
		}

		Class type = registration.type;
		id object;

		if (_referenceResolver != nil)
		{
			int stackSize = [self readReferenceOrNull:input withClass:type mayBeNull:NO];
			
			if (stackSize == REF)
			{
				return _readObject;
			}
			
			object = [registration.serializer read:self withClass:type from:input];
			
			if (stackSize == _readReferenceIds.count)
			{
				[self reference:object];
			}
		}
		else
		{
			object = [registration.serializer read:self withClass:type from:input];
		}

		return object;
	}
	@finally
	{
		if ((--_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (Registration *) readClass:(KryoInput *)input
{
	if (input == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"input cannot be nil."];
	}

	@try
	{
		return [_classResolver readClass:input];
	}
	@finally
	{
		if ((_depth == 0) && _autoReset)
		{
			[self reset];
		}
	}
}

- (Class)classFromString:(NSString *)className
{
	if (className == nil)
	{
		return nil;
	}
	
	Class type = [_classAliases objectForKey:className];
	
	if (type == nil)
	{
		type = NSClassFromString(className);
	}
	
	return type;
}

- (NSString *)stringFromClass:(Class)type
{
	if (type == nil)
	{
		return nil;
	}
	
	NSString *className = NSStringFromClass(type);
	NSString *alias = [_reverseAliases objectForKey:className];
	
	return (alias != nil) ? alias : className;
}

- (BOOL)isFinal:(Class)type
{
	Registration *registration = [self getRegistration:type];
	
	if ([registration.serializer respondsToSelector:@selector(isFinal:)])
	{
		return [registration.serializer isFinal:type];
	}
	
	return NO;
}

- (Registration *)getRegistration:(Class)type
{
	if (type == _memoizedClass)
	{
		return _memoizedClassValue;
	}

	Registration *registration = [_classResolver getRegistration:type];

	if (registration == nil)
	{
		registration = [_classResolver registerImplicit:type];
	}

	_memoizedClass = type;
	_memoizedClassValue = registration;

	return registration;
}

- (id<Serializer>) getSerializer:(Class)type
{
	Registration *registration = [self getRegistration:type];
	
	if (registration == nil)
	{
		return nil;
	}
	
	return registration.serializer;
}

- (id<Serializer>) getDefaultSerializer:(Class)type
{
	if (type == nil)
	{
		[NSException raise:NSInvalidArgumentException format:@"type cannot be nil."];
	}
	
	/*
	if (type.isAnnotationPresent(DefaultSerializer.class))
		return newSerializer(((DefaultSerializer)type.getAnnotation(DefaultSerializer.class)).value(), type);
	*/

	for (NSUInteger i = 0, serializerCount = _defaultSerializers.count; i < serializerCount; i++)
	{
		DefaultSerializerEntry *entry = [_defaultSerializers objectAtIndex:i];

		if ([type isSubclassOfClass:entry.type])
		{
			if (entry.serializer != nil)
			{
				return entry.serializer;
			}

			return [self newSerializer:entry.serializerClass forType:type];
		}
	}
	
	return [self newDefaultSerializer:type];
}

- (id<Serializer>) newDefaultSerializer:(Class)type
{
	return [self newSerializer:_defaultSerializer forType:type];
}

- (id<Serializer>) newSerializer:(Class)serializerClass forType:(Class)type
{
	NSObject<Serializer> *serializer = [serializerClass alloc];
	
	if ([serializer respondsToSelector:@selector(initWithType:)])
	{
		serializer = [serializer initWithType:type];
	}
	else if ([serializer respondsToSelector:@selector(initWithType:usingKryo:)])
	{
		serializer = [serializer initWithType:type usingKryo:self];
	}
	else
	{
		serializer = [serializer init];
	}
	
	return serializer;
}

- (int)readReferenceOrNull:(KryoInput *)input withClass:(Class)type mayBeNull:(BOOL)mayBeNull
{
	//if (type.isPrimitive()) type = getWrapperClass(type);
	BOOL referencesSupported = [_referenceResolver useReferences:type];
	int ident;

	if (mayBeNull)
	{
		ident = [input readIntOptimizePositive:YES];

		if (ident == IS_NULL)
		{
			_readObject = nil;
			return REF;
		}

		if (!referencesSupported)
		{
			[_readReferenceIds addObject:[NSNumber numberWithInt:NO_REF]];
			return (int)_readReferenceIds.count;
		}
	}
	else
	{
		if (!referencesSupported)
		{
			[_readReferenceIds addObject:[NSNumber numberWithInt:NO_REF]];
			return (int)_readReferenceIds.count;
		}

		ident = [input readIntOptimizePositive:YES];
	}

	if (ident == NOT_NULL)
	{
		// First time object has been encountered.
		ident = [_referenceResolver nextReadId:type];
		[_readReferenceIds addObject:[NSNumber numberWithInt:ident]];
		return (int)_readReferenceIds.count;
	}

	// The id is an object reference.
	ident -= 2; // - 2 because 0 and 1 are used for NULL and NOT_NULL.
	_readObject = [_referenceResolver getReadObject:type forKey:ident];

	return REF;
}

- (BOOL) writeReferenceOrNull:(id)obj to:(KryoOutput *)output mayBeNull:(BOOL)mayBeNull
{
	if (obj == nil)
	{
		[output writeByte:IS_NULL];
		return YES;
	}

	if (![_referenceResolver useReferences:[obj class]])
	{
		if (mayBeNull)
		{
			[output writeByte:NOT_NULL];
		}

		return NO;
	}
	
	// Determine if this object has already been seen in this object graph.
	int ident = [_referenceResolver getWrittenId:obj];
	
	// If not the first time encountered, only write reference ID.
	if (ident != -1)
	{
		[output writeInt:ident + 2 optimizePositive:YES]; // + 2 because 0 and 1 are used for NULL and NOT_NULL.
		return YES;
	}
	
	// Otherwise write NOT_NULL and then the object bytes.
	ident = [_referenceResolver addWrittenObject:obj];
	[output writeByte:NOT_NULL];

	return NO;
}

- (void)reference:(id)obj
{
	if ((_referenceResolver != nil) && (obj != nil))
	{
		NSNumber *identValue = [_readReferenceIds lastObject];
		int ident = identValue.intValue;
		[_readReferenceIds removeLastObject];
		
		if (ident != NO_REF)
		{
			[_referenceResolver addReadObject:obj forKey:ident];
		}
	}
}

- (void)reset
{
	_depth = 0;
	
	if (_graphContext != nil)
	{
		[_graphContext removeAllObjects];
	}
	
	//if (graphContext != null) graphContext.clear();
	[_classResolver reset];

	if (_referenceResolver != nil)
	{
		[_referenceResolver reset];
		_readObject = nil;
	}
}

- (void)beginObject
{
	if (_depth == _maxDepth)
	{
		[NSException raise:NSRangeException format:@"Max depth exceeded: %i", _depth];
	}

	_depth++;
}

- (SInt32)nextRegistrationId
{
	SInt32 ident = _nextRegisterID;

	while (true)
	{
		if ([_classResolver getRegistrationById:ident] == nil)
		{
			_nextRegisterID = ident + 1;
			return ident;
		}

		ident++;
	}
}

@end
