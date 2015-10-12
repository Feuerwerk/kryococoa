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
#import "JBoolean.h"
#import "JByte.h"
#import "JCharacter.h"
#import "JShort.h"
#import "JInteger.h"
#import "JLong.h"
#import "JFloat.h"
#import "JDouble.h"
#import "JBooleanArray.h"
#import "JCharacterArray.h"
#import "JShortArray.h"
#import "JIntegerArray.h"
#import "JLongArray.h"
#import "JFloatArray.h"
#import "JDoubleArray.h"
#import "JObjectArray.h"
#import "KryoOutput.h"
#import "KryoInput.h"
#import "Serializer.h"
#import "CompatibleFieldSerializer.h"

@class Registration;
@class ObjectMap;
@protocol ReferenceResolver;
@protocol ClassResolver;


enum
{
	IS_NULL = 0,
	NOT_NULL = 1
};


@interface Kryo : NSObject
{
	NSMutableArray *_readReferenceIds;
	NSMutableDictionary *_classAliases;
	NSMutableDictionary *_reverseAliases;
	NSMutableArray *_defaultSerializers;
	id _readObject;
	Class _memoizedClass;
	Registration *_memoizedClassValue;
	int _depth;
	SInt32 _nextRegisterID;
	NSNull *_null;
}

extern const int REF;
extern const int NO_REF;

@property (nonatomic, strong) id<ReferenceResolver> referenceResolver;
@property (nonatomic, strong) id<ClassResolver> classResolver;
@property (nonatomic, assign) BOOL autoReset;
@property (nonatomic, assign) int maxDepth;
@property (nonatomic, strong) Class defaultSerializer;
@property (nonatomic, strong) ObjectMap *graphContext;

- (ObjectMap *)graphContext;
- (void)setClassResolver:(id<ClassResolver>)newClassResolver;
- (void)registerDefaultSerializerClass:(Class)serializerClass forClass:(Class)type;
- (void)registerDefaultSerializer:(id<Serializer>)serializer forClass:(Class)type;
- (void)registerAlias:(NSString *)alias forClass:(Class)type;
- (void)registerClass:(Class)type usingSerializer:(id<Serializer>)serializer;
- (void)registerClass:(Class)type andIdent:(NSInteger)ident;
- (void)registerClass:(Class)type usingSerializer:(id<Serializer>)serializer andIdent:(NSInteger)ident;

- (Registration *)getRegistration:(Class)type;
- (id<Serializer>)getDefaultSerializer:(Class)type;
- (id<Serializer>)getSerializer:(Class)type;
- (void)reference:(id)obj;
- (Class)classFromString:(NSString *)className;
- (NSString *)stringFromClass:(Class)type;
- (id)newInstance:(Class)type;
- (BOOL)isFinal:(Class)type;

- (void)writeObject:(id)obj to:(KryoOutput *)output;
- (void)writeObject:(id)obj to:(KryoOutput *)output usingSerializer:(id<Serializer>)serializer;
- (void)writeNullableObject:(id)obj withClass:(Class)type to:(KryoOutput *)output;
- (void)writeNullableObject:(id)obj to:(KryoOutput *)output usingSerializer:(id<Serializer>)serializer;
- (void)writeClassAndObject:(id)obj to:(KryoOutput *)output;
- (Registration *) writeClass:(Class)type ofObject:(id)obj to:(KryoOutput *)output;

- (id)readObject:(KryoInput *)input ofClass:(Class)type;
- (id)readObject:(KryoInput *)input ofClass:(Class)type usingSerializer:(id<Serializer>)serializer;
- (id)readNullableObject:(KryoInput *)input ofClass:(Class)type;
- (id)readNullableObject:(KryoInput *)input ofClass:(Class)type usingSerializer:(id<Serializer>)serializer;
- (id)readClassAndObject:(KryoInput *)input;
- (Registration *)readClass:(KryoInput *)input;

+ (Class)resolveArrayType:(Class)type;

@end
