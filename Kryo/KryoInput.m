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

#import "KryoInput.h"
#import "KryoException.h"


@interface KryoInput()

- (void)clearBuffer;
- (NSUInteger)require:(NSUInteger)required;
- (UInt32)readUIntSlow;
- (UInt64)readULongSlow;
- (NSUInteger)readUtf8Length:(uint8_t)b;
- (NSUInteger)readUtf8LengthSlow:(uint8_t)b;
- (NSString *)readAscii;
- (NSString *)readAsciiSlow;
- (void)readUtf8:(NSUInteger)length intoBuffer:(unichar *)chars;
- (void)readUtf8Slow:(NSUInteger)length atIndex:(NSUInteger)index intoBuffer:(unichar *)chars;
- (NSInteger)optional:(NSUInteger)optional;
- (void)internalReadBytes:(void *)bytes withLength:(NSUInteger)length;

@end


@implementation KryoInput

- (id)initWithBufferSize:(NSUInteger)bufferSize
{
	self = [super init];
	
	if (self != nil)
	{
		_position = 0;
		_limit = 0;
		_capacity = bufferSize;
		_buffer = (uint8_t *)malloc(sizeof(uint8_t) * _capacity);
		_hasBufferOwnership = YES;
	}
	
	return self;
}

- (id)initWithInput:(NSInputStream *)inputStream
{
	return [self initWithInput:inputStream usingBufferSize:4096];
}

- (id)initWithInput:(NSInputStream *)inputStream usingBufferSize:(NSUInteger)bufferSize
{
	self = [self initWithBufferSize:bufferSize];
	
	if (self != nil)
	{
		[self setInputStream:inputStream];
	}
	
	return self;
}

- (id)initWithBuffer:(const void *)buffer ofLength:(NSUInteger)length
{
	self = [super init];
	
	if (self != nil)
	{
		[self setBuffer:buffer ofLength:length];
	}
	
	return self;
}

- (void)dealloc
{
	[self clearBuffer];
}

- (void)clearBuffer
{
	if ((_hasBufferOwnership == YES) && (_buffer != NULL))
	{
		free(_buffer);
	}
	
	_buffer = NULL;
}

- (void)setBuffer:(NSData *)buffer
{
	[self clearBuffer];

	_position = 0;
	_capacity = buffer.length;
	_limit = buffer.length;
	_buffer = (uint8_t *)[buffer bytes];
	_hasBufferOwnership = NO;
	_inputStream = nil;
}
	
- (void)setBuffer:(const void *)buffer ofLength:(NSUInteger)length
{
	[self clearBuffer];

	_position = 0;
	_capacity = length;
	_limit = length;
	_buffer = (uint8_t *)buffer;
	_hasBufferOwnership = NO;
	_inputStream = nil;
}

- (NSInputStream *)inputStream
{
	return _inputStream;
}

- (void)setInputStream:(NSInputStream *)inputStream
{
	_inputStream = inputStream;
	_limit = 0;
	[self rewind];
}

- (void)rewind
{
	_position = 0;
}

- (void)skip:(NSUInteger)count
{
	NSUInteger skipCount = MIN(_limit - _position, count);

	while (true)
	{
		_position += skipCount;
		count -= skipCount;

		if (count == 0)
		{
			break;
		}

		skipCount = MIN(count, _capacity);
		[self require:skipCount];
	}
}

- (BOOL)hasBytesAvailable
{
	return YES;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
	if (buffer == NULL)
	{
		[NSException raise:NSInvalidArgumentException format:@"buffer cannot be null."];
	}

	NSUInteger startingCount = len;
	NSUInteger copyCount = MIN(_limit - _position, len);
	
	while (true)
	{
		memcpy(buffer, _buffer + _position, copyCount);
		_position += copyCount;
		len -= copyCount;

		if (len == 0)
		{
			break;
		}

		buffer = (uint8_t *)buffer + copyCount;
		copyCount = [self  optional:len];
		
		if (copyCount == -1)
		{
			// End of data.
			if (startingCount == len)
			{
				return -1;
			}

			break;
		}

		if (_position == _limit)
		{
			break;
		}
	}

	return startingCount - len;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
	*buffer = _buffer;
	*len = _limit - _position;
	return YES;
}

- (void)close
{
	if (_inputStream != nil)
	{
		[_inputStream close];
	}
}

- (char)readByte
{
	[self require:1];
	return _buffer[_position++];
}

- (void)readBytes:(void *)bytes withLength:(NSUInteger)length
{
	if (bytes == NULL)
	{
		[NSException raise:NSInvalidArgumentException format:@"bytes cannot be null."];
	}

	[self internalReadBytes:bytes withLength:length];
}

- (SInt16)readShort
{
	[self require:2];
	SInt16 value = ntohs(*(SInt16 *)(_buffer + _position));
	_position += 2;
	return value;
}

- (SInt32)readInt
{
	[self require:4];
	SInt32 value = ntohl(*(SInt32 *)(_buffer + _position));
	_position += 4;
	return value;
}

- (SInt32)readIntOptimizePositive:(BOOL)optimizePositive
{
	UInt32 result = [self readUInt];

	if (!optimizePositive)
	{
		result = ((result >> 1) ^ -(result & 1));
	}
	
	return *(SInt32 *)&result;
}

- (UInt32)readUInt
{
	if ([self require:1] < 5)
	{
		return [self readUIntSlow];
	}

	uint8_t b = _buffer[_position++];
	UInt32 result = b & 0x7F;

	if ((b & 0x80) != 0)
	{
		b = _buffer[_position++];
		result |= (b & 0x7F) << 7;

		if ((b & 0x80) != 0)
		{
			b = _buffer[_position++];
			result |= (b & 0x7F) << 14;

			if ((b & 0x80) != 0)
			{
				b = _buffer[_position++];
				result |= (b & 0x7F) << 21;

				if ((b & 0x80) != 0)
				{
					b = _buffer[_position++];
					result |= (b & 0x7F) << 28;
				}
			}
		}
	}

	return result;
}

- (SInt64)readLong
{
	[self require:8];
	NSUInteger position = _position;
	_position += 8;
	return (SInt64)_buffer[position + 0] << 56 //
	| (SInt64)(_buffer[position + 1] & 0xFF) << 48 //
	| (SInt64)(_buffer[position + 2] & 0xFF) << 40 //
	| (SInt64)(_buffer[position + 3] & 0xFF) << 32 //
	| (SInt64)(_buffer[position + 4] & 0xFF) << 24 //
	| (_buffer[position + 5] & 0xFF) << 16 //
	| (_buffer[position + 6] & 0xFF) << 8 //
	| (_buffer[position + 7] & 0xFF);
}

- (SInt64)readLongOptimizePositive:(BOOL)optimizePositive
{
	UInt64 result = [self readULong];
	
	if (!optimizePositive)
	{
		result = (result >> 1) ^ -(result & 1);
	}

	return *(SInt64 *)&result;
}

- (UInt64)readULong
{
	if ([self require:1] < 9)
	{
		return [self readULongSlow];
	}
	
	uint8_t b = _buffer[_position++];
	UInt64 result = b & 0x7F;
	
	if ((b & 0x80) != 0)
	{
		b = _buffer[_position++];
		result |= (b & 0x7F) << 7;
		
		if ((b & 0x80) != 0)
		{
			b = _buffer[_position++];
			result |= (b & 0x7F) << 14;
			
			if ((b & 0x80) != 0)
			{
				b = _buffer[_position++];
				result |= (b & 0x7F) << 21;
				
				if ((b & 0x80) != 0)
				{
					b = _buffer[_position++];
					result |= (SInt64)(b & 0x7F) << 28;
					
					if ((b & 0x80) != 0)
					{
						b = _buffer[_position++];
						result |= (SInt64)(b & 0x7F) << 35;
						
						if ((b & 0x80) != 0)
						{
							b = _buffer[_position++];
							result |= (SInt64)(b & 0x7F) << 42;
							
							if ((b & 0x80) != 0)
							{
								b = _buffer[_position++];
								result |= (SInt64)(b & 0x7F) << 49;
								
								if ((b & 0x80) != 0)
								{
									b = _buffer[_position++];
									result |= (SInt64)b << 56;
								}
							}
						}
					}
				}
			}
		}
	}
	
	return result;
}


- (float)readFloat
{
	SInt32 value = [self readInt];
	return *(float *)&value;
}

- (float)readFloatWithPrecision:(float)precision optimizePositive:(BOOL)optimizePositive
{
	SInt32 value = [self readIntOptimizePositive:optimizePositive];
	return value / precision;
}

- (double)readDouble
{
	SInt64 value = [self readLong];
	return *(double *)&value;
}

- (double)readDoubleWithPrecision:(double)precision optimizePositive:(BOOL)optimizePositive
{
	SInt64 value = [self readLongOptimizePositive:optimizePositive];
	return value / precision;
}

- (bool)readBoolean
{
	[self require:1];
	return _buffer[_position++] == 1;
}

- (NSString *)readString
{
	NSUInteger available = [self require:1];
	uint8_t b = _buffer[_position++];

	if ((b & 0x80) == 0)
	{
		return [self readAscii]; // ASCII.
	}

	// Null, empty, or UTF8.
	NSUInteger charCount = (available >= 5) ? [self readUtf8Length:b] : [self readUtf8LengthSlow:b];

	switch (charCount)
	{
		case 0:
			return nil;

		case 1:
			return @"";
	}

	charCount--;
	
	// Reserve memory for char buffer
	unichar *chars = malloc(charCount * sizeof(unichar));
	
	@try
	{
		[self readUtf8:charCount intoBuffer:chars];
		
		NSString *string = [[NSString alloc] initWithCharactersNoCopy:chars length:charCount freeWhenDone:YES];
		chars = NULL;
		
		return string;
	}
	@finally
	{
		if (chars != NULL)
		{
			free(chars);
		}
	}
}

- (unichar)readChar
{
	[self require:2];
	unichar value = *(unichar *)(_buffer + _position);
	_position += 2;
	return value;
}

- (NSUInteger)readUtf8Length:(uint8_t)b;
{
	NSUInteger result = b & 0x3F; // Mask all but first 6 bits.

	if ((b & 0x40) != 0) // Bit 7 means another byte, bit 8 means UTF8.
	{
		b = _buffer[_position++];
		result |= (b & 0x7F) << 6;

		if ((b & 0x80) != 0)
		{
			b = _buffer[_position++];
			result |= (b & 0x7F) << 13;

			if ((b & 0x80) != 0)
			{
				b = _buffer[_position++];
				result |= (b & 0x7F) << 20;

				if ((b & 0x80) != 0)
				{
					b = _buffer[_position++];
					result |= (b & 0x7F) << 27;
				}
			}
		}
	}
	
	return result;
}

- (NSUInteger)readUtf8LengthSlow:(uint8_t)b
{
	NSUInteger result = b & 0x3F; // Mask all but first 6 bits.

	if ((b & 0x40) != 0) // Bit 7 means another byte, bit 8 means UTF8.
	{
		[self require:1];
		b = _buffer[_position++];
		result |= (b & 0x7F) << 6;

		if ((b & 0x80) != 0)
		{
			[self require:1];
			b = _buffer[_position++];
			result |= (b & 0x7F) << 13;

			if ((b & 0x80) != 0)
			{
				[self require:1];
				b = _buffer[_position++];
				result |= (b & 0x7F) << 20;

				if ((b & 0x80) != 0)
				{
					[self require:1];
					b = _buffer[_position++];
					result |= (b & 0x7F) << 27;
				}
			}
		}
	}

	return result;
}

- (NSString *)readAscii
{
	NSUInteger end = _position;
	NSUInteger start = end - 1;
	uint8_t b;

	do
	{
		if (end == _limit)
		{
			return [self readAsciiSlow];
		}

		b = _buffer[end++];
	}
	while ((b & 0x80) == 0);

	_buffer[end - 1] &= 0x7F; // Mask end of ascii bit.
	NSString *value = [[NSString alloc] initWithBytes:_buffer + start length:end - start encoding:NSASCIIStringEncoding];
	_buffer[end - 1] |= 0x80;
	_position = end;

	return value;
}

- (NSString *)readAsciiSlow
{
	_position--; // Re-read the first byte.
	// Copy chars currently in buffer.
	NSUInteger charCount = _limit - _position;
	NSUInteger charSize = MAX(charCount * 2, 32);
	unichar *chars = malloc(charSize * sizeof(unichar));
	
	for (NSUInteger i = _position, j = 0; i < _limit; ++i, ++j)
	{
		chars[j] = _buffer[i];
	}

	_position = _limit;
	
	// Copy additional chars one by one.
	while (true)
	{
		[self require:1];
		uint8_t b = _buffer[_position++];

		if (charCount == charSize)
		{
			charSize = charCount * 2;
			chars = realloc(chars, charSize);
		}

		if ((b & 0x80) == 0x80)
		{
			chars[charCount++] = b & 0x7F;
			break;
		}
		
		chars[charCount++] = b;
	}

	return [[NSString alloc] initWithCharactersNoCopy:chars length:charCount freeWhenDone:YES];
}

- (void)readUtf8:(NSUInteger)length intoBuffer:(unichar *)chars
{
	// Try to read 7 bit ASCII chars.
	NSUInteger available = [self require:1];
	NSUInteger charIndex = 0;
	NSUInteger count = MIN(available, length);
	NSUInteger position = _position;

	while (charIndex < count)
	{
		char b = _buffer[position++];

		if (b < 0)
		{
			position--;
			break;
		}

		chars[charIndex++] = b;
	}

	_position = position;
	
	// If buffer didn't hold all chars or any were not ASCII, use slow path for remainder.
	if (charIndex < length)
	{
		[self readUtf8Slow:length atIndex:charIndex intoBuffer:chars];
	}
}

- (void)readUtf8Slow:(NSUInteger)length atIndex:(NSUInteger)index intoBuffer:(unichar *)chars
{
	while (index < length)
	{
		if (_position == _limit)
		{
			[self require:1];
		}

		unichar b = _buffer[_position++] & 0xFF;

		switch (b >> 4)
		{
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
				chars[index] = b;
				break;

			case 12:
			case 13:
				if (_position == _limit)
				{
					[self require:1];
				}

				chars[index] = ((b & 0x1F) << 6 | (_buffer[_position++] & 0x3F));
				break;

			case 14:
				[self require:2];
				chars[index] = ((b & 0x0F) << 12 | (_buffer[_position++] & 0x3F) << 6 | (_buffer[_position++] & 0x3F));
				break;
		}

		index++;
	}
}

- (UInt32)readUIntSlow
{
	// The buffer is guaranteed to have at least 1 byte.
	uint8_t b = _buffer[_position++];
	UInt32 result = b & 0x7F;

	if ((b & 0x80) != 0)
	{
		[self require:1];
		b = _buffer[_position++];
		result |= (b & 0x7F) << 7;

		if ((b & 0x80) != 0)
		{
			[self require:1];
			b = _buffer[_position++];
			result |= (b & 0x7F) << 14;

			if ((b & 0x80) != 0)
			{
				[self require:1];
				b = _buffer[_position++];
				result |= (b & 0x7F) << 21;

				if ((b & 0x80) != 0)
				{
					[self require:1];
					b = _buffer[_position++];
					result |= (b & 0x7F) << 28;
				}
			}
		}
	}
	
	return result;
}

- (UInt64)readULongSlow
{
	// The buffer is guaranteed to have at least 1 byte.
	uint8_t b = _buffer[_position++];
	UInt64 result = b & 0x7F;

	if ((b & 0x80) != 0)
	{
		[self require:1];
		b = _buffer[_position++];
		result |= (b & 0x7F) << 7;

		if ((b & 0x80) != 0)
		{
			[self require:1];
			b = _buffer[_position++];
			result |= (b & 0x7F) << 14;

			if ((b & 0x80) != 0)
			{
				[self require:1];
				b = _buffer[_position++];
				result |= (b & 0x7F) << 21;

				if ((b & 0x80) != 0)
				{
					[self require:1];
					b = _buffer[_position++];
					result |= (UInt64)(b & 0x7F) << 28;

					if ((b & 0x80) != 0)
					{
						[self require:1];
						b = _buffer[_position++];
						result |= (UInt64)(b & 0x7F) << 35;

						if ((b & 0x80) != 0)
						{
							[self require:1];
							b = _buffer[_position++];
							result |= (UInt64)(b & 0x7F) << 42;

							if ((b & 0x80) != 0)
							{
								[self require:1];
								b = _buffer[_position++];
								result |= (UInt64)(b & 0x7F) << 49;

								if ((b & 0x80) != 0)
								{
									[self require:1];
									b = _buffer[_position++];
									result |= (UInt64)b << 56;
								}
							}
						}
					}
				}
			}
		}
	}

	return result;
}

- (NSUInteger)require:(NSUInteger)required
{
	NSUInteger remaining = _limit - _position;

	if (remaining >= required)
	{
		return remaining;	
	}

	if (required > _capacity)
	{
		[KryoException raiseWithFormat:@"Buffer too small: capacity: %d, required: %d", _capacity, required];
	}
	
	// Compact.
	memcpy(_buffer, _buffer + _position, remaining);
	_position = 0;
	
	while (true)
	{
		NSInteger count = [self fill:_buffer + remaining length:_capacity - remaining];
		
		if (count == -1)
		{
			if (remaining >= required)
			{
				break;
			}

			[KryoException raise:@"Buffer underflow."];
		}

		remaining += count;

		if (remaining >= required)
		{
			break; // Enough has been read.
		}
	}

	_limit = remaining;
	return remaining;
}

- (NSInteger)optional:(NSUInteger)optional
{
	NSUInteger remaining = _limit - _position;

	if (remaining >= optional)
	{
		return optional;	
	}

	optional = MIN(optional, _capacity);
	
	// Compact.
	memcpy(_buffer, _buffer + _position, remaining);
	_position = 0;
	
	while (true)
	{
		NSInteger count = [self fill:_buffer + remaining length:_capacity - remaining];

		if (count == -1)
		{
			break;
		}

		remaining += count;
		if (remaining >= optional)
		{
			break; // Enough has been read.
		}
	}
	
	_limit = remaining;
	return (remaining == 0) ? -1 : MIN(remaining, optional);
}

- (NSInteger)fill:(uint8_t *)buffer length:(NSUInteger)count
{
	if (_inputStream == nil)
	{
		return -1;
	}

	return [_inputStream read:buffer maxLength:count];
}

- (void)internalReadBytes:(void *)bytes withLength:(NSUInteger)length
{
	NSUInteger copyCount = MIN(_limit - _position, length);
	
	while (true)
	{
		memcpy(bytes, _buffer + _position, copyCount);
		_position += copyCount;
		length -= copyCount;
		
		if (length == 0)
		{
			break;
		}
		
		bytes = (uint8_t *)bytes + copyCount;
		copyCount = MIN(length, _capacity);
		[self require:copyCount];
	}
}

@end
