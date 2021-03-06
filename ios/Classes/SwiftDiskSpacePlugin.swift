import Flutter
import UIKit

public class SwiftDiskSpacePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "disk_space", binaryMessenger: registrar.messenger())
    let instance = SwiftDiskSpacePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getFreeDiskSpace":
        result(UIDevice.current.freeDiskSpaceInMB)
    case "getTotalDiskSpace":
        result(UIDevice.current.totalDiskSpaceInMB)
    default:
        result(0.0)
    }
    result("iOS " + UIDevice.current.systemVersion)

  }
}

extension UIDevice {
    var totalDiskSpaceInMB:Double {
        return Double(totalDiskSpaceInBytes / (1024 * 1024))
    }

    var freeDiskSpaceInMB:Double {
        return Double(freeDiskSpaceInBytes / (1024 * 1024))
    }

    var usedDiskSpaceInMB:Double {
        return Double(usedDiskSpaceInBytes / (1024 * 1024))
    }

    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }

    /*
     Total available capacity in bytes for "Important" resources, including space expected to be cleared by purging non-essential and cached resources. "Important" means something that the user or application clearly expects to be present on the local system, but is ultimately replaceable. This would include items that the user has explicitly requested via the UI, and resources that an application requires in order to provide functionality.
     Examples: A video that the user has explicitly requested to watch but has not yet finished watching or an audio file that the user has requested to download.
     This value should not be used in determining if there is room for an irreplaceable resource. In the case of irreplaceable resources, always attempt to save the resource regardless of available capacity and handle failure as gracefully as possible.
     */
//    var freeDiskSpaceInBytes:Int64 {
//        if #available(iOS 11.0, *) {
//            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
//                return space ?? 0
//            } else {
//                return 0
//            }
//        } else {
//            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
//            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
//                return freeSpace
//            } else {
//                return 0
//            }
//        }
//    }
    //  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
    var freeDiskSpaceInBytes:Int64 {

        var totalFreeSpace: Int64 = 0

        var error: Error? = nil

        if #available(iOS 11.0, *) {
            let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
            do {
                let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
                if let capacity = values.volumeAvailableCapacityForImportantUsage {
                    print("Available capacity for important usage: \(capacity)")
                    totalFreeSpace=capacity
                } else {
                    print("Capacity is unavailable")
                }
            } catch {
                print("Error retrieving capacity: \(error.localizedDescription)")
            }
        }else{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)

            var dictionary: [FileAttributeKey : Any]? = nil
            do {
                dictionary = try FileManager.default.attributesOfFileSystem(forPath: paths.last ?? "")
            } catch {
            }

            if let dictionary = dictionary {

                let freeFileSystemSizeInBytes = dictionary[.systemFreeSize] as? NSNumber

                totalFreeSpace = freeFileSystemSizeInBytes?.int64Value ?? 0

                print(String(format: "Memory Capacity of %llu.", (totalFreeSpace / 1024) / 1024))
            } else {

                print("Error Obtaining System Memory Info: Domain = \((error as NSError?)?.domain ?? ""), Code = \((error as NSError?)?.code ?? 0)")
            }
        }
         return totalFreeSpace
    }
    

    var usedDiskSpaceInBytes:Int64 {
       return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }

}

