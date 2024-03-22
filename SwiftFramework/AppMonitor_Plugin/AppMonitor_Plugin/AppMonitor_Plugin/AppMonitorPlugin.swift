//
//  AppMonitorPlugin.swift
//  AppMonitor_Plugin
//
//  Created by Manigandan on 20/03/24.
//

import Foundation
import MetricKit

struct AppMetric {
    var memoryUsage: Double
    var cpuUsage: Double
    var gpuUsage: Double
}

class AppMonitorPlugin
{
    private var isMonitoring: Bool = false
    private var timer : Timer?
    private var prevCPULoadInfo : host_cpu_load_info?
    private var metricsDict = [Double : AppMetric]()
    
    func startMonitor() {
        self.isMonitoring = true
        print("App Monitoring started")
	
        // Scheduling monitoring
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: Selector("updateAppMetrics"), userInfo: nil, repeats: true)
    }
    
    func stopMonitor() -> String? {
        self.isMonitoring = false
        print("App Monitoring stopped")
        self.timer?.invalidate()
        self.timer = nil
        let jsonMemoryUsage = convertDictToJsonString(metricsDict)
        return jsonMemoryUsage
    }
    
    func convertDictToJsonString(_ dictionary : [Double:AppMetric]) -> String?
    {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
            print("Something is wrong while json serializing the dictionary")
            return nil
        }
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Something is wrong while converting json data to string")
            return nil
        }
        return jsonString
    }

    func updateAppMetrics()
    {
        if(isMonitoring)
        {
            metricsDict[NSDate().timeIntervalSince1970] = AppMetric(memoryUsage: calculateGPUUsage(), cpuUsage: calculateCPUUsage(), gpuUsage: calculateGPUUsage())
        }
        else
        {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func calculateGPUUsage() -> Double {
        
        let gpuMetric = MXGPUMetric.init()
        return gpuMetric.cumulativeGPUTime.value
    }
    
    func calculateCPUUsage() -> Double {
        
        let cpuLoadInfo = getCPULoadInfo()
        if(prevCPULoadInfo == nil) {
            prevCPULoadInfo = cpuLoadInfo!
            return 0
        }
        let userTicks = Double((cpuLoadInfo?.cpu_ticks.0)! - prevCPULoadInfo!.cpu_ticks.0)
        let systemTicks = Double((cpuLoadInfo?.cpu_ticks.1)! - prevCPULoadInfo!.cpu_ticks.1)
        let idleTicks = Double((cpuLoadInfo?.cpu_ticks.2)! - prevCPULoadInfo!.cpu_ticks.2)
        let niceTicks = Double((cpuLoadInfo?.cpu_ticks.3)! - prevCPULoadInfo!.cpu_ticks.3)
        return userTicks + systemTicks + idleTicks + niceTicks
    }
    
    func getCPULoadInfo() -> host_cpu_load_info? {
        let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride/MemoryLayout<integer_t>.stride

        var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
        var cpuLoadInfo = host_cpu_load_info()
	
        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        if(result != KERN_SUCCESS){
            print("Error")
            return nil
        }
        return cpuLoadInfo
    }

    func calculateMemoryUsage() -> Double {
        var info = task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
	
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO),
                          task_info_t($0),
                          &count)
            }
        }
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0
        }
        else {
            return 0.0
        }
    }
}

let appMonitor = AppMonitorPlugin()

@_cdecl("startAppMonitor")
public func startAppMonitor(){
    appMonitor.startMonitor()
}

@_cdecl("stopAppMonitor")
public func stopAppMonitor() -> String?{
    return appMonitor.stopMonitor()
}
