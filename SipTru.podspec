Pod::Spec.new do |spec|

  spec.name         = "SipTru"
  spec.version      = "0.0.2"
  spec.summary      = "广东触点科技有限公司云对讲库"
  spec.homepage     = "https://github.com/1691665955/SipTru.git"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "masterzeng" => "1691665955@qq.com" }
  spec.source       = { :git => "https://github.com/1691665955/SipTru.git", :tag => spec.version }
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  spec.source_files  = "SipTru", "SipTru/*.{h,m}"
  spec.dependency 'linphone-sdk','4.3'
  spec.public_header_files = "SipTru/SipTruManager.h"

end
