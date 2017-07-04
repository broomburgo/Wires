import Dispatch

public func after(_ delay: Double, _ callback: @escaping () -> ()) {
	let delayTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
	DispatchQueue.main.asyncAfter(deadline: delayTime) {
		callback()
	}
}
