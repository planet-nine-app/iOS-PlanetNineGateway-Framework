Pod::Spec.new do |s|
  
  s.name             = 'PlanetNineGateway'
  s.version          = '0.0.37'
  s.summary          = 'The Planet Nine Gateway Framework'
 
  s.description      = <<-DESC
This contains everything you need to build one-time, one-time-ble, and ongoing gateways in the Planet Nine ecosystem.
                       DESC
 
  s.homepage         = 'https://github.com/planet-nine-app/iOS-PlanetNineGateway-Framework'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zach Babb' => 'zach@planetnine.app' }
  s.source           = { :git => 'https://github.com/planet-nine-app/iOS-PlanetNineGateway-Framework.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '13.0'
  s.source_files = 'PlanetNineGateway/*'
  s.source_files = 'PlanetNineGateway/**/*'
  s.exclude_files = 'PlanetNineGateway/*.plist'

  s.swift_version = '5.0'

  s.dependency 'BraintreeDropIn', '~> 8.0.0'
  s.dependency 'Valet', '~> 3.2.8'
  s.dependency 'secp256k1.swift', '~> 0.1.4'
  s.dependency 'CryptoSwift', '~> 1.3.0'
 
end
