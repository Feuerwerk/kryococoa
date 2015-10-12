// ======================================================================================
// Copyright (c) 2013, Christian Fruth, Boxx IT Solutions e.K.
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

#import "JDoubleArray.h"
#import "JDoubleArraySerializer.h"

@interface JDoubleArray ()

- (void)grow;

@end

@implementation JDoubleArray

+ (instancetype)arrayWithCapacity:(NSUInteger)capacity
{
	return [[JDoubleArray alloc] initWithCapacity:capacity];
}

+ (instancetype)arrayWithArray:(JDoubleArray *)array
{
	return [[JDoubleArray alloc] initWithArray:array];
}

- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		_capacity = 0;
		_count = 0;
		_value = NULL;
	}
	
	return self;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
	
	if (self != nil)
	{
		_count = 0;
		_capacity = capacity;
		_value = malloc(sizeof(double) * capacity);
	}
	
	return self;
}

- (id)initWithArray:(JDoubleArray *)array
{
	self = [super init];
	
	if (self != nil)
	{
		_count = array.count;
		_capacity = _count;
		
		const double *constValues = [array doubleValues];
		
		if (constValues == NULL)
		{
			_value = NULL;
		}
		else
		{
			_value = malloc(sizeof(double) * _capacity);
			memcpy(_value, constValues, sizeof(double) * _count);
		}
	}
	
	return self;
}

-(void)dealloc
{
	free(_value);
}

- (const double *)doubleValues
{
	return _value;
}

- (NSUInteger)count
{
	return _count;
}

- (void)setCount:(NSUInteger)count
{
	_capacity = count;
	
	if (_value == NULL)
	{
		_value = malloc(sizeof(double) * _capacity);
	}
	else
	{
		_value = realloc(_value, sizeof(double) * _capacity);
	}
	
	_count = count;
}

- (double)valueAtIndex:(NSUInteger)index
{
	if (index >= _count)
	{
		[NSException raise:NSRangeException format:@"Parameter index not in range"];
	}
	
	return _value[index];
}

- (void)replaceValueAtIndex:(NSUInteger)index withValue:(double)value
{
	if (index >= _count)
	{
		[NSException raise:NSRangeException format:@"Parameter index not in range"];
	}
	
	_value[index] = value;
}

- (void)addValue:(double)value
{
	[self grow];
	_value[_count] = value;
	++_count;
}

- (void)insertValue:(double)value atIndex:(NSUInteger)index
{
	if (index > _count)
	{
		index = _count;
	}
	
	[self grow];
	
	for (NSUInteger i = index; i < _count; ++i)
	{
		_value[i + 1] = _value[i];
	}
	
	_value[index] = value;
	++_count;
}

- (void)removeAllValues
{
	_count = 0;
}

- (void)removeLastValue
{
	if (_count == 0)
	{
		[NSException raise:NSRangeException format:@"Parameter index not in range"];
	}
	
	--_count;
}

- (void)removeValueAtIndex:(NSUInteger)index
{
	if (index >= _count)
	{
		[NSException raise:NSRangeException format:@"Parameter index not in range"];
	}
	
	for (NSUInteger i = index + 1; i < _count; ++i)
	{
		_value[i - 1] = _value[i];
	}
	
	--_count;
}

- (id)copyWithZone:(NSZone *)zone
{
	return [JDoubleArray arrayWithArray:self];
}

- (void)grow
{
	if (_count >= _capacity)
	{
		_capacity += 16;
		_value = realloc(_value, sizeof(double) * _capacity);
	}
}

+ (Class)defaultSerializer
{
	return [JDoubleArraySerializer class];
}

@end
