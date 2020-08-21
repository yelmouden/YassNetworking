Pod::Spec.new do |s|
  s.name = "YassNetworking"
  s.version = "1.0.1"
  s.license = "MIT"
  s.summary = "Networking layer"
  s.homepage = "https://github.com/yelmouden/YassNetworking"
  s.source = { :git => 'https://github.com/yelmouden/YassNetworking.git', :tag => "YassNetworking/1.0.1" }
  s.authors = { "yassin el mouden" => "yassin.elmouden@gmail.com" }
  s.ios.deployment_target = "13.5"
  s.module_name = "YassNetworking"
  s.swift_version = "5.2"

  s.subspec "Core" do |ss|
    ss.source_files = "Sources/**/*.swift"
    s.dependency "RxSwift"
  end
end
