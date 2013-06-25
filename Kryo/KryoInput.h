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

#import <Foundation/Foundation.h>


@interface KryoInput : NSInputStream
{
	@protected NSUInteger _position;
	@protected NSUInteger _capacity;
	@protected NSUInteger _limit;
	@protected uint8_t *_buffer;
	@protected BOOL _hasBufferOwnership;
	@protected NSInputStream *_inputStream;
}

- (id)initWithBufferSize:(NSUInteger)bufferSize;
- (id)initWithInput:(NSInputStream *)inputStream;
- (id)initWithInput:(NSInputStream *)inputStream usingBufferSize:(NSUInteger)bufferSize;
- (id)initWithBuffer:(const void *)buffer ofLength:(NSUInteger)length;

- (void)setBuffer:(NSData *)buffer;
- (void)setBuffer:(const void *)buffer ofLength:(NSUInteger)length;

- (NSInputStream *)inputStream;
- (void)setInputStream:(NSInputStream *)inputStream;

- (BOOL)hasBytesAvailable;
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len;
- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len;

- (void)rewind;
- (void)skip:(NSUInteger)count;

- (char)readByte;
- (void)readBytes:(void *)bytes withLength:(NSUInteger)length;
- (SInt16)readShort;
- (SInt32)readInt;
- (SInt32)readIntOptimizePositive:(BOOL)optimizePositive;
- (UInt32)readUInt;
- (SInt64)readLong;
- (SInt64)readLongOptimizePositive:(BOOL)optimizePositive;
- (UInt64)readULong;
- (float)readFloat;
- (float)readFloatWithPrecision:(float)precision optimizePositive:(BOOL)optimizePositive;
- (double)readDouble;
- (double)readDoubleWithPrecision:(double)precision optimizePositive:(BOOL)optimizePositive;
- (bool)readBoolean;
- (NSString *)readString;
- (unichar)readChar;

/* protected */
- (NSInteger)fill:(uint8_t *)buffer length:(NSUInteger)count;

@end
