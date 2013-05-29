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

#import "JBoolean.h"

@implementation JBoolean

static JBoolean *TRUE_VALUE;
static JBoolean *FALSE_VALUE;

+ (instancetype)trueValue
{
	if (TRUE_VALUE == nil)
	{
		TRUE_VALUE = [[JBoolean alloc] initWithValue:true];
	}
	
	return TRUE_VALUE;
}

+ (instancetype)falseValue
{
	if (FALSE_VALUE == nil)
	{
		FALSE_VALUE = [[JBoolean alloc] initWithValue:false];
	}

	return FALSE_VALUE;
}

+ (instancetype)boolWithValue:(bool)value
{
	return value ? [JBoolean trueValue] : [JBoolean falseValue];
}

- (id)initWithValue:(bool)value
{
	self = [super init];
	
	if (self != nil)
	{
		_value = value;
	}
	
	return self;
}

- (bool)boolValue
{
	return _value;
}

- (SInt8)byteValue
{
	return _value ? 1 : 0;
}

- (SInt16)shortValue
{
	return _value ? 1 : 0;
}

- (SInt32)intValue
{
	return _value ? 1 : 0;
}

- (SInt64)longValue
{
	return _value ? 1 : 0;
}

- (float)floatValue
{
	return _value ? 1 : 0;
}

- (double)doubleValue
{
	return _value ? 1 : 0;
}

- (id)copyWithZone:(NSZone *)zone
{
	return [JBoolean boolWithValue:_value];
}

- (NSString *)description
{
	return _value ? @"true" : @"false";
}

- (NSString *)debugDescription
{
	return [self description];
}

+ (NSString *)serializingAlias
{
	return @"java.lang.Boolean";
}

+ (BOOL)primitiveType
{
	return YES;
}

@end
