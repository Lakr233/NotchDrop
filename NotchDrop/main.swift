//
//  main.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import AppKit

let productPage = URL(string: "https://github.com/Lakr233/NotchDrop")!
let sponsorPage = URL(string: "https://github.com/sponsors/Lakr233")!

let bundleIdentifier = Bundle.main.bundleIdentifier!
let appVersion = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))"

private let availableDirectories = FileManager
    .default
    .urls(for: .documentDirectory, in: .userDomainMask)
let documentsDirectory = availableDirectories[0]
    .appendingPathComponent("NotchDrop")
let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent(bundleIdentifier)
try? FileManager.default.removeItem(at: temporaryDirectory)
try? FileManager.default.createDirectory(
    at: documentsDirectory,
    withIntermediateDirectories: true,
    attributes: nil
)
try? FileManager.default.createDirectory(
    at: temporaryDirectory,
    withIntermediateDirectories: true,
    attributes: nil
)

let pidFile = documentsDirectory.appendingPathComponent("ProcessIdentifier")

do {
    let prevIdentifier = try String(contentsOf: pidFile, encoding: .utf8)
    if let prev = Int(prevIdentifier) {
        if let app = NSRunningApplication(processIdentifier: pid_t(prev)) {
            app.terminate()
        }
    }
} catch {}
try? FileManager.default.removeItem(at: pidFile)

do {
    let pid = String(NSRunningApplication.current.processIdentifier)
    try pid.write(to: pidFile, atomically: true, encoding: .utf8)
} catch {
    NSAlert.popError(error)
    exit(1)
}

_ = TrayDrop.shared
TrayDrop.shared.cleanExpiredFiles()

repeat {
    let executablePath = ProcessInfo.processInfo.arguments.first!
    let selfHandle = open(executablePath, O_EVTONLY)
    guard selfHandle > 0 else { break }

    let monitorSource = DispatchSource.makeFileSystemObjectSource(
        fileDescriptor: selfHandle,
        eventMask: .delete
    )
    monitorSource.setEventHandler {
        guard monitorSource.data == .delete else { return }
        monitorSource.cancel()
        exit(0)
    }
    monitorSource.resume()
} while false

private let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
