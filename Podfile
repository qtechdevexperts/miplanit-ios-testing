# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'MiPlanIt' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
#    pod 'RRuleSwift', :path => './RRuleSwift-master/'
    pod 'TwitterCore', :path => './twitter-kit-ios-master/TwitterCore'
    pod 'TwitterKit', :path => './twitter-kit-ios-master/TwitterKit'
#    pod 'Alamofire', '~> 4.7'
    # pod 'TwitterKit'
    pod 'TwitterKit5'
    pod 'Alamofire'
    pod 'IQKeyboardManagerSwift'
#    pod 'GoogleSignIn', '5.0.0'
    pod 'GoogleSignIn'
#    pod 'FacebookCore'
#    pod 'FacebookLogin'
#    pod 'FacebookShare'
    pod 'TransitionButton'
    pod 'MSAL'
    pod 'MSGraphClientSDK'
#    pod 'MSGraphClientSDK' , '1.0.0'
    pod 'MSGraphClientModels'
#    pod 'MSGraphClientModels', '1.1.0'
    pod 'PINRemoteImage'
    pod 'AWSAuthUI'
    pod 'AWSMobileClient'
    pod 'lottie-ios'
    pod 'GoogleMaps'
    pod 'GooglePlacePicker'
    pod 'GooglePlaces'
    # Add the Firebase pod for Google Analytics
    pod 'Firebase/Analytics'
    pod 'Firebase/Messaging'
    pod 'Firebase/Crashlytics'
    pod 'GrowingTextView'
#    pod 'GrowingTextView', '0.7.2'
    pod 'GradientLoadingBar'
    pod 'GzipSwift'
    pod 'SwiftKeychainWrapper'
    pod 'Google-Mobile-Ads-SDK'
    #User Default
    pod 'SwiftDefaults'
#     pod 'SwiftDefaults', '0.1.6'
    

  # Pods for MiPlanIt

 post_install do |installer|
     installer.pods_project.build_configurations.each do |config|
     config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
     config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
  end
 end

#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      config.build_settings['OTHER_CFLAGS'] ||= ['$(inherited)']
#      config.build_settings['OTHER_CFLAGS'] << '-DFORCE_USE_CURLOPT_TIMEOUT=1'
#      config.build_settings['OTHER_CFLAGS'] << '--connect-timeout 60'
#      config.build_settings['OTHER_CFLAGS'] << '--max-time 300'
#    end
#  end
#end

end
