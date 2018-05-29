#
# Be sure to run `pod lib lint NeosuranceSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NeosuranceSDK'
  s.version          = '1.3.12'
  s.summary          = 'Collects info from device sensors and from the hosting app'

  s.description      = <<-DESC
Neosurance SDK - Collects info from device sensors and from the hosting app - Exchanges info with the AI engines - Sends the push notification - Displays a landing page - Displays the list of the purchased policies
                       DESC

  s.homepage         = 'https://github.com/neosurance/ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Neosurance' => 'info@neosurance.eu' }
  s.source           = { :git => 'https://github.com/neosurance/ios-sdk', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'NeosuranceSDK/Classes/**/*'

  s.resource_bundles = {
    'NeosuranceSDK' => ['NeosuranceSDK/Assets/*.*']
  }
  s.dependency 'TapFramework'
end
