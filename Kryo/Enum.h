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

#import <Foundation/Foundation.h>

@interface Enum : NSObject<NSCopying, NSCoding>
{
	NSString *_name;
	int _ordinal;
	NSDictionary *_properties;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int ordinal;

+ (instancetype)valueOfName:(NSString *)name;
+ (instancetype)valueOfOrdinal:(int)ordinal;
+ (NSArray *)values;

// this should only be called from with the enum declaration methods
- (id)initWithName:(NSString *)name ordinal:(int)ordinal properties:(NSDictionary *)properties;
+ (void)invalidateEnumCache; // if you've done dynamic code loading and added an enum through a category, call this for each enum class modified

@end

#define ENUM_ELEMENT(ename, evalue, eproperties...) \
+ (id) ename { \
static id retval = nil; \
if (retval == nil) { \
retval = [[self alloc] initWithName: @ #ename ordinal: evalue properties: [NSDictionary dictionaryWithObjectsAndKeys: eproperties, nil]]; \
}\
return retval;\
}
