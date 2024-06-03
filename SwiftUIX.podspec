Pod::Spec.new do |s|

  s.name         = "SwiftUIX"
  s.version      = "0.0.5"
  s.summary      = "Timeless fork of SwiftUIX"

  s.description  = <<-DESC
Timeless fork of SwiftUIX
                   DESC

  s.homepage     = "https://github.com/SwiftUIX/SwiftUIX"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Vatsal Manot" => "https://github.com/vmanot" }

  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"
  s.watchos.deployment_target = "6.0"

  s.source       = { :git => "https://github.com/SwiftUIX/SwiftUIX.git", :tag => "#{s.version}" }

  s.source_files  = "Sources/**/*.{swift,h}"
  s.swift_versions = ['5.0', '5.1']
  #s.exclude_files = "Classes/Exclude"

  s.framework  = "Foundation"

  s.requires_arc = true

end
