//
//  CollectionsSingletonMap.h
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializationAnnotation.h"

@interface CollectionsSingletonMap : NSDictionary<SerializationAnnotation>
{
	id _value;
	id<NSCopying> _key;
}

- (id)key;
- (id)value;

@end
