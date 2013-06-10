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

#import "FieldSerializer.h"
#import "Field.h"
#import "Kryo.h"
#import "Registration.h"
#import "ReferenceResolver.h"
#import <objc/runtime.h>


/////////////////////////////////////////////////////////////////////////////////
// Common
/////////////////////////////////////////////////////////////////////////////////

static void invokeGetter(id object, SEL selector, void *returnValue, NSUInteger length)
{
	NSMethodSignature *methodSignature = [object methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];

	[invocation setSelector:selector];
	[invocation setTarget:object];
	[invocation invoke];

	NSUInteger returnLength = [[invocation methodSignature] methodReturnLength];

	if (returnLength != length)
	{
		[NSException raise:NSInvalidArgumentException format:@"Return type doesn't have correct length"];
	}

	[invocation getReturnValue:returnValue];
}

static void invokeSetter(id object, SEL selector, void *value)
{
	NSMethodSignature *methodSignature = [object methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];

	[invocation setSelector:selector];
	[invocation setTarget:object];
	[invocation setArgument:value atIndex:2];
	
	[invocation invoke];
}

/////////////////////////////////////////////////////////////////////////////////
// BooleanField
/////////////////////////////////////////////////////////////////////////////////

@interface BooleanField : Field

@end


@implementation BooleanField

- (BOOL)canBeNull
{
	return NO;
}

- (void)read:(id)object from:(KryoInput *)input usingKryo:(Kryo *)kryo
{
	bool propertyValue = [input readBoolean];
	invokeSetter(object, self.setter, &propertyValue);
}

- (void)write:(id)object to:(KryoOutput *)output usingKryo:(Kryo *)kryo
{
	bool propertyValue = false;
	invokeGetter(object, self.getter, &propertyValue, sizeof(propertyValue));
	[output writeBoolean:propertyValue];
}

@end

/////////////////////////////////////////////////////////////////////////////////
// ByteField
/////////////////////////////////////////////////////////////////////////////////

@interface ByteField : Field

@end


@implementation ByteField

- (BOOL)canBeNull
{
	return NO;
}

- (void)read:(id)object from:(KryoInput *)input usingKryo:(Kryo *)kryo
{
	SInt8 propertyValue = [input readByte];
	invokeSetter(object, self.setter, &propertyValue);
}

- (void)write:(id)object to:(KryoOutput *)output usingKryo:(Kryo *)kryo
{
	SInt8 propertyValue = 0;
	invokeGetter(object, self.getter, &propertyValue, sizeof(propertyValue));
	[output writeByte:propertyValue];
}

@end

/////////////////////////////////////////////////////////////////////////////////
// ShortField
/////////////////////////////////////////////////////////////////////////////////

@interface ShortField : Field

@end


@implementation ShortField

- (BOOL)canBeNull
{
	return NO;
}

- (void)read:(id)object from:(KryoInput *)input usingKryo:(Kryo *)kryo
{
	SInt16 propertyValue = [input readShort];
	invokeSetter(object, self.setter, &propertyValue);
}

- (void)write:(id)object to:(KryoOutput *)output usingKryo:(Kryo *)kryo
{
	SInt16 propertyValue = 0;
	invokeGetter(object, self.getter, &propertyValue, sizeof(propertyValue));
	[output writeShort:propertyValue];
}

@end

/////////////////////////////////////////////////////////////////////////////////
// IntegerField
/////////////////////////////////////////////////////////////////////////////////

@interface IntegerField : Field

@end


@implementation IntegerField

- (BOOL)canBeNull
{
	return NO;
}

- (void)read:(id)object from:(KryoInput *)input usingKryo:(Kryo *)kryo
{
	SInt32 propertyValue = [input readIntOptimizePositive:NO];
	invokeSetter(object, self.setter, &propertyValue);
}

- (void)write:(id)object to:(KryoOutput *)output usingKryo:(Kryo *)kryo
{
	SInt32 propertyValue = 0;
	invokeGetter(object, self.getter, &propertyValue, sizeof(propertyValue));
	[output writeInt:propertyValue optimizePositive:NO];
}

@end

/////////////////////////////////////////////////////////////////////////////////
// LongField
/////////////////////////////////////////////////////////////////////////////////

@interface LongField : Field

@end


@implementation LongField

- (BOOL)canBeNull
{
	return NO;
}

- (void)read:(id)object from:(KryoInput *)input usingKryo:(Kryo *)kryo
{
	SInt64 propertyValue = [input readLongOptimizePositive:NO];
	invokeSetter(object, self.setter, &propertyValue);
}

- (void)write:(id)object to:(KryoOutput *)output usingKryo:(Kryo *)kryo
{
	SInt64 propertyValue = 0;
	invokeGetter(object, self.getter, &propertyValue, sizeof(propertyValue));
	[output writeLong:propertyValue optimizePositive:NO];
}

@end

/////////////////////////////////////////////////////////////////////////////////
// FloatField
/////////////////////////////////////////////////////////////////////////////////

@interface FloatField : Field

@end


@implementation FloatField

- (BOOL)canBeNull
{
	return NO;
}

- (void)read:(id)object from:(KryoInput *)input usingKryo:(Kryo *)kryo
{
	float propertyValue = [input readFloat];
	invokeSetter(object, self.setter, &propertyValue);
}

- (void)write:(id)object to:(KryoOutput *)output usingKryo:(Kryo *)kryo
{
	float propertyValue = 0;
	invokeGetter(object, self.getter, &propertyValue, sizeof(propertyValue));
	[output writeFloat:propertyValue];
}

@end

/////////////////////////////////////////////////////////////////////////////////
// DoubleField
/////////////////////////////////////////////////////////////////////////////////

@interface DoubleField : Field

@end


@implementation DoubleField

- (BOOL)canBeNull
{
	return NO;
}

- (void)read:(id)object from:(KryoInput *)input usingKryo:(Kryo *)kryo
{
	double propertyValue = [input readDouble];
	invokeSetter(object, self.setter, &propertyValue);
}

- (void)write:(id)object to:(KryoOutput *)output usingKryo:(Kryo *)kryo
{
	double propertyValue = 0;
	invokeGetter(object, self.getter, &propertyValue, sizeof(propertyValue));
	[output writeDouble:propertyValue];
}

@end

/////////////////////////////////////////////////////////////////////////////////
// StringField
/////////////////////////////////////////////////////////////////////////////////

@interface StringField : Field

@end


@implementation StringField

- (BOOL)canBeNull
{
	return YES;
}

- (void)read:(id)object from:(KryoInput *)input usingKryo:(Kryo *)kryo
{
	NSString *propertyValue = [input readString];
	
	_Pragma("clang diagnostic push")
	_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
	[object performSelector:self.setter withObject:propertyValue];
	_Pragma("clang diagnostic pop")
}

- (void)write:(id)object to:(KryoOutput *)output usingKryo:(Kryo *)kryo
{
	_Pragma("clang diagnostic push")
	_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
	NSString *propertyValue = [object performSelector:self.getter];
	_Pragma("clang diagnostic pop")
	
	[output writeString:propertyValue];
}

@end

/////////////////////////////////////////////////////////////////////////////////
// ObjectField
/////////////////////////////////////////////////////////////////////////////////

@interface ObjectField : Field

@property (nonatomic) NSArray *generics;

@end


@implementation ObjectField

- (BOOL)canBeNull
{
	return YES;
}

- (void)read:(id)object from:(KryoInput *)input usingKryo:(Kryo *)kryo
{
	id propertyValue;
	Class concreteType = self.valueClass;
	id<Serializer> serializer = self.serializer;

	if (concreteType == nil)
	{
		Registration *registration = [kryo readClass:input];

		if (registration == nil)
		{
			propertyValue = nil;
		}
		else
		{
			if (serializer == nil)
			{
				serializer = registration.serializer;
			}
			
			if (_generics != nil)
			{
				[serializer setGenerics:_generics kryo:kryo];
			}

			propertyValue = [kryo readObject:input ofClass:registration.type usingSerializer:serializer];
		}
	}
	else
	{
		if (serializer == nil)
		{
			serializer = [kryo getSerializer:self.valueClass];
			self.serializer = serializer;
		}
		
		if (_generics != nil)
		{
			[serializer setGenerics:_generics kryo:kryo];
		}

		if (self.canBeNull)
		{
			propertyValue = [kryo readNullableObject:input ofClass:concreteType usingSerializer:serializer];
		}
		else
		{
			propertyValue = [kryo readObject:input ofClass:concreteType usingSerializer:serializer];
		}
	}
	
	_Pragma("clang diagnostic push")
	_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
	[object performSelector:self.setter withObject:propertyValue];
	_Pragma("clang diagnostic pop")
}

- (void)write:(id)object to:(KryoOutput *)output usingKryo:(Kryo *)kryo
{
	_Pragma("clang diagnostic push")
	_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
	id propertyValue = [object performSelector:self.getter];
	_Pragma("clang diagnostic pop")
	id<Serializer> serializer = self.serializer;

	if (self.valueClass == nil)
	{
		// The concrete type of the field is unknown, write the class first.
		if (propertyValue == nil)
		{
			[kryo writeClass:nil to:output];
			return;
		}

		Registration *registration = [kryo writeClass:[propertyValue class] to:output];

		if (serializer == nil)
		{
			serializer = registration.serializer;
		}
		
		if (_generics != nil)
		{
			[serializer setGenerics:_generics kryo:kryo];
		}

		[kryo writeObject:propertyValue to:output usingSerializer:serializer];

	}
	else
	{
		// The concrete type of the field is known, always use the same serializer.
		if (serializer == nil)
		{
			serializer = [kryo getSerializer:self.valueClass];
			self.serializer = serializer;
		}
		
		if (_generics != nil)
		{
			[serializer setGenerics:_generics kryo:kryo];
		}
		
		if (self.canBeNull)
		{
			[kryo writeNullableObject:propertyValue to:output usingSerializer:serializer];
		}
		else
		{
			if (propertyValue == nil)
			{
				[NSException raise:NSInvalidArgumentException format:@"Field value is null but canBeNull is false: %@ (%@)", self, NSStringFromClass([object class])];
			}

			[kryo writeObject:propertyValue to:output usingSerializer:serializer];
		}
	}
}

@end

/////////////////////////////////////////////////////////////////////////////////
// FieldSerializer
/////////////////////////////////////////////////////////////////////////////////

@interface FieldSerializer ()

- (Field *)newField:(const char *)encodedTypeName length:(NSUInteger)length usingKryo:(Kryo *)kryo;
- (Field *)fieldFromProperty:(objc_property_t)property usingKryo:(Kryo *)kryo;

@end


@implementation FieldSerializer

static Field *newField(NSString *propertyName, const char *encodedTypeName, NSUInteger length, Class type, Kryo *kryo)
{
	switch (encodedTypeName[0])
	{
		case '@':
		{
			NSString *typeName = [[NSString alloc] initWithBytes:encodedTypeName + 2 length:length - 3 encoding:NSASCIIStringEncoding];
			
			if ([typeName isEqualToString:@"NSString"])
			{
				id<ReferenceResolver> referenceResolver = [kryo referenceResolver];
				
				if ((referenceResolver == nil) || ![referenceResolver useReferences:[NSString class]])
				{
					return [StringField new];
				}
			}
			
			Class propertyType = NSClassFromString(typeName);
			ObjectField *newField = [ObjectField new];
			SEL genericsResolver = NSSelectorFromString([propertyName stringByAppendingString:@"Generics"]);
			
			if ([type respondsToSelector:genericsResolver])
			{
				_Pragma("clang diagnostic push")
				_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
				newField.generics = [type performSelector:genericsResolver];
				_Pragma("clang diagnostic pop")
			}
			
			if ([kryo isFinal:propertyType])
			{
				newField.valueClass = propertyType;
			}
			
			return newField;
		}
			
		case 'B':
			return [BooleanField new];
			
		case 'c':
			return [ByteField new];
			
		case 's':
			return [ShortField new];
			
		case 'i':
		case 'l':
			return [IntegerField new];
			
		case 'q':
			return [LongField new];
			
		case 'f':
			return [FloatField new];
			
		case 'd':
			return [DoubleField new];
			
		default:
			NSLog(@"Datatype %c of property %@.%@ is not known", encodedTypeName[0], type, propertyName);
			break;
	}
	
	return nil;
}

static Field *fieldFromProperty(NSString *propertyName, objc_property_t property, Class type, Kryo *kryo)
{
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
	
    strcpy(buffer, attributes);
    char *state = buffer;
	char *attribute;
	
    while ((attribute = strsep(&state, ",")) != NULL)
	{
        if (attribute[0] == 'T')
		{
			return newField(propertyName, attribute + 1, strlen(attribute) - 1, type, kryo);
        }
    }
	
    return nil;
}

static void resolvePropertyFields(Class type, NSMutableArray *fields, Kryo *kryo)
{
	// Resolve super-class first
	Class superType = class_getSuperclass(type);
	
	if ((superType != nil) && (superType != [NSObject class]))
	{
		resolvePropertyFields(superType, fields, kryo);
	}
	
	// then the properties declared in the current class
	unsigned int outCount;
	objc_property_t *properties = class_copyPropertyList(type, &outCount);
	
	@try
	{
		for (NSUInteger i = 0; i < outCount; i++)
		{
			objc_property_t propertyEntry = properties[i];
			const char *nameBytes = property_getName(propertyEntry);
			
			if (nameBytes == nil)
			{
				continue;
			}
			
			NSString *propertyName = [NSString stringWithCString:nameBytes encoding:NSASCIIStringEncoding];
			Field *newField = fieldFromProperty(propertyName, propertyEntry, type, kryo);
			NSString *setterName = [NSString stringWithFormat:@"set%@%@:", [[propertyName substringToIndex:1] uppercaseString], [propertyName substringFromIndex:1]];
			SEL getter = NSSelectorFromString(propertyName);
			SEL setter = NSSelectorFromString(setterName);
			
			if (![type instancesRespondToSelector:getter])
			{
				continue;
			}
			
			if (![type instancesRespondToSelector:setter])
			{
				continue;
			}
			
			newField.name = propertyName;
			newField.getter = getter;
			newField.setter = setter;
			
			[fields addObject:newField];
			
		}
	}
	@finally
	{
		free(properties);
	}
}

- (id)initWithType:(Class)type usingKryo:(Kryo *)kryo
{
	self = [super init];
	
	if (self != nil)
	{
		_type = type;
		
		// Resolve fields of "bean"
		NSMutableArray *fields = [NSMutableArray new];
		resolvePropertyFields(type, fields, kryo);
		_fields = [fields sortedArrayUsingSelector:@selector(compare:)];
		[self initializeCachedFields];
		
		if ([type respondsToSelector:@selector(serializingAlias)])
		{
			_className = [type serializingAlias];
		}
		else
		{
			_className = NSStringFromClass(type);
		}
	}
	
	return self;
}

- (void)initializeCachedFields
{
}

- (BOOL)acceptsNull
{
	return YES;
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	for (NSUInteger i = 0, fieldCount = _fields.count; i < fieldCount; i++)
	{
		Field *field = [_fields objectAtIndex:i];
		[field write:value to:output usingKryo:kryo];
	}
}

- (id)read:(Kryo *)kryo withClass:(Class)type from:(KryoInput *)input
{
	id object = [self create:type from:input usingKryo:kryo];
	[kryo reference:object];

	for (NSUInteger i = 0, fieldCount = _fields.count; i < fieldCount; i++)
	{
		Field *field = [_fields objectAtIndex:i];
		[field read:object from:input usingKryo:kryo];
	}

	return object;
}

- (id)create:(Class)type from:(KryoInput *)input usingKryo:(Kryo *)kryo
{
	return [kryo newInstance:type];
}

- (Field *)fieldFromProperty:(objc_property_t)property usingKryo:(Kryo *)kryo
{
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
	
    strcpy(buffer, attributes);
    char *state = buffer;
	char *attribute;
	
    while ((attribute = strsep(&state, ",")) != NULL)
	{
        if (attribute[0] == 'T')
		{
			return [self newField:attribute + 1 length:strlen(attribute) - 1 usingKryo:kryo];
        }
    }
	
    return nil;
}

- (Field *)newField:(const char *)encodedTypeName length:(NSUInteger)length usingKryo:(Kryo *)kryo
{
	switch (encodedTypeName[0])
	{
		case '@':
		{
			NSString *typeName = [[NSString alloc] initWithBytes:encodedTypeName + 2 length:length - 3 encoding:NSASCIIStringEncoding];
			
			if ([typeName isEqualToString:@"NSString"])
			{
				id<ReferenceResolver> referenceResolver = [kryo referenceResolver];

				if ((referenceResolver == nil) || ![referenceResolver useReferences:[NSString class]])
				{
					return [StringField new];
				}
			}
			
			Class type = NSClassFromString(typeName);
			ObjectField *newField = [ObjectField new];
			
			if ([kryo isFinal:type])
			{
				newField.valueClass = type;
			}

			return newField;
		}
			
		case 'B':
			return [BooleanField new];
			
		case 'c':
			return [ByteField new];
			
		case 's':
			return [ShortField new];
			
		case 'i':
			return [IntegerField new];
			
		case 'q':
			return [LongField new];
			
		case 'f':
			return [FloatField new];
			
		case 'd':
			return [DoubleField new];
			
		default:
			NSLog(@"Kenne den typ nicht");
			break;
	}

	return nil;
}

- (NSString *)getClassName:(Class)type
{
	return _className;
}

@end
