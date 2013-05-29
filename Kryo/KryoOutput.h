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

#import <Foundation/Foundation.h>


@interface KryoOutput : NSOutputStream
{
	@protected NSUInteger _position;
	@protected NSUInteger _capacity;
	@protected NSUInteger _maxCapacity;
	@protected uint8_t *_buffer;
}

@property (nonatomic, strong) NSOutputStream *outputStream;

- (id)initWithBufferSize:(NSUInteger)bufferSize untilMaximum:(NSUInteger)maximum;
- (id)initWithStream:(NSOutputStream *)outputStream;
- (id)initWithStream:(NSOutputStream *)outputStream usingBufferSize:(NSUInteger)bufferSize;

- (NSUInteger)position;
- (NSUInteger)capacity;
- (const uint8_t *)buffer;
- (NSData *)toData;

- (void)flush;
- (void)clear;

- (BOOL)hasSpaceAvailable;
- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len;

- (void)writeByte:(char)value;
- (void)writeBytes:(const void *)bytes withLength:(NSUInteger)length;
- (void)writeShort:(SInt16)value;
- (void)writeInt:(SInt32)value;
- (NSUInteger)writeInt:(SInt32)value optimizePositive:(BOOL)optimizePositive;
- (NSUInteger)writeUInt:(UInt32)value;
- (void)writeLong:(SInt64)value;
- (NSUInteger)writeLong:(SInt64)value optimizePositive:(BOOL)optimizePositive;
- (NSUInteger)writeULong:(UInt64)value;
- (void)writeFloat:(float)value;
- (NSUInteger)writeFloat:(float)value withPrecision:(float)precision optimizePositive:(BOOL)optimizePositive;
- (void)writeDouble:(double)value;
- (NSUInteger)writeDouble:(double)value withPrecision:(double)precision optimizePositive:(BOOL)optimizePositive;
- (void)writeBoolean:(bool)value;
- (void)writeString:(NSString *)value;
- (void)writeChar:(unichar)value;

@end

@interface NSInputStream (KryoOutput)

+ (NSInputStream *)inputStreamWithOutput:(KryoOutput *)output;

@end
