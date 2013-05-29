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

#import "KryoInputChunked.h"
#import "KryoException.h"

@interface KryoInputChunked ()

- (void)readChunkSize;

@end

@implementation KryoInputChunked

+ (instancetype)inputWithInput:(KryoInput *)input
{
	return [[KryoInputChunked alloc] initWithInput:input];
}

+ (instancetype)inputWithInput:(KryoInput *)input usingBufferSize:(NSUInteger)bufferSize
{
	return [[KryoInputChunked alloc] initWithInput:input usingBufferSize:bufferSize];
}

- (id)initWithInput:(KryoInput *)input
{
	return [self initWithInput:input usingBufferSize:2048];
}

- (id)initWithInput:(KryoInput *)input usingBufferSize:(NSUInteger)bufferSize
{
	return [super initWithInput:input usingBufferSize:bufferSize];
}

- (void)setBuffer:(NSData *)buffer
{
	[super setBuffer:buffer];
	_chunkSize = -1;
}

- (void)setBuffer:(const void *)buffer ofLength:(NSUInteger)length
{
	[super setBuffer:buffer ofLength:length];
	_chunkSize = -1;
}

- (void)setInputStream:(NSInputStream *)inputStream
{
	[super setInputStream:inputStream];
	_chunkSize = -1;
}

- (void)rewind
{
	[super rewind];
	_chunkSize = -1;
}

- (void)nextChunks
{
	if (_chunkSize == -1)
	{
		[self readChunkSize]; // No current chunk, expect a new chunk.
	}

	while (_chunkSize > 0)
	{
		[self skip:_chunkSize];
	}

	_chunkSize = -1;
}

- (void)readChunkSize
{
	NSInputStream *inputStream = self.inputStream;

	for (int offset = 0, result = 0; offset < 32; offset += 7)
	{
		uint8_t b;

		if ([inputStream read:&b maxLength:1] < 1)
		{
			[KryoException raise:@"Buffer underflow."];
		}

		result |= (b & 0x7F) << offset;

		if ((b & 0x80) == 0)
		{
			_chunkSize = result;
			return;
		}
	}

	[KryoException raise:@"Malformed integer."];
}

- (NSInteger)fill:(uint8_t *)buffer length:(NSUInteger)count
{
	if (_chunkSize == -1)
	{
		// No current chunk, expect a new chunk.
		[self readChunkSize];
	}
	else if (_chunkSize == 0)
	{
		// End of chunks.
		return -1;
	}

	NSInteger actual = [super fill:buffer length:MIN(_chunkSize, count)];
	_chunkSize -= actual;

	if (_chunkSize == 0)
	{
		[self readChunkSize]; // Read next chunk size.
	}

	return actual;
}

@end
