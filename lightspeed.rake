Lightspeed.configure do |c|
  c.sdk = :macosx # default value
  # c.sdk = :iphonesimulator # module builds fine, linker error building executable
  # c.sdk = :iphoneos # LOTS of errors

  c.build_dir = 'Build' # default value

  c.executables_dir = 'bin' # default value
end

## Frameworks

framework 'Rake'
framework 'Hello'
framework 'Greetable' => ['Hello.framework', 'Rake.framework']

## Executables

swiftapp 'lspd' => 'Hello.framework' do |lspd|
  lspd.source_files = 'lspd/main.swift'
end

swiftapp 'hello' => 'Greetable.framework' do |app|
  app.source_files = 'main.swift'
end
