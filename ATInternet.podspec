#
# Be sure to run `pod lib lint AHWModel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ATInternet"
  s.version          = "2.1.0"
  s.summary          = "AT Internet mobile analytics solution for iOS"

  s.description      = <<-DESC
  Deals and offers module for the AccorHotels Application.
                       DESC

  s.homepage         = "https://github.com/at-internet/atinternet-ios-objc-sdk"
  s.license          = 'MIT'
  s.author           = { "AT Internet" => "at@atinternet.com" }
  s.source           = { :git => "https://github.com/at-internet/atinternet-ios-objc-sdk.git", :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  # s.tvos.deployment_target = '9.0'

  s.requires_arc = true

  s.default_subspec = 'iOS'

  s.prefix_header_file = 'Tracker/Tracker/ATTracker-prefix.pch'

  s.subspec 'Res' do |ss|
    ss.watchos.deployment_target = '2.0'
    ss.ios.deployment_target = '7.0'
    ss.resource_bundle = { 'ATAssets' => [ 
          "Tracker/Tracker/*.{xcdatamodeld,png,json}",
          "Tracker/Tracker/ATDefaultConfiguration.plist"
    ] }
  end

  s.subspec 'iOS' do |ss|
    ss.frameworks = [ "CoreData",
        "CoreFoundation",
        "UIKit",
        "CoreTelephony",
        "SystemConfiguration" ]

    ss.source_files = 'Tracker/Tracker/*.{h,m}'
    ss.dependency 'ATInternet/Res'
  end

  s.subspec 'AppExtension' do |ss|
    ss.watchos.deployment_target = '2.0'
    ss.dependency 'ATInternet/Res'

    ss.frameworks = [
        "CoreData",
        "CoreFoundation",
        "WatchKit"
      ]

    ss.source_files = "Tracker/Tracker/*.{h,m}"
    ss.exclude_files =  [ "Tracker/Tracker/ATBackgroundTask.{h,m}", "Tracker/Tracker/ATDebuggerWindow.{h,m}", "Tracker/Tracker/ATReachability.{h,m}"]
  end


end
