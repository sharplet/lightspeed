import Hello
import Rake

protocol Greeting: Printable {}
protocol Greetable: Printable {}

extension Hello: Greeting {}
extension Rake: Greetable {}

func +(greeting: Greeting, subject: Greetable) -> String {
  return "\(greeting), \(subject)!"
}

println(Hello() + Rake())
