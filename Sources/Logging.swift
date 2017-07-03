import Foundation

public enum WiresPreferences {
	private static let logActiveKey = "Wires.WiresPreferences.logActiveKey"
	public static var logActive: Bool = false
}

enum Log {
	static let prefix = "WiresLog"
	static let separator = " --> "

	static func with(context: Any, text: String) {
		guard WiresPreferences.logActive else { return }
		let actualContext = "\(context)".replacingOccurrences(of: "Wires.", with: "")
		print(prefix + separator + actualContext + separator + text)
	}
}
