Pod::Spec.new do |spec|
  spec.name         = "SwiftUIX"
  spec.version      = "0.0.1"
  spec.summary      = "An extension to the standard SwiftUI library."
  spec.description  = <<-DESC
SwiftUIX attempts to fill the gaps of the still nascent SwiftUI framework, providing an extensive suite of components, extensions and utilities to complement the standard library.
                   DESC
  spec.homepage     = "https://github.com/SwiftUIX/SwiftUIX"
  spec.license      = { :type => "MIT", :file => "LICENSE.md" }
  spec.author             = { "Vatsal Manot" => "vatsal.manot@yahoo.com" }
  spec.social_media_url   = "https://twitter.com/vatsal_manot"
  
  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "10.15"
  spec.watchos.deployment_target = "6.0"
  spec.tvos.deployment_target = "13.0"

  spec.source = { :git => "https://github.com/SwiftUIX/SwiftUIX.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/**/*.{swift}"
  spec.swift_version = "5.1"
  spec.framework  = "SwiftUI"
end
