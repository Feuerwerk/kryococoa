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

#import "KryoOutput.h"
#import "KryoException.h"


@interface KryoOutput()

- (BOOL)require:(NSUInteger)required;
- (NSUInteger)writeInternalInt:(UInt32)value optimizePositive:(BOOL)optimizePositive;
- (NSUInteger)writeInternalLong:(UInt64)value optimizePositive:(BOOL)optimizePositive;
- (void)writeUtf8Length:(NSUInteger)value;
- (void)writeAsciiSlow:(NSString *)value length:(NSUInteger)length;
- (void)writeStringSlow:(NSString *)value length:(NSUInteger)length beginningFrom:(NSUInteger)index;

@end

@implementation KryoOutput

- (id)initWithBufferSize:(NSUInteger)bufferSize untilMaximum:(NSUInteger)maximum
{
	self = [super init];
	
	if (self != nil)
	{
		_position = 0;
		_capacity = bufferSize;
		_maxCapacity = maximum;
		_buffer = (uint8_t *)malloc(sizeof(uint8_t) * _capacity);
	}
	
	return self;
}

- (id)initWithStream:(NSOutputStream *)outputStream
{
	self = [self initWithBufferSize:4096 untilMaximum:4096];
	
	if (self != nil)
	{
		self.outputStream = outputStream;
	}
	
	return self;
}

- (id)initWithStream:(NSOutputStream *)outputStream usingBufferSize:(NSUInteger)bufferSize
{
	self = [self initWithBufferSize:bufferSize untilMaximum:bufferSize];
	
	if (self != nil)
	{
		self.outputStream = outputStream;
	}
	
	return self;
}

- (void)dealloc
{
	if (_buffer != NULL)
	{
		free(_buffer);
		_buffer = NULL;
	}
}

- (NSUInteger)position
{
	return _position;
}

- (NSUInteger)capacity
{
	return _capacity;
}

- (const uint8_t *)buffer
{
	return _buffer;
}

- (NSData *)toData
{
	return [NSData dataWithBytes:_buffer length:_position];
}

- (void)flush
{
	if (_outputStream == nil)
	{
		return;
	}

	[_outputStream write:_buffer maxLength:_position];
	_position = 0;
}

- (void)close
{
	[self flush];
	
	if (_outputStream != nil)
	{
		[_outputStream close];
	}
}

- (void)clear
{
	_position = 0;
}

- (BOOL)hasSpaceAvailable
{
	return YES;
}

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len
{
	[self writeBytes:buffer withLength:len];
	return len;
}

- (void)writeByte:(char)value
{
	if (_position == _capacity)
	{
		[self require:1];
	}

	_buffer[_position++] = value;
}

- (void)writeBytes:(const void *)bytes withLength:(NSUInteger)length
{
	if (bytes == NULL)
	{
		[NSException raise:NSInvalidArgumentException format:@"bytes cannot be null."];
	}

	NSUInteger offset = 0;
	NSUInteger copyCount = MIN(_capacity - _position, length);
	uint8_t *localBytes = (uint8_t *)bytes;

	while (true)
	{
		memcpy(_buffer + _position, localBytes + offset, copyCount);
		_position += copyCount;
		length -= copyCount;

		if (length == 0)
		{
			return;
		}

		offset += copyCount;
		copyCount = MIN(_capacity, length);
		[self require:copyCount];
	}
}

- (void)writeShort:(SInt16)value
{
	[self require:2];
	*(SInt16 *)(_buffer + _position) = htons(value);
	_position += 2;
}

- (void)writeInt:(SInt32)value
{
	[self require:4];
	*(SInt32 *)(_buffer + _position) = htonl(value);
	_position += 4;
}

- (NSUInteger)writeInt:(SInt32)value optimizePositive:(BOOL)optimizePositive
{
	return [self writeInternalInt:*(UInt32 *)&value optimizePositive:optimizePositive];
}

- (NSUInteger)writeUInt:(UInt32)value
{
	return [self writeInternalInt:value optimizePositive:YES];
}

- (void)writeLong:(SInt64)value
{
	[self require:8];
	UInt64 unsignedValue = *(UInt64 *)&value;
	
	_buffer[_position++] = (uint8_t)(unsignedValue >> 56);
	_buffer[_position++] = (uint8_t)(unsignedValue >> 48);
	_buffer[_position++] = (uint8_t)(unsignedValue >> 40);
	_buffer[_position++] = (uint8_t)(unsignedValue >> 32);
	_buffer[_position++] = (uint8_t)(unsignedValue >> 24);
	_buffer[_position++] = (uint8_t)(unsignedValue >> 16);
	_buffer[_position++] = (uint8_t)(unsignedValue >> 8);
	_buffer[_position++] = (uint8_t)unsignedValue;
}

- (NSUInteger)writeLong:(SInt64)value optimizePositive:(BOOL)optimizePositive
{
	return [self writeInternalLong:*(UInt64 *)&value optimizePositive:optimizePositive];
}

- (NSUInteger)writeULong:(UInt64)value
{
	return [self writeInternalLong:value optimizePositive:YES];
}

- (void)writeFloat:(float)value
{
	[self writeInt:*(SInt32 *)&value];
}

- (NSUInteger)writeFloat:(float)value withPrecision:(float)precision optimizePositive:(BOOL)optimizePositive
{
	return [self writeInt:(SInt32)(value * precision) optimizePositive:optimizePositive];
}

- (void)writeDouble:(double)value
{
	[self writeLong:*(SInt64 *)&value];
}

- (NSUInteger)writeDouble:(double)value withPrecision:(double)precision optimizePositive:(BOOL)optimizePositive
{
	return [self writeLong:(SInt64)(value * precision) optimizePositive:optimizePositive];
}

- (void)writeBoolean:(bool)value
{
	if (_position == _capacity)
	{
		[self require:1];
	}
	
	_buffer[_position++] = value ? 1 : 0;
}

- (void)writeString:(NSString *)value
{
	if (value == nil)
	{
		[self writeByte:0x80]; // 0 means null, bit 8 means UTF8.
		return;
	}

	NSUInteger charCount = value.length;

	if (charCount == 0)
	{
		[self writeByte:1 | 0x80]; // 1 means empty string, bit 8 means UTF8.
		return;
	}

	// Detect ASCII.
	BOOL ascii = NO;

	if (charCount > 1 && charCount < 64)
	{
		ascii = YES;

		for (NSUInteger i = 0; i < charCount; i++)
		{
			unichar c = [value characterAtIndex:i];

			if (c > 127)
			{
				ascii = NO;
				break;
			}
		}
	}

	if (ascii == YES)
	{
		if (_capacity - _position < charCount)
		{
			[self writeAsciiSlow:value length:charCount];
		}
		else
		{
			[value getBytes:_buffer + _position maxLength:charCount usedLength:NULL encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, charCount) remainingRange:NULL];
			_position += charCount;
		}

		_buffer[_position - 1] |= 0x80;
	}
	else
	{
		[self writeUtf8Length: charCount + 1];

		NSUInteger charIndex = 0;

		if (_capacity - _position >= charCount)
		{
			// Try to write 8 bit chars.
			for (; charIndex < charCount; charIndex++)
			{
				unichar c = [value characterAtIndex:charIndex];

				if (c > 127)
				{
					break;
				}

				_buffer[_position++] = (uint8_t)c;
			}
		}

		if (charIndex < charCount)
		{
			[self writeStringSlow:value length:charCount beginningFrom:charIndex];
		}
	}
}

- (void)writeChar:(unichar)value
{
	[self require:2];
	*(unichar *)(_buffer + _position) = value;
	_position += 2;
}

- (BOOL)require:(NSUInteger)required
{
	if (_capacity - _position >= required)
	{
		return NO;
	}

	if (required > _maxCapacity)
	{
		[KryoException raiseWithFormat:@"Buffer overflow. Max capacity: %d, required: %d", _maxCapacity, required];
	}

	[self flush];

	while (_capacity - _position < required)
	{
		if (_capacity == _maxCapacity)
		{
			[KryoException raiseWithFormat:@"Buffer overflow. Available: %d, required: %d",_capacity - _position, required];
		}

		// Grow buffer.
		_capacity = MIN(_capacity * 2, _maxCapacity);
		_buffer = (uint8_t *)realloc(_buffer, sizeof(uint8_t) * _capacity);
	}

	return YES;
}

- (void)writeUtf8Length:(NSUInteger)value
{
	if (value >> 6 == 0)
	{
		[self require:1];
		_buffer[_position++] = (uint8_t)(value | 0x80); // Set bit 8.
	}
	else if (value >> 13 == 0)
	{
		[self require:2];
		_buffer[_position++] = (uint8_t)(value | 0x40 | 0x80); // Set bit 7 and 8.
		_buffer[_position++] = (uint8_t)(value >> 6);
	}
	else if (value >> 20 == 0)
	{
		[self require:3];
		_buffer[_position++] = (uint8_t)(value | 0x40 | 0x80); // Set bit 7 and 8.
		_buffer[_position++] = (uint8_t)((value >> 6) | 0x80); // Set bit 8.
		_buffer[_position++] = (uint8_t)(value >> 13);
	}
	else if (value >> 27 == 0)
	{
		[self require:4];
		_buffer[_position++] = (uint8_t)(value | 0x40 | 0x80); // Set bit 7 and 8.
		_buffer[_position++] = (uint8_t)((value >> 6) | 0x80); // Set bit 8.
		_buffer[_position++] = (uint8_t)((value >> 13) | 0x80); // Set bit 8.
		_buffer[_position++] = (uint8_t)(value >> 20);
	}
	else
	{
		[self require:5];
		_buffer[_position++] = (uint8_t)(value | 0x40 | 0x80); // Set bit 7 and 8.
		_buffer[_position++] = (uint8_t)((value >> 6) | 0x80); // Set bit 8.
		_buffer[_position++] = (uint8_t)((value >> 13) | 0x80); // Set bit 8.
		_buffer[_position++] = (uint8_t)((value >> 20) | 0x80); // Set bit 8.
		_buffer[_position++] = (uint8_t)(value >> 27);
	}
}

- (void)writeAsciiSlow:value length:(NSUInteger)length
{
	NSUInteger index = 0;
	NSUInteger charsToWrite = MIN(length, _capacity - _position);

	while (index < length)
	{
		[value getBytes:_buffer + _position maxLength:charsToWrite usedLength:NULL encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(index, charsToWrite) remainingRange:NULL];
		index += charsToWrite;
		_position += charsToWrite;
		charsToWrite = MIN(length - index, _capacity);
		[self require:charsToWrite];
	}
}

- (void)writeStringSlow:(NSString *)value length:(NSUInteger)length beginningFrom:(NSUInteger)index
{
	for (; index < length; index++)
	{
		if (_position == _capacity)
		{
			[self require:MIN(_capacity, length - index)];
		}
		
		unichar c = [value characterAtIndex:index];
		
		if (c <= 0x007F)
		{
			_buffer[_position++] = (uint8_t)c;
		}
		else if (c > 0x07FF)
		{
			_buffer[_position++] = (uint8_t)(0xE0 | (c >> 12 & 0x0F));
			[self require:2];
			_buffer[_position++] = (uint8_t)(0x80 | (c >> 6 & 0x3F));
			_buffer[_position++] = (uint8_t)(0x80 | (c & 0x3F));
		}
		else
		{
			_buffer[_position++] = (uint8_t)(0xC0 | (c >> 6 & 0x1F));
			[self require:1];
			_buffer[_position++] = (uint8_t)(0x80 | (c & 0x3F));
		}
	}
}

- (NSUInteger)writeInternalInt:(UInt32)value optimizePositive:(BOOL)optimizePositive
{
	if (!optimizePositive)
	{
		value = (value << 1) ^ (value >> 31);
	}
	
	if (value >> 7 == 0)
	{
		[self require:1];
		_buffer[_position++] = (uint8_t)value;
		return 1;
	}
	
	if (value >> 14 == 0)
	{
		[self require:2];
		_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 7);
		return 2;
	}
	
	if (value >> 21 == 0)
	{
		[self require:3];
		_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 7 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 14);
		return 3;
	}
	
	if (value >> 28 == 0)
	{
		[self require:4];
		_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 7 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 14 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 21);
		return 4;
	}

	[self require:5];
	_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 7 | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 14 | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 21 | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 28);
	return 5;
}

- (NSUInteger)writeInternalLong:(UInt64)value optimizePositive:(BOOL)optimizePositive
{
	if (!optimizePositive)
	{
		value = (value << 1) ^ (value >> 63);
	}
	
	if (value >> 7 == 0)
	{
		[self require:1];
		_buffer[_position++] = (uint8_t)value;
		return 1;
	}

	if (value >> 14 == 0)
	{
		[self require:2];
		_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 7);
		return 2;
	}
	
	if (value >> 21 == 0)
	{
		[self require:3];
		_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 7 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 14);
		return 3;
	}
	
	if (value >> 28 == 0)
	{
		[self require:4];
		_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 7 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 14 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 21);
		return 4;
	}
	
	if (value >> 35 == 0)
	{
		[self require:5];
		_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 7 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 14 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 21 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 28);
		return 5;
	}
	
	if (value >> 42 == 0)
	{
		[self require:6];
		_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 7 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 14 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 21 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 28 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 35);
		return 6;
	}
	
	if (value >> 49 == 0)
	{
		[self require:7];
		_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 7 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 14 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 21 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 28 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 35 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 42);
		return 7;
	}
	
	if (value >> 56 == 0)
	{
		[self require:8];
		_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 7 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 14 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 21 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 28 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 35 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 42 | 0x80);
		_buffer[_position++] = (uint8_t)(value >> 49);
		return 8;
	}
		
	[self require:9];
	_buffer[_position++] = (uint8_t)((value & 0x7F) | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 7 | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 14 | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 21 | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 28 | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 35 | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 42 | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 49 | 0x80);
	_buffer[_position++] = (uint8_t)(value >> 56);
	return 9;
}

@end

@interface KryoInputStream : NSInputStream
{
	NSUInteger _position;
	NSUInteger _capacity;
	const uint8_t *_buffer;
}

- (KryoInputStream *)initWithBuffer:(const uint8_t *)buffer ofLength:(NSUInteger)length;

@end

@implementation KryoInputStream

- (KryoInputStream *)initWithBuffer:(const uint8_t *)buffer ofLength:(NSUInteger)length
{
	self = [super init];
	
	if (self != nil)
	{
		_position = 0;
		_capacity = length;
		_buffer = buffer;
	}
	
	return self;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
	NSUInteger copyCount = MIN(_capacity - _position, len);
	memcpy(buffer, _buffer, copyCount);
	_position += copyCount;
	return copyCount;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
	*buffer = (uint8_t *)_buffer;
	*len = _capacity - _position;
	return YES;
}

- (BOOL)hasBytesAvailable
{
	return _position < _capacity;
}

@end

@implementation NSInputStream (KryoOutput)

+ (NSInputStream *)inputStreamWithOutput:(KryoOutput *)output
{
	return [[KryoInputStream alloc] initWithBuffer:output.buffer ofLength:output.capacity];
}

@end
