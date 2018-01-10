#
# Be sure to run `pod lib lint NNPhoto.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NNPhoto'
  s.version          = '0.0.2'
  s.summary          = 'a photo browser and picker framework for iOS.'
  s.homepage         = 'https://github.com/NNKit/NNPhoto'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ws00801526' => '3057600441@qq.com' }
  s.source           = { :git => 'https://github.com/NNKit/NNPhoto.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.subspec 'Browser' do |ss|
    ss.source_files = 'Browser/Classes/**/*'
    ss.public_header_files = 'Browser/Classes/NNPhotoBrowser.h','Browser/Classes/NNPhotoMaskView.h','Browser/Classes/NNPhotoModel.h','Browser/Classes/NNPhotoBrowserController.h'
    ss.dependency 'YYWebImage'
  end
end
