import UIKit
import QuartzCore

final class SystemInfoProvider {
    private var displayLink: CADisplayLink?
    private var frameCount = 0
    private var lastTimestamp: CFTimeInterval = 0
    private var currentFPS: Double = 0

    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
        displayLink?.add(to: .main, forMode: .common)
        lastTimestamp = CACurrentMediaTime()
    }

    @objc private func tick(_ link: CADisplayLink) {
        frameCount += 1
        let now = CACurrentMediaTime()
        let elapsed = now - lastTimestamp
        if elapsed >= 1.0 {
            currentFPS = Double(frameCount) / elapsed
            frameCount = 0
            lastTimestamp = now
        }
    }

    private func ramUsedMB() -> Double {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        return Double(info.phys_footprint) / (1024.0 * 1024.0)
    }

    func snapshot() -> [String: Any] {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        let batteryLevel = device.batteryLevel < 0 ? 0 : device.batteryLevel * 100
        var batteryState = "unknown"
        switch device.batteryState {
        case .charging: batteryState = "charging"
        case .full: batteryState = "full"
        case .unplugged: batteryState = "unplugged"
        default: break
        }

        return [
            "fps": Int(currentFPS.rounded()),
            "battery": Int(batteryLevel.rounded()),
            "batteryState": batteryState,
            "ramMB": Int(ramUsedMB().rounded())
        ]
    }
}
