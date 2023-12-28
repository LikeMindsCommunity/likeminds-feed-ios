#
# Be sure to run `pod lib lint likeminds-feed-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'likeminds-feed-iOS'
  s.version          = '0.1.0'
  s.summary          = 'Masterpiece in Making'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://likeminds.community/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Devansh Mohata' => 'devansh.mohata@likeminds.community' }
  s.source           = { :git => 'https://github.com/LikeMindsCommunity/likeminds-feed-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://www.linkedin.com/company/14677797/admin/feed/posts/'

  s.ios.deployment_target = '13.0'
  
  s.source_files = 'Source/Classes/**/*'
  
  s.resource_bundles = {
     'likeminds-feed-iOS' => ['Source/Assets/*.{xcassets}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.swift_version = '5.0'
#  s.frameworks = 'UIKit'
  s.dependency 'Kingfisher', '~> 7.0'
  s.dependency 'LikeMindsFeed'
end
