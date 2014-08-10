# To do

- Build pure swift frameworks
- Build C and Objective-C files
    - Generate a module map with umbrella header to support importing
      C/ObjC code within the same framework (see "unextended-module.modulemap")
    - Generate Swift bridging headers
        - Or use the same "unextended module" concept in app targets
          (though bridging headers no longer make sense)
    - Generate exported Swift headers
    - Link C/ObjC object files into any target
- Easy intergration of frameworks into playgrounds (installation in system locations)
- Target-specific build settings
- Configure, build and run tests with XCTest
- Automatically add build output to CLEAN if rake/clean is imported
    - Make this configurable

# Done

- Output dylibs in Build/Products
- Output swiftmodules in Build/Products
- Add the ability to define "apps" or "executables" as well as modules
    - Put executables in bin/ by default

## Maybe later...

- Configure and build Cocoa & Cocoa Touch apps
