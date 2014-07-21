struct HelloRake: Printable {
  var greeting = "Hello, Rake"
  var description: String { return greeting }
}

println(HelloRake())
