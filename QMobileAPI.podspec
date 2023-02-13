Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "QMobileAPI"
  s.version      = "0.1.0"
  s.summary      = "Connect to 4D server using rest api."

  s.description  = <<-DESC
                   Load records from local or remote json files
                   DESC

  s.homepage     = "https://project.wakanda.org/issues/88964"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = "Copyright © 4D"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author             = { "Eric Marchand" => "eric.marchand@4d.com" }

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://gitfusion.wakanda.io/qmobile/QMobileAPI.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = "Sources/**/*.swift"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.dependency "SwiftyJSON"
  s.dependency "XCGLogger"
  s.dependency "Moya" # Alamofire/Result
  s.dependency "Prephirences"
  s.ios.dependency "DeviceKit"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.resources = ['**/*.lproj/*.strings']

end
