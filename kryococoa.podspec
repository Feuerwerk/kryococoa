Pod::Spec.new do |spec|
  spec.name         = 'kryococoa'
  spec.version      = '1.0.1'
  spec.summary      = 'A Serialization Framework for Cocoa'
  spec.homepage     = 'https://github.com/Feuerwerk/kryococoa'
  spec.license     = { :type => 'MIT', :file => 'license_kryo.txt' }
  spec.author       = { 'Christian Fruth' => 'christian.fruth@boxx-it.de' }
  spec.source       = { :git => 'https://github.com/Feuerwerk/kryococoa.git', :tag => spec.version.to_s }
  spec.platform    = :ios
  spec.source_files = 'Kryo/**/*.{h,m}'
  spec.public_header_files = 'Kryo/Kryo.h', 'Kryo/SerializationAnnotation.h', 'Kryo/KryoInput.h', 'Kryo/KryoOutput.h', 'Kryo/Serializer.h', 'Kryo/Serializer/FieldSerializer.h', 'Kryo/Serializer/CompatibleFieldSerializer.h', 'Kryo/J*.h'
  spec.requires_arc = true
end