Pod::Spec.new do |s|
  s.name = "Networking"
  s.version = "1.0.0"
  s.license = "MIT"
  s.summary = "Networking layer"
  s.homepage = "https://github.com/yelmouden/networking"
  s.source = { :git => 'git@github.com:yelmouden/Networking.git', :tag => "Networking/{s.version}" }
  s.authors = { "yassin el mouden" => "yassin.elmouden@gmail.com" }
  s.ios.deployment_target = "13.5"
  s.module_name = "Networking"
  s.swift_version = "5.0"

  s.subspec "Core" do |ss|
    ss.source_files = "Sources/**/*.swift"
    s.dependency "RxSwift"
  end
end
