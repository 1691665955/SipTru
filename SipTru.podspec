Pod::Spec.new do |spec|

  spec.name         = "SipTru"
  spec.version      = "0.0.1"
  spec.summary      = "广东触点科技有限公司云对讲库"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "masterzeng" => "1691665955@qq.com" }
  spec.source       = { :git => "https://github.com/1691665955/SipTru.git", :tag => s.version }
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  spec.source_files  = "SipTru", "SipTru/*.{h,m}"
  spec.dependency 'linphone-sdk','~> 4.3'
  spec.public_header_files = "SipTru/SipTruManager.h"

end