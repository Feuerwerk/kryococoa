// ======================================================================================
// Copyright (c) 2013, Christian Fruth, Boxx IT Solutions e.K.
// Based on GandEnum (c) 2010, Andreas Glenn
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

#import "Enum.h"
#import <objc/runtime.h>

@implementation Enum

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_properties forKey:@"properties"];
    [aCoder encodeInt:_ordinal forKey:@"ordinal"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self != nil)
	{
		// see if the enum name exists - it should
		NSString *ename = [aDecoder decodeObjectForKey:@"name"];
		SEL sel = NSSelectorFromString(ename);
		Class type = self.class;

		if ([type respondsToSelector:sel])
		{
			_Pragma("clang diagnostic push")
			_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
			return [type performSelector:sel];
			_Pragma("clang diagnostic pop")
		}

		// no enum for this name, so treat as normal, which is the best we can hope for currently
		_name = ename;
		_properties = [aDecoder decodeObjectForKey:@"properties"];
		_ordinal = [aDecoder decodeIntForKey:@"ordinal"];
    }

    return self;
}

- (id)initWithName:(NSString *)aname ordinal:(int)anordinal properties:(NSDictionary *)aproperties
{
    self = [super init];

    if (self != nil)
	{
		_name = aname;
		_ordinal = anordinal;
		_properties = aproperties;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone;
{
    // we're immutable, just retain ourselves again
    return self;
}

+ (instancetype)valueOfName:(NSString *)name
{
    SEL sel = NSSelectorFromString(name);

    if ([self respondsToSelector:sel])
	{
		_Pragma("clang diagnostic push")
		_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
		return [self performSelector:sel];
		_Pragma("clang diagnostic pop")
    }

    return nil;
}

+ (instancetype)valueOfOrdinal:(int)ordinal
{
	// find first enum that has the corresponding ordinal
	for (Enum *retval in self.values)
	{
		if (retval.ordinal == ordinal)
		{
			return retval;
		}
    }

    return nil;
}

- (NSString *)description
{
    return _name;
}

- (NSString *)debugDescription
{
	if (_properties.count > 0)
	{
		return [NSString stringWithFormat: @"<%@:%x %@=%d %@>",NSStringFromClass(self.class), (int)self, _name, _ordinal, _properties];
    }
	
	return [NSString stringWithFormat: @"<%@:%x %@=%d>",NSStringFromClass(self.class), (int)self, _name, _ordinal];
}

- (NSUInteger)hash
{
	return [_name hash]; // use the hash of the string, that way "if two objects are equal (as determined by the isEqual: method) they must have the same hash value"
}

- (BOOL) isEqual:(id)other
{
    if (other == self)
	{
		return YES;
	}
	
    if ([other isKindOfClass:self.class] || [self isKindOfClass:[other class]])
	{
		return [_name isEqual:[other name]];
    }
	
	return NO;
}

#pragma mark Accessing

static NSInteger sortByOrdinal(id left, id right, void *ctx)
{
    return [left ordinal] - [right ordinal];
}

static NSMutableDictionary *enumCache = nil;

+ (NSArray *)values
{
    // use the class as a key for what enum list we want - it's expensive to build on the fly
    if (enumCache == nil)
	{
		enumCache = [NSMutableDictionary dictionary];
    }

	id<NSCopying> key = (id<NSCopying>)self;
    NSMutableArray *retval = [enumCache objectForKey:key];

    if (retval != nil)
	{
		return retval;
	}

    retval = [NSMutableArray array];
    [enumCache setObject:retval forKey:key];

    // walk the class methods
    unsigned int methodCount = 0;
    Method *mlist = class_copyMethodList(object_getClass(self), &methodCount);

    for (unsigned int i = 0;i < methodCount; i++)
	{
		NSString *mname = NSStringFromSelector(method_getName(mlist[i]));

		if ([[mname uppercaseString] isEqualToString:mname]) // entirely in uppercase, it's an enum
		{
			_Pragma("clang diagnostic push")
			_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
			id enumElement = [self performSelector:method_getName(mlist[i])];
			_Pragma("clang diagnostic pop")
			
			[retval addObject:enumElement]; // call it to retrieve the singleton
		}
    }

    if (retval.count > 0) // there may be no enums yet
	{
		[retval sortUsingFunction:sortByOrdinal context:nil];
    }

    free(mlist);
    return retval;
}

+ (void)invalidateEnumCache
{
	id<NSCopying> key = (id<NSCopying>)self;
    [enumCache removeObjectForKey:key];
}

#pragma mark dynamic ivar support

- (id)valueForUndefinedKey:(NSString *)key
{
    return [_properties objectForKey:key];
}

// to speed this code up, should create a map from SEL to NSString mapping selectors to their keys.
// converts a getter selector to an NSString, equivalent to NSStringFromSelector().

NS_INLINE NSString *getterKey(SEL sel)
{
	return [NSString stringWithUTF8String:sel_getName(sel)];
}

// Generic accessor methods for property types id, double, and NSRect.

static id getProperty(Enum *self, SEL name)
{
	return [self->_properties objectForKey:getterKey(name)];
}

#define TYPEDGETTER(type,Type,typeValue) \
static type get ## Type ## Property(Enum *self, SEL name) {\
return [[self->_properties objectForKey:getterKey(name)] typeValue];\
}

TYPEDGETTER(double, Double, doubleValue)
TYPEDGETTER(float, Float, floatValue)
TYPEDGETTER(char, Char, charValue)
TYPEDGETTER(unsigned char, UnsignedChar, unsignedCharValue)
TYPEDGETTER(short, Short, shortValue)
TYPEDGETTER(unsigned short, UnsignedShort, unsignedShortValue)
TYPEDGETTER(int, Int, intValue)
TYPEDGETTER(unsigned int, UnsignedInt, unsignedIntValue)
TYPEDGETTER(long, Long, longValue)
TYPEDGETTER(unsigned long, UnsignedLong, unsignedLongValue)
TYPEDGETTER(long long, LongLong, longLongValue)
TYPEDGETTER(unsigned long long, UnsignedLongLong, unsignedLongLongValue)
TYPEDGETTER(BOOL, Bool, boolValue)
TYPEDGETTER(void *, Pointer, pointerValue)

#ifdef UIKIT_EXTERN

static CGRect getCGRectProperty(Enum *self, SEL name)
{
	return [[self->_properties objectForKey:getterKey(name)] CGRectValue];
}

static CGPoint getCGPointProperty(Enum *self, SEL name)
{
	return [[self->_properties objectForKey:getterKey(name)] CGPointValue];
}

static CGSize getCGSizeProperty(Enum *self, SEL name)
{
	return [[self->_properties objectForKey:getterKey(name)] CGSizeValue];
}

#endif

#ifdef NSKIT_EXTERN

static NSRect getNSRectProperty(Enum *self, SEL name)
{
	return [[self->_properties objectForKey:getterKey(name)] rectValue];
}

static NSPoint getNSPointProperty(Enum *self, SEL name)
{
	return [[self->_properties objectForKey:getterKey(name)] pointValue];
}

static NSSize getNSSizeProperty(Enum *self, SEL name)
{
    return [[self->_properties objectForKey:getterKey(name)] sizeValue];
}

#endif

static const char* getPropertyType(objc_property_t property)
{
	// parse the property attribues. this is a comma delimited string. the type of the attribute starts with the
	// character 'T' should really just use strsep for this, using a C99 variable sized array.
	const char *attributes = property_getAttributes(property);
	char buffer[1 + strlen(attributes)];

    strcpy(buffer, attributes);

	char *state = buffer;
	char *attribute;

	while ((attribute = strsep(&state, ",")) != NULL)
	{
		if (attribute[0] == 'T')
		{
			// return a pointer scoped to the autorelease pool. Under GC, this will be a separate block.
			return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute)] bytes];
		}
	}

    return "@";
}

static BOOL getPropertyInfo(Class type, NSString *propertyName, Class *propertyClass, const char **propertyType)
{
	const char *name = [propertyName UTF8String];
	
	while (type != NULL)
	{
		objc_property_t property = class_getProperty(type, name);

		if (property)
		{
			*propertyClass = type;
			*propertyType = getPropertyType(property);
			return YES;
		}

		type = class_getSuperclass(type);
	}

	return NO;
}

+ (BOOL)resolveInstanceMethod:(SEL)name
{
	Class propertyClass;
	const char *propertyType;
	IMP accessor = NULL;
	const char *signature = NULL;

	// TODO:  handle more property types.
	if (strncmp("set", sel_getName(name), 3) == 0)
	{
		// choose an appropriately typed generic setter function. - we have no setters, enum properties are read only
	}
	else
	{
		// choose an appropriately typed getter function.
		if (getPropertyInfo(self, getterKey(name), &propertyClass, &propertyType))
		{
			switch (propertyType[0])
			{
				case _C_ID:
					accessor = (IMP)getProperty;
					signature = "@@:";
					break;

				case _C_CLASS:
					accessor = (IMP)getProperty;
					signature = "#@:";
					break;

				case _C_CHR:
					accessor = (IMP)getCharProperty;
					signature = "c@:";
					break;

				case _C_UCHR:
					accessor = (IMP)getUnsignedCharProperty;
					signature = "C@:";
					break;

				case _C_SHT:
					accessor = (IMP)getShortProperty;
					signature = "s@:";
					break;

				case _C_USHT:
					accessor = (IMP)getUnsignedShortProperty;
					signature = "S@:";
					break;

				case _C_INT:
					accessor = (IMP)getIntProperty;
					signature = "i@:";
					break;

				case _C_UINT:
					accessor = (IMP)getUnsignedIntProperty;
					signature = "I@:";
					break;

				case _C_LNG:
					accessor = (IMP)getLongProperty;
					signature = "l@:";
					break;

				case _C_ULNG:
					accessor = (IMP)getUnsignedLongProperty;
					signature = "L@:";
					break;

				case _C_LNG_LNG:
					accessor = (IMP)getLongLongProperty;
					signature = "q@:";
					break;

				case _C_ULNG_LNG:
					accessor = (IMP)getUnsignedLongLongProperty;
					signature = "Q@:";
					break;

				case _C_BOOL:
					accessor = (IMP)getBoolProperty;
					signature = "B@:";
					break;

				case _C_DBL:
					accessor = (IMP)getDoubleProperty;
					signature = "d@:";
					break;

				case _C_FLT:
					accessor = (IMP)getFloatProperty;
					signature = "f@:";
					break;

				case _C_PTR:
					accessor = (IMP)getPointerProperty;
					signature = "^@:";
					break;

				case _C_CHARPTR:
					accessor = (IMP)getPointerProperty;
					signature = "*@:";
					break;

				case _C_STRUCT_B:
#ifdef UIKIT_EXTERN
					if (strncmp(propertyType, "{_CGRect=", 9) == 0)
					{
						accessor = (IMP)getCGRectProperty;
						signature = "{_CGRect}@:";
					}
					else if (strncmp(propertyType, "{_CGPoint=", 10) == 0)
					{
						accessor = (IMP)getCGPointProperty;
						signature = "{_CGPoint}@:";
					}
					else if (strncmp(propertyType, "{_CGSize=", 9) == 0)
					{
						accessor = (IMP)getCGSizeProperty;
						signature = "{_CGSize}@:";
					}
#endif

#ifdef NSKIT_EXTERN
					if (strncmp(propertyType, "{_NSRect=", 9) == 0)
					{
						accessor = (IMP)getNSRectProperty;
						signature = "{_NSRect}@:";
					}
					else if (strncmp(propertyType, "{_NSPoint=", 10) == 0)
					{
						accessor = (IMP)getNSPointProperty;
						signature = "{_NSPoint}@:";
					}
					else if (strncmp(propertyType, "{_NSSize=", 9) == 0)
					{
						accessor = (IMP)getNSSizeProperty;
						signature = "{_NSSize}@:";
					}
#endif
					break;
            }
        }
    }

    if ((accessor != NULL) && (signature != NULL))
	{
		class_addMethod(propertyClass, name, accessor, signature);
		return YES;
	}

	return NO;
}

@end
