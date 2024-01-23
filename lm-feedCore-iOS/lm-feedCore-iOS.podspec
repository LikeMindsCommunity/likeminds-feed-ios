Pod::Spec.new do |spec|
  spec.name         = 'lm-feedCore-iOS'
  spec.summary      = 'Masterpiece in Making'
  spec.homepage     = 'https://likeminds.community/'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT', :file => '../LICENSE' }
  spec.authors      = { 'Devansh Mohata' => 'devansh.mohata@likeminds.community' }
  spec.source       = { :git => 'git@github.com:LikeMindsCommunity/likeminds-feed-ios.git', :tag => "MyAmazingFramework_v#{spec.version}" }
  spec.source_files = 'lm-feedCore-iOS/Source/**/*.swift'
  spec.resource_bundles = {
     'lm-feedCore-iOS' => ['lm-feedCore-iOS/Source/**/*.{xcassets}']
  }
  spec.ios.deployment_target = '13.0'
  spec.swift_version = '5.0'
  spec.requires_arc = true

  spec.dependency "AWSCore"
  spec.dependency "AWSCognito"
  spec.dependency "AWSS3"
  spec.dependency 'lm-feedUI-iOS'
  spec.dependency 'BSImagePicker'
  spec.dependency 'LikeMindsFeed'
end
