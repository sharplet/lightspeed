def swift(*args)
  if args.count == 1 && args.first.to_s.include?(" ")
    sh "xcrun swift #{args.first.to_s}"
  else
    sh "xcrun", "swift", *args
  end
end
