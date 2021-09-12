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
  s.tvos.deployment_target = '13.4'
  s.source_files = 'PlanetNineGateway/Common/**/*'
  s.ios.source_files = 'PlanetNineGateway/iOS/**/*'
  s.tvos.source_files = 'PlanetNineGateway/tvOS/*'
  s.exclude_files = 'PlanetNineGateway/*.plist'

  s.swift_version = '5.0'

  s.ios.dependency 'BraintreeDropIn', '~> 8.0.0'
  s.ios.dependency 'Valet', '~> 3.2.8'
  s.ios.dependency 'secp256k1.swift', '~> 0.1.4'
  s.ios.dependency 'CryptoSwift', '~> 1.4.1'
 
end
