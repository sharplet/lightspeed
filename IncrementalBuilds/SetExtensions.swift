extension Set {
	func map<U>(transform: T -> U) -> Set<U> {
		return flatMap { [transform($0)] }
	}

	func flatMap<U>(transform: T -> Set<U>) -> Set<U> {
		return reduce(self, Set<U>()) { $0.union(transform($1)) }
	}
}
