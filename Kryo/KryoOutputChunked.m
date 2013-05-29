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

#import "KryoOutputChunked.h"

@interface KryoOutputChunked ()

- (void)writeChunkSize;

@end

@implementation KryoOutputChunked

+ (instancetype)outputWithOutput:(KryoOutput *)output
{
	return [[KryoOutputChunked alloc] initWithOutput:output];
}

+ (instancetype)outputWithOutput:(KryoOutput *)output usingBufferSize:(NSUInteger)bufferSize
{
	return [[KryoOutputChunked alloc] initWithOutput:output usingBufferSize:bufferSize];
}

- (id)initWithOutput:(KryoOutput *)output
{
	return [super initWithStream:output usingBufferSize:2048];
}

- (id)initWithOutput:(KryoOutput *)output usingBufferSize:(NSUInteger)bufferSize
{
	return [super initWithStream:output usingBufferSize:bufferSize];
}

- (void)flush
{
	if (self.position > 0)
	{
		[self writeChunkSize];
	}

	[super flush];
}

- (void)endChunks
{
	[self flush]; // Flush any partial chunk.

	// Zero length chunk.
	uint8_t value = 0;
	[self.outputStream write:&value maxLength:1];
}

- (void)writeChunkSize
{
	NSUInteger size = self.position;
	NSUInteger length = 0;
	uint8_t value[8];

	if ((size & ~0x7F) == 0)
	{
		value[length++] = size;
	}
	else
	{
		value[length++] = (size & 0x7F) | 0x80;
		size >>= 7;

		if ((size & ~0x7F) == 0)
		{
			value[length++] = size;
		}
		else
		{
			value[length++] = (size & 0x7F) | 0x80;
			size >>= 7;

			if ((size & ~0x7F) == 0)
			{
				value[length++] = size;
			}
			else
			{
				value[length++] = (size & 0x7F) | 0x80;
				size >>= 7;
				
				if ((size & ~0x7F) == 0)
				{
					value[length++] = size;
				}
				else
				{
					value[length++] = (size & 0x7F) | 0x80;
					size >>= 7;
					value[length++] = size;
				}
			}
		}
	}
	
	[self.outputStream write:value maxLength:length];
}

@end
