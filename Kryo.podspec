Pod::Spec.new do |spec|
  spec.name         = 'Kryo'
  spec.version      = '1.0.0'
  spec.summary      = 'A Serialization Framework for Cocoa'
  spec.homepage     = 'https://github.com/Feuerwerk/kryococoa'
  spec.license     = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Christian Fruth' => 'christian.fruth@boxx-it.de' }
  spec.source       = { :git => 'https://github.com/Feuerwerk/kryococoa.git', :tag => spec.version.to_s }
  spec.platform    = :ios, '6.0'
  spec.ios.deployment_target = '6.0'
  spec.source_files = 'Kryo/**/*.{h,m}'
  spec.public_header_files = 'Kryo/*.h'
  spec.requires_arc = true
end