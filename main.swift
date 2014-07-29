import Greetable
import Hello
import Rake

func +(greeting: Greeting, subject: Greetable) -> String {
  return "\(greeting), \(subject)!"
}

println(Hello() + Rake())
