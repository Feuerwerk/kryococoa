//
//  LocaleSerializer.m
//  Stasis
//
//  Created by Christian Fruth on 15.05.15.
//  Copyright (c) 2015 Boxx IT Solutions GmbH. All rights reserved.
//

#import "LocaleSerializer.h"
#import "KryoInput.h"
#import "KryoOutput.h"

@implementation LocaleSerializer

- (BOOL)acceptsNull
{
	return YES;
}

- (BOOL)isFinal:(Class)type
{
	return YES;
}

- (void)write:(Kryo *)kryo value:(id)value to:(KryoOutput *)output
{
	NSLocale *locale = value;
	NSString *language = [locale objectForKey:NSLocaleLanguageCode];
	NSString *country = [locale objectForKey:NSLocaleCountryCode];
	NSString *variant = [locale objectForKey:NSLocaleVariantCode];
	
	if (language == nil)
	{
		language = @"";
	}
	
	if (country == nil)
	{
		country = @"";
	}
	
	if (variant == nil)
	{
		variant = @"";
	}
	
	[output writeString:language];
	[output writeString:country];
	[output writeString:variant];
}

- (id)read:(Kryo *)kryo withClass:(Class)type from:(KryoInput *)input
{
	NSString *language = [input readString];
	
	if (language.length == 0)
	{
		[NSException raise:NSInvalidArgumentException format:@"language cannot be nil."];
	}
	
	NSString *country = [input readString];
	NSString *variant = [input readString];
	NSMutableString *identifier = [NSMutableString new];
	
	[identifier appendString:language];
	
	if (country.length > 0)
	{
		[identifier appendString:@"_"];
		[identifier appendString:country];
	}
	
	if (variant.length > 0)
	{
		[identifier appendString:@"_"];
		[identifier appendString:variant];
	}
	
	return [NSLocale localeWithLocaleIdentifier: identifier];
}

- (NSString *)getClassName:(Class)type
{
	return @"java.util.Locale";
}

@end
