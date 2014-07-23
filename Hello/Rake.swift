public struct Rake {
  public init() {}
  var greeting = "Hello, Rake"
}

extension Rake: Printable {
  public var description: String { return greeting }
}
