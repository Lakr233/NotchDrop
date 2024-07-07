//
//  Ext+FileProvider.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Cocoa
import Foundation
import UniformTypeIdentifiers

extension NSItemProvider {
    func convertToFilePathThatIsWhatWeThinkItWillWorkWithNotchDrop() -> URL? {
        var url: URL?
        let sem = DispatchSemaphore(value: 0)
        _ = loadObject(ofClass: URL.self) { item, _ in
            url = item
            sem.signal()
        }
        sem.wait()
        if url == nil {
            loadInPlaceFileRepresentation(
                forTypeIdentifier: UTType.data.identifier
            ) { input, _, _ in
                url = input
                sem.signal()
            }
            sem.wait()
        }
        if url == nil {
            _ = loadObject(ofClass: String.self) { item, _ in
                let file = temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("txt")
                try? item?.write(to: file, atomically: true, encoding: .utf8)
                if FileManager.default.fileExists(atPath: file.path) {
                    url = file
                }
                sem.signal()
            }
        }
        return url
    }
}

extension Array where Element == NSItemProvider {
    func interfaceConvert() -> [URL]? {
        let urls = compactMap { provider -> URL? in
            provider.convertToFilePathThatIsWhatWeThinkItWillWorkWithNotchDrop()
        }
        guard urls.count == count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.alertStyle = .critical
                alert.informativeText = "One or more files failed to load"
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
            return nil
        }
        return urls
    }
}
