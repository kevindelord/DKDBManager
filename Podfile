source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "8.0"

use_frameworks!

target 'Example-Carthage' do
	project 'Example/DKDBManager.xcodeproj'

	pod 'DKHelper', '~> 2.2.4'
end

target 'Example-Cocoapods' do
	project 'Example/DKDBManager.xcodeproj'

	pod 'DKHelper', '~> 2.2.4'
	pod 'DKDBManager', :path => './DKDBManager.podspec'
end

target 'DKDBManagerTests' do
	project 'Example/DKDBManager.xcodeproj'

	pod 'DKHelper', '~> 2.2.4'
end
