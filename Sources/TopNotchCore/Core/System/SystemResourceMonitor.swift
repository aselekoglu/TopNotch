import Foundation
import MachO
import Combine

public struct SystemResourceMetrics: Equatable, Sendable {
    public let cpuUsage: Double // 0.0 to 1.0
    public let memoryUsage: Double // 0.0 to 1.0
    public let freeMemoryGB: Double
    public let totalMemoryGB: Double
    
    public init(cpuUsage: Double, memoryUsage: Double, freeMemoryGB: Double, totalMemoryGB: Double) {
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.freeMemoryGB = freeMemoryGB
        self.totalMemoryGB = totalMemoryGB
    }
}

@MainActor
public final class SystemResourceMonitor: ObservableObject {
    public static let shared = SystemResourceMonitor()
    
    @Published public private(set) var metrics = SystemResourceMetrics(cpuUsage: 0.0, memoryUsage: 0.0, freeMemoryGB: 0.0, totalMemoryGB: 0.0)
    
    private var timer: AnyCancellable?
    private var previousCPULoad: [processor_cpu_load_info]?
    
    private init() {
        start()
    }
    
    public func start() {
        stop()
        // Take initial CPU sample
        previousCPULoad = getCPULoads()
        updateMetrics()
        
        timer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateMetrics()
            }
    }
    
    public func stop() {
        timer?.cancel()
        timer = nil
    }
    
    private func updateMetrics() {
        let cpu = calculateCPUUsage()
        let mem = calculateMemoryUsage()
        
        metrics = SystemResourceMetrics(
            cpuUsage: cpu,
            memoryUsage: mem.usage,
            freeMemoryGB: mem.freeGB,
            totalMemoryGB: mem.totalGB
        )
    }
    
    private func calculateCPUUsage() -> Double {
        guard let currentCPULoad = getCPULoads() else {
            return 0.0
        }
        
        guard let prevCPULoad = previousCPULoad, prevCPULoad.count == currentCPULoad.count else {
            previousCPULoad = currentCPULoad
            return 0.0
        }
        
        var totalUser: UInt64 = 0
        var totalSystem: UInt64 = 0
        var totalIdle: UInt64 = 0
        var totalNice: UInt64 = 0
        
        for i in 0..<currentCPULoad.count {
            let prev = prevCPULoad[i]
            let curr = currentCPULoad[i]
            
            // Handle ticks overflow/wrap safely using UInt64 conversion
            totalUser += curr.cpu_ticks.0 >= prev.cpu_ticks.0 ? UInt64(curr.cpu_ticks.0 - prev.cpu_ticks.0) : 0
            totalSystem += curr.cpu_ticks.1 >= prev.cpu_ticks.1 ? UInt64(curr.cpu_ticks.1 - prev.cpu_ticks.1) : 0
            totalIdle += curr.cpu_ticks.2 >= prev.cpu_ticks.2 ? UInt64(curr.cpu_ticks.2 - prev.cpu_ticks.2) : 0
            totalNice += curr.cpu_ticks.3 >= prev.cpu_ticks.3 ? UInt64(curr.cpu_ticks.3 - prev.cpu_ticks.3) : 0
        }
        
        previousCPULoad = currentCPULoad
        
        let totalTicks = totalUser + totalSystem + totalIdle + totalNice
        guard totalTicks > 0 else { return 0.0 }
        
        let activeTicks = totalUser + totalSystem + totalNice
        return Double(activeTicks) / Double(totalTicks)
    }
    
    private func getCPULoads() -> [processor_cpu_load_info]? {
        var numCPUs: natural_t = 0
        var processorInfo: processor_info_array_t?
        var numProcessorInfo: mach_msg_type_number_t = 0
        
        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUs,
            &processorInfo,
            &numProcessorInfo
        )
        
        guard result == KERN_SUCCESS, let info = processorInfo else {
            return nil
        }
        
        defer {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), vm_size_t(numProcessorInfo) * vm_size_t(MemoryLayout<integer_t>.stride))
        }
        
        var loads = [processor_cpu_load_info]()
        let stride = MemoryLayout<processor_cpu_load_info>.stride / MemoryLayout<integer_t>.stride
        
        for i in 0..<Int(numCPUs) {
            let offset = i * stride
            let ptr = info.advanced(by: offset)
            let loadInfo = ptr.withMemoryRebound(to: processor_cpu_load_info.self, capacity: 1) { $0.pointee }
            loads.append(loadInfo)
        }
        
        return loads
    }
    
    private func calculateMemoryUsage() -> (usage: Double, freeGB: Double, totalGB: Double) {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride)
        
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        let totalBytes = Double(ProcessInfo.processInfo.physicalMemory)
        let totalGB = totalBytes / (1024.0 * 1024.0 * 1024.0)
        
        guard result == KERN_SUCCESS else {
            return (0.0, totalGB, totalGB)
        }
        
        let pageSize = Double(getpagesize())
        let freeBytes = Double(stats.free_count) * pageSize
        let activeBytes = Double(stats.active_count) * pageSize
        let inactiveBytes = Double(stats.inactive_count) * pageSize
        let wireBytes = Double(stats.wire_count) * pageSize
        let compressedBytes = Double(stats.compressor_page_count) * pageSize
        
        let usedBytes = activeBytes + inactiveBytes + wireBytes + compressedBytes
        let freeGB = freeBytes / (1024.0 * 1024.0 * 1024.0)
        
        let usage = totalBytes > 0 ? (usedBytes / totalBytes) : 0.0
        return (min(1.0, max(0.0, usage)), freeGB, totalGB)
    }
}
