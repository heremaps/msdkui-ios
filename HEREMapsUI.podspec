Pod::Spec.new do |s|
    s.name                  = 'HEREMapsUI'
    s.module_name           = 'MSDKUI'
    s.version               = '2.1.8'
    s.summary               = 'HEREMapsUI (MSDKUI) provides ready-to-use UI components for the HERE Mobile SDK for iOS.'
    s.description           = 'HEREMapsUI (MSDKUI) aims to make life easier for the iOS developers using the HERE Mobile SDK for iOS. It provides ready-to-use UI components with strong customization support. Plus, it supports accessibility and localization.'
    s.homepage              = 'https://github.com/heremaps/msdkui-ios'
    s.license               = { :type => 'Apache-2.0', :file => 'LICENSE' }
    s.author                = { 'HERE Europe B.V.' => '' }
    s.source                = { :git => 'https://github.com/heremaps/msdkui-ios.git', :tag => s.version.to_s }
    s.ios.deployment_target = '12.0'
    s.swift_version         = '5.3.3'
    s.source_files          = 'MSDKUI/Classes/**/*'
    s.resource_bundles      = {
        'MSDKUI' => ['MSDKUI/Assets/*.png', 'MSDKUI/Assets/*.xib', 'MSDKUI/Assets/*.lproj']
    }
    s.dependency            'HEREMaps', '3.18.2'
    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
