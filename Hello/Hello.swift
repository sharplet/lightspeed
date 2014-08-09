import Foundation

public struct Hello: Printable {
  public init() {}
  public var description: String { return "Hello" }
}

public func greeting() -> String {
  let greeting = Hello()
  let subject = NSString(UTF8String: earth())
  return "\(greeting), \(subject)!"
}
