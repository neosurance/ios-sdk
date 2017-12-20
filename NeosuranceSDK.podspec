#
# Be sure to run `pod lib lint NeosuranceSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NeosuranceSDK'
  s.version          = '0.1.1'
  s.summary          = 'Collects info from device sensors and from the hosting app'

  s.description      = <<-DESC
Neosurance SDK - Collects info from device sensors and from the hosting app - Exchanges info with the AI engines - Sends the push notification - Displays a landing page - Displays the list of the purchased policies
                       DESC

  s.homepage         = 'https://github.com/clickntap/NeosuranceSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tonino Mendicino' => 'tonino@clickntap.com' }
  s.source           = { :git => 'https://github.com/clickntap/NeosuranceSDK', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'NeosuranceSDK/Classes/**/*'

  s.resource_bundles = {
    'NeosuranceSDK' => ['NeosuranceSDK/Assets/*.*']
  }
  s.dependency 'TapFramework'
end
