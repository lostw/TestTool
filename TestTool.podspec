Pod::Spec.new do |s|

  s.name = "TestTool"
  s.version = "1.0.0"
  s.summary = "private kit"

  s.description = <<-DESC
    private kit.
  DESC

  s.homepage = "http://101.69.143.198:8082/tz_frontend/ios/testtool"
  s.license = "MIT"
  s.author = { "Lostw" => "zzywil@163.com" }

  s.source = { :git => "http://101.69.143.198:8082/tz_frontend/ios/testtool.git", :tag => s.version }
  s.source_files = "Classes/**/*.{swift}"
  # s.exclude_files = "SwiftyRSA/SwiftyRSA+ObjC.swift"
  # s.framework = "Security"
  s.xcconfig = {'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'TestTool'}
  s.requires_arc = true
  
  s.swift_version = "5.0"
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.2"
  s.watchos.deployment_target = "2.2"

  s.dependency 'LostwKit'

end
