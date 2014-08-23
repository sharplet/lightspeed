# Lightspeed Dependencies

Description:

- "Depfile": lightspeed.rake in root of project which describes how to
  build the project.

  Example:

        # lightspeed.rake
        framework "swiftz", source: "https://github.com/maxpow4h/swiftz.git"
        framework "Alamofire", source: "https://github.com/Alamofire/Alamofire.git"
        framework "ReactiveCocoa", source "https://github.com/ReactiveCocoa/ReactiveCocoa.git",
                                   commit: "e442b3ca59c6fd7ee44216f9be2ab6305fc0b81d"

- Lightspeed::Deps::DSL can be "prepended" to Lightspeed::DSL to
  intercept the call to #framework and create a remote framework.
- Depfile also can specify dependencies of this project. This means:
    - Download a project as a Git submodule
    - Load the project's depfile
        - Load _that_ project's deps, etc.
- lightspeed-deps depends on a small module that provides API for
  describing Git rake tasks, e.g. downloading a submodule (this probably
  doesn't need to be extracted to begin with)
- All dependent projects are installed in the Vendor/ directory of this
  project.
- lightspeed.rb should automatically load lightspeed-deps.rb if
  possible, and recover if it's not installed.

Possible issues:

- Recursive dependency resolution: I'd like to be able to run
  "rake lightspeed:install" and each time a new dependency is
  downloaded, dynamically load its depfile and continue downloading until
  there is nothing more to download. Complete when:
    - All submodules installed
    - Correct commits are checked out
    - lightspeed.rake loaded
        - All deps installed, etc.
- Dependency cycles: hopefully rake would handle this, but the main
  potential issue is that new tasks would be loaded dynamically and
  cycles may not exist until much later during execution.
- My lightspeed.rake declares an external dependency with one name, but
  once downloaded it actually has a different name (e.g., misspelled
  "Alamofire"). This should produce an error.
