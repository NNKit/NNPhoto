#
# Be sure to run `pod lib lint NNPhoto.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NNPhoto'
  s.version          = '0.1.0'
  s.summary          = 'A short description of NNPhoto.'
  s.homepage         = 'https://github.com/ws00801526/NNPhoto'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ws00801526' => '3057600441@qq.com' }
  s.source           = { :git => 'https://github.com/ws00801526/NNPhoto.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.subspec 'Browser' do |ss|
    ss.source_files = 'Browser/Classes/**/*'
    ss.dependency 'YYWebImage'
  end

  # s.resource_bundles = {
  #   'NNPhoto' => ['NNPhoto/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
