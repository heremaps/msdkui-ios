platform :ios, '10.0'

use_frameworks!

def project_pods
    pod 'HEREMapsUI', :path => './'
    pod 'SwiftLint', '0.29.1'
end

target 'MSDKUI_Demo' do
    project_pods

    target 'MSDKUI_Tests' do
        inherit! :search_paths
        pod 'OCMock', '3.4.1'
    end

    target 'MSDKUI_Demo_Tests' do
        inherit! :search_paths
        pod 'OCMock', '3.4.1'
    end

    target 'MSDKUI_Demo_UI_Tests' do
        inherit! :search_paths
        pod 'EarlGrey', '1.15.0'
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '${PODS_ROOT}/HEREMaps/framework']
            config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.cocoapods.MSDKUI'
            config.build_settings['RUN_CLANG_STATIC_ANALYZER'] = 'YES'
        end
    end
end
