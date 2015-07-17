kryococoa
=========

What is KryoCocoa?
===============================

KryoCocoa is an Objective-C Port of the great Kryo Serialization-Library for Java (http://code.google.com/p/kryo/)
It was designed to be compatible to Kryo and the basic Java Datatypes.


How can i use it?
===============================
    Kryo *kryo = [Kryo new];
    // ...
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:@"file.bin" append:NO];
    KryoOutput *output = [[Kryo alloc] initWithStream:outputStream];
    SomeClass *someObject = ...
    [kryo writeObject:someObject to:output];
    [output close];
    // ...
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:@"file.bin"];
    KryoInput *input = [[KryoInput alloc] initWithInput:inputStream];
    SomeClass *someObject = [kryo readObject:input ofClass:[SomeClass class]];
    [input close];

Serializers
===============================

KryoCocoa is a serialization framework. It doesn't enforce a schema or care what data is written or read.
This is left to the serializers themselves. Serializers are provided by default to read and write
data in various ways. If these don't meet particular needs, they can be replaced in part or in whole.
The provided serializers can read and write most objects but, if necessary, writing a new serializer
is easy. The Serializer protocol defines methods to go from objects to bytes and bytes to
objects.

*UIColorSerializer.h*

    #import <Foundation/Foundation.h>
    #import "../Serializer.h"
    
    @interface UIColorSerializer : NSObject<Serializer>
    
    @end

*UIColorSerializer.m*

    #import "UIColorSerializer.h"
    #import "Kryo.h"
    
    @implementation UIColorSerializer
    
    - (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
    {
    	UIColor *colorValue = (UIColor *)value;
    	CGFloat red, green, blue, alpha;
    
    	[colorValue getRed:&red green:&green blue:&blue alpha:&alpha];
    	SInt32 rgbValue = ((SInt32)(red * 255) << 16)
    	                | ((SInt32)(green * 255) << 8)
    	                | (SInt32)(blue * 255);

    	[output writeInt:rgbValue optimizePositive:YES];
    }
    
    - (id)read:(Kryo *)kryo withClass:(Class)type from:(KryoInput *)input
    {
    	SInt32 rgbValue = [input readIntOptimizePositive:YES];
    	return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0f
    	                       green:((rgbValue & 0xFF00) >> 8) / 255.0f
    	                        blue:((rgbValue & 0xFF) / 255.0f alpha:1.0];
    }
    
    @end

The *Serializer* protocol defines two methods which must be implemented. *write:value:to* writes
the object as bytes. *read:withClass:from* creates a new instance of the object and reads from the
input to populate it. The *Kryo* instance can be used to write and read nested objects.
If *Kryo* is used to read a nested object in *read:withClass:from* then *[kryo reference:]*
must first be called with the parent object if it is possible for the nested object to reference the
parent object. It is unnecessary to call *[kryo reference:]* if the nested objects can't possibly reference
the parent object, *Kryo* is not being used for nested objects, or references are not being used. If
nested objects can use the same serializer, the serializer must be reentrant. Code should not make use
of serializers directly, instead the *Kryo* read and write methods should be used. This allows *Kryo*
to orchestrate serialization and handle features such as references and nil objects.

By default, serializers do not need to handle the object being nil. The *KryoCocoa* framework will write a
byte as needed denoting nil or not nil. If a serializer wants to be more efficient and handle nils
itself, it can return *YES* from *acceptsNull*. This can also be used to avoid writing the nil
denoting byte when it is known that all instances of a type will never be nil.

Compatibility to Kryo (Java)
===============================
The *KryoCocoa* framework is currently based on *Kryo* v2.20 and it was attempted to be binary compatible
as much as possible. Since the language Objective-C doesn't provide features like packages, annotations
and generics you must provide these meta informations in another way.

The following Java-Types are directly supported by *KryoCocoa*.

| Java                | Objective-C           |
| ----------------------- | --------------------- |
| bool                    | bool (not *BOOL*, because *bool* is a builtin type which can be determined by reflection whereas *BOOL* is just a typedef to *char*) |
| byte                    | char                  |
| short                   | SInt16                |
| int                     | SInt32                |
| long                    | SInt64                |
| float                   | float                 |
| double                  | double                |
| char                    | unichar               |
| bool[]                  | JBooleanArray         |
| byte[]                  | NSData                |
| short[]                 | JShortArray           |
| int[]                   | JIntegerArray         |
| long[]                  | JLongArray            |
| float[]                 | JFloatArray           |
| double[]                | JDoubleArray          |
| char[]                  | JCharacterArray       |
| Object[]                | NSArray               |
| java.lang.Boolean       | JBoolean              |
| java.lang.Byte          | JByte                 |
| java.lang.Short         | JShort                |
| java.lang.Integer       | JInteger              |
| java.lang.Long          | JLong                 |
| java.lang.Float         | JFloat                |
| java.lang.Double        | JDouble               |
| java.lang.Character     | JCharacter            |
| java.lang.String        | NSString              |
| java.lang.StringBuilder | NSMutableString       |
| java.util.Date          | NSDate                |
| java.util.List          | NSArray               |
| java.util.Map           | NSDictionary          |
| java.util.Locale        | NSLocale              |

Handling Packages
--------------------------------
Since objective-c doesn't know the concept of namespaces or packages it is now nessesary to provide KryoCocoa with this information.
All you have to do is extending your class with the SerializationAnnotation protocol and providing the method *serializingAlias* which
must return the full qualified java class name (including the packages). This means that it is not important that the name of the
Objective-C class is the same as on Java side as long as you provide the java classname with *serializingAlias*.

*SampleBean.java*

	package test;

	public class SampleBean
	{
		private int key;
		private String name;

		public SampleBean()
		{
		}

		public int getKey()
		{
			return key;
		}

		public void setKey(int key)
		{
			this.key = key;
		}

		public String getName()
		{
			return name;
		}

		public void setName(String name)
		{
			this.name = name;
		}
	}
	
*SampleBean.m*

	#import "SampleBean.h"

	@implementation SampleBean

	+ (NSString *)serializingAlias
	{
		return @"test.SampleBean";
	}

*SampleBean.h*

    #import <Foundation/Foundation.h>
    #import "SerializationAnnotation.h"
    
    @interface SampleBean : NSObject<SerializationAnnotation>
    
    @property (nonatomic, copy) NSString *name;
    @property (nonatomic, assign) SInt32 key;
    
    @end

Handling Generics
--------------------------------

Given the following Java bean with the property *infoMap* of type *Map* with key-type *Integer*
and value-type *String*.

*OtherBean.java*

	package test;
	
	import java.util.List;
	import java.util.Map;

	public class OtherBean
	{
		private Float price;
		private Map<Integer, String> infoMap;
		private List<SampleBean> elements;

		public OtherBean()
		{
		}
		
		public Float getPrice()
		{
			return price;
		}
		
		public void setPrice(Float price)
		{
			this.price = price;
		}
		
		public Map<Integer, String> getInfoMap()
		{
			return infoMap;
		}
		
		public void setInfoMap(Map<Integer, String> infoMap)
		{
			this.infoMap = infoMap;
		}
		
		public List<SampleBean> getElements()
		{
			return elements;
		}
		
		public void setElements(List<SampleBean> elements)
		{
			this.elements = elements;
		}
	}
	
To notify KryoCocoa about the generic types on the objective-c side you must provide a static
method named *&lt;name of property&gt;Generics* returning a NSArray with the two Class-objects, *JInteger*
and *NSString* in this case.

*OtherBean.h*

	#import <Foundation/Foundation.h>
	#import "SerializationAnnotation.h"
	#import "JFloat.h"

	@interface OtherBean : NSObject<SerializationAnnotation>

	@property (nonatomic, strong) NSDictionary *infoMap;
	@property (nonatomic, strong) JFloat *price;
	@property (nonatomic, strong) NSArray *elements;

	+ (NSArray *)infoMapGenerics;

	@end

*OtherBean.m*

	#import "OtherBean.h"

	@implementation OtherBean

	+ (NSArray *)infoMapGenerics
	{
		return [NSArray arrayWithObjects:[JInteger class], [NSString class], nil];
	}

	+ (NSString *)serializingAlias
	{
		return @"test.OtherBean";
	}

	@end

Enumerations
--------------------------------

It it possible to use Enumerations as property types. But on Objective-C side this means that
you can't use the native C enums, the corresponding type must be implemented as a class.
There is a very fine small Enum-Implementation on the web ([gandreas Blog](http://www.gandreas.com/blog/files/gandenum.html))
which was included into KryoCocoa.

*SampleEnum.java*

	package test;

	public enum SampleEnum
	{
		Sun, Earth, Moon
	}

*SampleEnum.h*

	#import <Foundation/Foundation.h>
	#import "Enum.h"
	#import "SerializationAnnotation.h"

	@interface SampleEnum : Enum<SerializationAnnotation>

	+ (SampleEnum *)SUN;
	+ (SampleEnum *)EARTH;
	+ (SampleEnum *)MOON;

	@end

*SampleEnum.m*

	#import "SampleEnum.h"

	@implementation SampleEnum

	ENUM_ELEMENT(SUN, 0, nil)
	ENUM_ELEMENT(EARTH, 1, nil)
	ENUM_ELEMENT(MOON, 2, nil)

	+ (NSString *)serializingAlias
	{
		return @"test.SampleEnum";
	}

	@end

To create a KryoCocoa compatible Enumeration-Class all you have to do is creating a new class inherited by Enum
(optionally extended by SerializationAnnotation to annote the full Java classname) adding a static method for
each enumeration constant and add an ENUM_ELEMENT-entry for each constant in the m-file where the first parameter
of ENUM_ELEMENT is for the constant name, the second is the ordinal value which must correspond to the ordinal value
on java side and as third parameter any key/value-pair you want as extended information for your enum constant.
See gandreas blog for further details on this.
It is important that the constant names must be uppercase because only uppercase-names will be recognized currently.

Handling *final* classes
--------------------------------

Dealing with final classes is pretty easy. If you have to write your own serializer for a class just implement the
*isFinal*-Method. If you have a simple bean, which needs no special serializer, just add the protocol *FinalAnnotation* which needs no method to be implemented. The fact that your class implements the protocol is enought to mark this class as *final*.
	
Using TaggedFieldSerializer
--------------------------------

If you want to use *TaggedFieldSerializer* as default serializer your serializable classes
have to conform to protocol *TagAnnotation* which defines the static method *taggedProperties*
which returns a dictionary from property name to tag value. If a tag value is negative it is
treated as deprecated.

*TaggedBean.java*

	package test;
	
	import com.esotericsoftware.kryo.serializers;

	public class TaggedBean
	{
		@TaggedFieldSerializer.Tag(1)
		private int value;

		@TaggedFieldSerializer.Tag(2)
		private String name;

		@Deprecated
		@TaggedFieldSerializer.Tag(3)
		private int deprecatedField;

		public TaggedBean()
		{
		}
		
		public int getValue()
		{
			return value;
		}
		
		public void setValue(int value)
		{
			this.value = value;
		}
		
		public String getName()
		{
			return name;
		}
		
		public void setName(String name)
		{
			this.name = name;
		}
		
		public int getDeprecatedField()
		{
			return deprecatedField;
		}
		
		public void setDeprecatedField(int deprecatedField)
		{
			this.deprecatedField = deprecatedField;
		}
	}

*TaggedBean.h*

	#import <Foundation/Foundation.h>
	#import "SerializationAnnotation.h"
	#import "TagAnnotation.h"

	@interface TaggedBean : NSObject<SerializationAnnotation, TagAnnotation>

	@property (nonatomic, assign) SInt32 value;
	@property (nonatomic, strong) NSString *name;
	@property (nonatomic, strong) SInt32 deprecatedField;

	@end

*TaggedBean.m*

	#import "TaggedBean.h"

	@implementation TaggedBean

	+ (NSString *)serializingAlias
	{
		return @"test.TaggedBean";
	}
	
	+ (NSDictionary *)taggedProperties
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@1, @"value", @2, @"name", @-3, @"deprecatedField", nil];
	}

	@end

Limitations
--------------------------------

Currently there is no support for cloning objects. On java side you can annote a property with @NotNull
which is currently not supported.

The following Serializers are still not ported which is not a technical problem but lack of time:

- BlowfishSerializer
- DeflateSerialier
- BigDecimalSerializer
- ClassSerializer
- EnumSetSerializer
- CurrencySerializer
- StringBufferSerializer
- KryoSerializableSerializer
- TimeZoneSerializer
- CalendarSerializer
- TreeMapSerializer

*JavaSerializer* will probably never be ported because of the different serialization API in Cocoa
but maybe someone has a good idea for that.

Since NSDictionary require the key-type to conform to the protocol *NSCopying* not every key-type which is
possible under java can also be used under objective-c.
