#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'sms'
  s.version          = '0.0.1'
  s.summary          = 'SMS library for Flutter applications. Its allow to send, receive, query sms messages, sms delivery and query contacts info. It exposes an easy and friendly API for developing a completely functional sms app in Flutter.'
  s.description      = <<-DESC
SMS library for Flutter applications. Its allow to send, receive, query sms messages, sms delivery and query contacts info. It exposes an easy and friendly API for developing a completely functional sms app in Flutter.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.ios.deployment_target = '8.0'
end

