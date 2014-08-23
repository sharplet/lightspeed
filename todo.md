# To do

- Build C and Objective-C files
    - Generate Swift bridging headers
        - Or use the same "unextended module" concept in app targets
          (though bridging headers no longer make sense)
    - Generate exported Swift headers
    - Link C/ObjC object files into any target
- Define dependencies in a lightspeed.rake file that is evaluated with
  only the stripped-down lightspeed DSL
- Define an auto-loading mechanism for deps defined in submodules
- Easy distribution of binaries (and embedded frameworks?) using
  Homebrew
- Easy intergration of frameworks into playgrounds (installation in system locations)
- Target-specific build settings
- Configure, build and run tests with XCTest
- Automatically add build output to CLEAN if rake/clean is imported
    - Make this configurable
- CocoaPods integration?

# Done

- Output dylibs in Build/Products
- Output swiftmodules in Build/Products
- Add the ability to define "apps" or "executables" as well as modules
    - Put executables in bin/ by default
- Build pure swift frameworks
- Issue: Updating a swift file in a framework won't cause a recompile of
  an app depending on the framework
- Build C and Objective-C files
    - Generate a module map with umbrella header to support importing
      C/ObjC code within the same framework (see "unextended-module.modulemap")

## Maybe later...

- Configure and build Cocoa & Cocoa Touch apps
