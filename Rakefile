#
# Copyright (C) 2017-2021 HERE Europe B.V.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Constants

MSDKUI_WORKSPACE = "MSDKUI.xcworkspace"
MSDKUI_PROJECT = "MSDKUI.xcodeproj"
MSDKUI_PODSPEC = "MSDKUI.podspec"
MSDKUI_ARCHIVE = "MSDKUI.xcarchive"

MSDKUI_TARGET_SCHEME_NAME = "HEREMapsUI"
MSDKUI_TARGET = "MSDKUI"
DEMO_APP_TARGET = "MSDKUI_Demo"

DEFAULT_SIMULATOR_NAME = ENV['DEFAULT_SIMULATOR_NAME'] || "iPhone 8"
DEFAULT_IOS_VERSION = ENV['DEFAULT_IOS_VERSION'] || "14.4.2"

# Export to .ipa
DEFAULT_EXPORT_METHOD = ENV['DEFAULT_EXPORT_METHOD'] || "development"
DEFAULT_EXPORT_BUNDLE_ID = ENV['DEFAULT_EXPORT_BUNDLE_ID'] || "com.here.msdkui.demo"
DEFAULT_EXPORT_TEAM_ID = ENV['DEFAULT_EXPORT_TEAM_ID'] || ""
DEFAULT_EXPORT_PROV_PROFILE_NAME = ENV['DEFAULT_EXPORT_PROV_PROFILE_NAME'] || "IoT MSDKUI DemoApp Dev"

# Read secrets from .env.rb if possible
begin
    require './.env'
rescue LoadError
    puts("Missing .env.rb file. Secrets will be read from env. variables instead.")
end

# Default task

task default: %w[help]

task :help do
    system "rake -T"
end

# Build tasks

namespace :build do
    desc "Clean"
    task :clean do
        xcodebuild(command: "clean",
                   workspace: MSDKUI_WORKSPACE,
                   scheme: DEMO_APP_TARGET,
                   simulator_name: DEFAULT_SIMULATOR_NAME,
                   ios_version: DEFAULT_IOS_VERSION)
    end

    desc "Build the Demo app"
    task :simulator => [:"tools:cocoapods", :"build:clean"] do
        xcodebuild(command: "build",
                   workspace: MSDKUI_WORKSPACE,
                   scheme: DEMO_APP_TARGET,
                   simulator_name: DEFAULT_SIMULATOR_NAME,
                   ios_version: DEFAULT_IOS_VERSION)
    end

    desc "Build MSDKUI framework (fat binary)"
    task :msdkui_framework => [:"tools:cocoapods", :"build:clean"] do
        frameworks_directory = "#{ENV['PWD']}/output/framework/"
        device_framework = "iphoneos"
        simulator_framework = "iphonesimulator"

        # Remove previous framework builds
        systemOrExit "rm -rf '#{frameworks_directory}'"

        # Build for device
        buildframework(workspace: MSDKUI_WORKSPACE,
                       scheme: MSDKUI_TARGET_SCHEME_NAME,
                       architectures: "armv7,arm64",
                       sdk: device_framework,
                       output_directory: "#{frameworks_directory}/#{device_framework}/")

        # Build for simulator
        buildframework(workspace: MSDKUI_WORKSPACE,
                       scheme: MSDKUI_TARGET_SCHEME_NAME,
                       architectures: "x86_64,i386",
                       sdk: simulator_framework,
                       output_directory: "#{frameworks_directory}/#{simulator_framework}/")

        # Create a directory for the fat binary
        systemOrExit "mkdir -p '#{frameworks_directory}/universal/'"

        # Copy the device framework to the new directory
        systemOrExit "cp -r '#{frameworks_directory}/#{device_framework}/#{MSDKUI_TARGET}.framework' '#{frameworks_directory}/universal/'"

        # Combine both frameworks into a single fat binary
        systemOrExit "lipo -create \
                -output '#{frameworks_directory}/universal/#{MSDKUI_TARGET}.framework/#{MSDKUI_TARGET}' \
                '#{frameworks_directory}/#{device_framework}/#{MSDKUI_TARGET}.framework/#{MSDKUI_TARGET}' \
                '#{frameworks_directory}/#{simulator_framework}/#{MSDKUI_TARGET}.framework/#{MSDKUI_TARGET}'"

        # Copy the simulator module file over (device module files are already there)
        systemOrExit "cp -r '#{frameworks_directory}/#{simulator_framework}/#{MSDKUI_TARGET}.framework/Modules/#{MSDKUI_TARGET}.swiftmodule/' \
                '#{frameworks_directory}/universal/#{MSDKUI_TARGET}.framework/Modules/#{MSDKUI_TARGET}.swiftmodule'"

        # Remove intermediate steps
        systemOrExit "rm -rf '#{frameworks_directory}/#{device_framework}/'"
        systemOrExit "rm -rf '#{frameworks_directory}/#{simulator_framework}/'"
    end

    desc "Build the demo app .ipa (development)"
    task :ipa => [:"tools:cocoapods", :"build:clean"] do
        systemOrExit "rm -rf output/archive/"
        systemOrExit "rm -rf output/ipa/"

        xcodesetteam(xcode_project: MSDKUI_PROJECT,
                     team_id: DEFAULT_EXPORT_TEAM_ID)

        xcodearchive(workspace: MSDKUI_WORKSPACE,
                     scheme: DEMO_APP_TARGET,
                     sdk: "iphoneos",
                     archive_path: "output/archive/#{MSDKUI_ARCHIVE}")

        xcodeexport(archive_path: "output/archive/#{MSDKUI_ARCHIVE}",
                    output_directory: "output/ipa/",
                    method: DEFAULT_EXPORT_METHOD,
                    bundle_id: DEFAULT_EXPORT_BUNDLE_ID,
                    team_id: DEFAULT_EXPORT_TEAM_ID,
                    provisioning_profile_name: DEFAULT_EXPORT_PROV_PROFILE_NAME)
    end
end

# Test tasks

namespace :test do
    desc "Run all tests (Demo app Unit and UI; MSDKUI Unit)"
    task :all => [:"tools:cocoapods", :"build:clean"] do
        xcodetest(workspace: MSDKUI_WORKSPACE,
                  scheme: DEMO_APP_TARGET,
                  simulator_name: DEFAULT_SIMULATOR_NAME,
                  ios_version: DEFAULT_IOS_VERSION)
    end

    desc "Run MSDKUI Framework Unit Tests"
    task :msdkui_unit => [:"tools:cocoapods", :"build:clean"] do
        xcodetest(target: "MSDKUI_Tests",
                  workspace: MSDKUI_WORKSPACE,
                  scheme: DEMO_APP_TARGET,
                  simulator_name: DEFAULT_SIMULATOR_NAME,
                  ios_version: DEFAULT_IOS_VERSION)
    end

    desc "Run Demo App Unit Tests"
    task :demo_app_unit => [:"tools:cocoapods", :"build:clean"] do
        xcodetest(target: "MSDKUI_Demo_Tests",
                  workspace: MSDKUI_WORKSPACE,
                  scheme: DEMO_APP_TARGET,
                  simulator_name: DEFAULT_SIMULATOR_NAME,
                  ios_version: DEFAULT_IOS_VERSION)
    end

    desc "Run Demo App UI Tests"
    task :demo_app_ui => [:"tools:cocoapods", :"build:clean"] do
        xcodetest(target: "MSDKUI_Demo_UI_Tests",
                  workspace: MSDKUI_WORKSPACE,
                  scheme: DEMO_APP_TARGET,
                  simulator_name: DEFAULT_SIMULATOR_NAME,
                  ios_version: DEFAULT_IOS_VERSION)
    end
end

# Tools tasks

namespace :tools do
    desc "Run CocoaPods"
    task :cocoapods do
        systemOrExit "bundle exec pod install --repo-update --verbose"
    end

    desc "Run SwiftLint"
    task :swiftlint do
        swiftlint_path = "./Pods/SwiftLint/swiftlint"
        if File.exist?(swiftlint_path)
            systemOrExit swiftlint_path
        else
            puts "Make sure you have swiftlint installed (bundle exec pod install)."
        end
    end

    desc "Run SwiftLint Formatter"
    task :swiftlint_formatter do
        swiftlint_path = "./Pods/SwiftLint/swiftlint"
        if File.exist?(swiftlint_path)
            systemOrExit swiftlint_path + " autocorrect --format"
            systemOrExit swiftlint_path + " autocorrect"
        else
            puts "Make sure you have swiftlint installed (bundle exec pod install)."
        end
    end

    desc "Run Podspec lint"
    task :podspeclint do
        systemOrExit "bundle exec pod spec lint #{MSDKUI_PODSPEC}"
    end

    desc "Run Test Coverage for the MSDKUI Framework Unit Tests"
    task :xcov_msdkui => [:"test:msdkui_unit"] do
        xcov(workspace: MSDKUI_WORKSPACE,
             scheme: DEMO_APP_TARGET,
             exclude_targets: "OCMock.framework,MSDKUI_Demo.app",
             output_directory: "output/xcov/msdkui/")
    end

    desc "Run Test Coverage for the Demo App Unit Tests"
    task :xcov_demo_app => [:"test:demo_app_unit"] do
        xcov(workspace: MSDKUI_WORKSPACE,
             scheme: DEMO_APP_TARGET,
             exclude_targets: "OCMock.framework,MSDKUI.framework",
             output_directory: "output/xcov/demo_app/")
    end

    desc "Build Jazzy API Reference"
    task :jazzy => [:"tools:cocoapods", :"build:clean"] do
        buildjazzy(workspace: MSDKUI_WORKSPACE,
                   scheme: MSDKUI_TARGET_SCHEME_NAME,
                   module_name: MSDKUI_TARGET,
                   readme: "Documentation/API_Reference/Intro.md",
                   output_directory: "docs/")
    end

    desc "Build the NMACredentials file from environment variables"
    task :buildcredentials do
        createcredentialsfile(type_name: "NMACredentials",
                             file_path: "MSDKUI_Demo/NMACredentials.swift",
                             appID: "#{ENV['MSDKUI_APP_ID_IOS']}",
                             appCode: "#{ENV['MSDKUI_APP_TOKEN_IOS']}",
                             licenseKey: "#{ENV['MSDKUI_APP_LICENSE_IOS']}")
    end
end

# Localized strings

namespace :strings do
    desc "Download all localized strings (MSDKUI and Demo App)"
    task :all => [:"strings:msdkui_framework", :"strings:demo_app"] do
    end

    desc "Download localized strings for the MSDKUI Framework"
    task :msdkui_framework do
        downloadstrings(url: "#{ENV['MSDKUI_FRAMEWORK_STRINGS_URL']}",
                        output_directory: "MSDKUI/Assets/")
    end

    desc "Download localized strings for the Demo App"
    task :demo_app do
        downloadstrings(url: "#{ENV['MSDKUI_DEMO_APP_STRINGS_URL']}",
                        output_directory: "Commons/")
    end
end

# Helper functions

def systemOrExit(command)
    system command or exit!(1)
end

def xcodebuild(command:, workspace:, scheme:, simulator_name:, ios_version:)
    systemOrExit "xcodebuild \
            -workspace #{workspace} \
            -scheme #{scheme} \
            -destination 'platform=iOS Simulator,name=#{simulator_name},OS=#{ios_version}' \
            #{command}"
end

def xcodetest(target: target = '', workspace:, scheme:, simulator_name:, ios_version:)
    testing = "'-only-testing:#{target}'" if !target.to_s.empty?
    systemOrExit "xcodebuild \
            -workspace #{workspace} \
            -scheme #{scheme} \
            -destination 'platform=iOS Simulator,name=#{simulator_name},OS=#{ios_version}' \
            #{testing} \
            test"
end

def xcov(workspace:, scheme:, exclude_targets:, output_directory:)
    systemOrExit "bundle exec xcov \
            --workspace #{workspace} \
            --skip_slack \
            --configuration Debug \
            --scheme #{scheme} \
            --exclude_targets #{exclude_targets} \
            --html_report \
            --minimum_coverage_percentage 80 \
            --ignore_file_path .xcovignore \
            --output_directory #{output_directory} 2> /dev/null"
end

def buildframework(workspace:, scheme:, architectures:, sdk:, output_directory:)
    archs = architectures
        .split(",")
        .reduce("") { |previous, arch| "#{previous} -arch #{arch}" }

    systemOrExit "xcodebuild \
    		BITCODE_GENERATION_MODE=bitcode \
            -workspace #{workspace} \
            -configuration Release \
            #{archs} only_active_arch=no defines_module=yes \
            -sdk '#{sdk}' \
            -scheme #{scheme} CONFIGURATION_BUILD_DIR='#{output_directory}'"
end

def buildjazzy(workspace:, scheme:, module_name:, readme:, output_directory:)
    systemOrExit "bundle exec jazzy \
            --skip-undocumented \
            --hide-documentation-coverage \
            --clean \
            --xcodebuild-arguments -workspace,#{workspace},-scheme,#{scheme},-configuration,Release,defines_module=yes \
            --module '#{module_name}' \
            --output '#{output_directory}' \
            --github_url 'https://github.com/heremaps/msdkui-ios/' \
            --theme fullwidth \
            --readme='#{readme}'"

    systemOrExit "rm -rf '#{output_directory}/undocumented.json'"
end

def xcodesetteam(xcode_project:, team_id:)
    project = File.join(xcode_project, "project.pbxproj")

    file = File.read(project)
    file.gsub!(/DevelopmentTeam = .*;/, "DevelopmentTeam = #{team_id};")
    file.gsub!(/DEVELOPMENT_TEAM = .*;/, "DEVELOPMENT_TEAM = #{team_id};")
    File.write(project, file)
end

def xcodearchive(workspace:, scheme:, sdk:, archive_path:)
    systemOrExit "xcodebuild \
            -workspace #{workspace} \
            -scheme #{scheme} \
            -sdk #{sdk} \
            -configuration Release archive \
            -archivePath #{archive_path}"
end

def xcodeexport(archive_path:, output_directory:, method:, bundle_id:, team_id:, provisioning_profile_name:)
    exportOptions = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
            <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
            <plist version=\"1.0\">
                <dict>
                    <key>method</key>
                    <string>#{method}</string>
                    <key>teamID</key>
                    <string>#{team_id}</string>
                    <key>provisioningProfiles</key>
                    <dict>
                        <key>#{bundle_id}</key>
                        <string>#{provisioning_profile_name}</string>
                    </dict>
                </dict>
            </plist>\n"

    File.open("/tmp/exportOptions.plist", 'w') { |file| file.write(exportOptions) }

    systemOrExit "xcodebuild \
            -exportArchive \
            -archivePath #{archive_path} \
            -exportOptionsPlist /tmp/exportOptions.plist \
            -exportPath #{output_directory}"
end

def createcredentialsfile(type_name:, file_path:, appID:, appCode:, licenseKey:)
    file_content = <<-NMACREDENTIALS_FILE
//
// This is an auto-generated file that should not be committed to Git.
//

import Foundation

enum #{type_name} {
    static let appID = "#{appID}"
    static let appCode = "#{appCode}"
    static let licenseKey = "#{licenseKey}"
}
NMACREDENTIALS_FILE

    file = File.new(file_path, "w")
    file.puts(file_content)
    file.close
end

def downloadstrings(url:, output_directory:)
    # Dependencies
    begin
        require 'open-uri'
        require 'fileutils'
        require 'zip'
    rescue LoadError
        puts("Missing dependencies")
    end

    # Temporary directory
    strings_temp = "strings_temp"

    # Downloads to the temporary directory
    content = open(url)
    Zip::File.open_buffer(content) do |zip_file|
        zip_file.each do |entry|
            entry_path = File.join(strings_temp, entry.name)
            entry.extract(entry_path) unless File.exist?(entry_path)
        end
    end

    # Converts to UTF-8 and replaces exiting files
    Dir["#{strings_temp}/*"].each do |strings_language_dir|
        dir_name = File.basename(strings_language_dir)
        destination_dir_name = "#{output_directory}#{dir_name}/"

        if !Dir[destination_dir_name].empty?
            puts "Copying #{strings_language_dir} to #{destination_dir_name}"

            Dir["#{strings_language_dir}/Localizable.strings"].each do |strings_file|
                new_content = File.open(strings_file, "rb:UTF-16BE") { |f| f.read.encode('utf-8', :invalid=>:replace, :replace=>'').gsub(/%(\d+\$)?\Ks/, '@').gsub(/%(\d+\$)?\Kd/, 'ld') }
                File.open(strings_file, "w") { |file| file << new_content }
                file_name = File.basename(strings_file)
                destination_strings_file = "#{destination_dir_name}#{file_name}"
                FileUtils.cp(strings_file, destination_strings_file)
            end
        end
    end

    # Removes the temporary directory
    FileUtils.rm_r Dir[strings_temp]
end
