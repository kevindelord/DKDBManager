source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "7.1"

use_frameworks!

target 'Example-Carthage' do
	project 'Example/DKDBManager.xcodeproj'

	pod 'DKHelper', '~> 2.1.1'
end

target 'Example-Cocoapods' do
	project 'Example/DKDBManager.xcodeproj'

	pod 'DKHelper', '~> 2.1.1'
	pod 'DKDBManager', :path => './DKDBManager.podspec'
end

target 'DKDBManagerTests' do
	project 'Example/DKDBManager.xcodeproj'

	pod 'DKHelper', '~> 2.1.1'
end
