kryococoa
=========

What is KryoCocoa?
----------------------

KryoCocoa is an Objective-C Port of the great Kryo Serialization-Library for Java (http://code.google.com/p/kryo/)
It was designed to be compatible to Kryo and the basic Java Datatypes.


How can i use it?
----------------------

```
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
```
