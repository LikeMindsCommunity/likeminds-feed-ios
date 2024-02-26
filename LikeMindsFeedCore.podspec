Pod::Spec.new do |spec|
  spec.name         = 'LikeMindsFeedCore'
  spec.summary      = 'LikeMinds Feed official iOS SDK'
  spec.homepage     = 'https://likeminds.community/'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors      = { 'Devansh Mohata' => 'devansh.mohata@likeminds.community' }
  spec.source       = { :git => 'https://github.com/LikeMindsCommunity/likeminds-feed-ios.git', :tag => spec.version }
  spec.source_files = 'lm-feedCore-iOS/lm-feedCore-iOS/Source/**/*.swift'
  spec.resource_bundles = {
     'LikeMindsFeedCore' => ['lm-feedCore-iOS/lm-feedCore-iOS/Source/**/*.{xcassets}']
  }
  spec.ios.deployment_target = '13.0'
  spec.swift_version = '5.0'
  spec.requires_arc = true

  spec.dependency "AWSCore"
  spec.dependency "AWSCognito"
  spec.dependency "AWSS3"
  spec.dependency 'BSImagePicker'
  spec.dependency "FirebaseCore"
  spec.dependency "FirebaseMessaging"
  spec.dependency 'LikeMindsFeed'
  spec.dependency 'LikeMindsFeedUI'
end
