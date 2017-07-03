public enum Preferences {
	private static let logActiveKey = "Wires.Preferences.logActiveKey"
	public static var logActive: Bool = false
}

enum Log {
	static let prefix = "WiresLog"
	static let separator = " --> "

	static func with(context: Any, text: String) {
		guard Preferences.logActive else { return }
		print(prefix + separator + "\(context)" + separator + text)
	}
}
