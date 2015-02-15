extension Optional {
	func flatMap<U>(transform: T -> U?) -> U? {
		switch self {
		case let .Some(t): return transform(t)
		case .None: return nil
		}
	}
}
