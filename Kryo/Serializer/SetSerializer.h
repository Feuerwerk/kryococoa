//
//  SetSerializer.h
//  Kryo
//
//  Created by Christian Fruth on 26.07.13.
//  Copyright (c) 2013 Boxx IT Solutions e.K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Serializer.h"

@interface SetSerializer : NSObject<Serializer>
{
	Class _genericType;
}

@property (nonatomic, strong) Class elementClass;
@property (nonatomic, strong) id<Serializer> serializer;
@property (nonatomic, assign) BOOL elementsCanBeNull;

@end
