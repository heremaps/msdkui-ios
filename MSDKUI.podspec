#
# Be sure to run `pod lib lint MSDKUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name                  = 'MSDKUI'
    s.version               = '1.4.0'
    s.summary               = 'MSDKUI provides ready-to-use UI components for the HERE Technologies\' NMAKit framework.'
    s.description           = 'MSDKUI aims to make life easier for the iOS developers using the HERE Technologies\' NMAKit framework. It provides ready-to-use UI components with strong customization support. Plus, it supports accessibility and localization.'
    s.homepage              = 'https://github.com/heremaps/msdkui-ios'
    s.license               = { :type => 'Apache-2.0', :file => 'LICENSE' }
    s.author                = { 'HERE Technologies' => 'info@here.com' }
    s.source                = { :git => 'To be set', :tag => s.version.to_s }
    s.ios.deployment_target = '10.0'
    s.source_files          = 'MSDKUI/Classes/**/*'
    s.resource_bundles      = {
        'MSDKUI' => ['MSDKUI/Assets/*.png', 'MSDKUI/Assets/*.xib', 'MSDKUI/Assets/*.lproj']
    }
    s.dependency            'HEREMaps', '3.8'
end
