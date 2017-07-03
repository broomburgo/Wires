public enum Preferences {
	public static var logActive: Bool = false
	public static var logSeparator: String? = nil
}

enum Log {
	static let prefix = "WiresLog"
	static let separator = "------"
	static let interfix = " --> "

	static func with(context: Any, text: String) {
		guard Preferences.logActive else { return }
		let preseparator = Preferences.logSeparator.map { $0 + "\n" } ?? ""
		let postseparator = Preferences.logSeparator.map { "\n" + $0 } ?? ""
		print(preseparator + prefix + interfix + "\(context)" + interfix + text + postseparator)
	}
}
