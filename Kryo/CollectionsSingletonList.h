//
//  CollectionsSingletonList.h
//  Kryo
//
//  Created by Christian Fruth on 17.07.15.
//  Copyright (c) 2015 Boxx IT Solutions e.K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializationAnnotation.h"

@interface CollectionsSingletonList : NSArray<SerializationAnnotation>
{
	id _value;
}

@end
