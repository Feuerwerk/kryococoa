Pod::Spec.new do |s|
  s.name     = 'Kryo'
  s.version  = '0.1.0'
  s.source_files = '{Kryo,Kryo/Serializer}/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '6.0'
  s.ios.frameworks = 'Foundation'
end
