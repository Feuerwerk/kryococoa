Pod::Spec.new do |s|
  s.name     = 'Kryo'
  s.version  = '0.1.0'
  s.source_files = '{Kryo,Kryo}/*.{h,m}'
  s.preserve_paths = 'Kryo/Serializer'


  s.default_subspec = 'Serializer'

  s.subspec 'Serializer' do |core|
    core.source_files = '{Kryo/Serializer}/*.{h,m}'
  end

  s.requires_arc = true
  s.ios.deployment_target = '6.0'
  s.ios.frameworks = 'Foundation'
end
