extension Array {
	func flatMap<U>(transform: T -> [U]) -> [U] {
		return reduce([]) { $0 + transform($1) }
	}
}
