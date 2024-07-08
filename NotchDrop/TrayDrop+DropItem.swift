//
//  TrayDrop+DropItem.swift
//  TrayDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Cocoa
import Foundation
import QuickLook

extension TrayDrop {
    struct DropItem: Identifiable, Codable, Equatable, Hashable {
        let id: UUID

        let name: String
        let size: Int

        let originalURL: URL
        let copiedDate: Date
        let workspacePreviewImageData: Data

        init(url: URL) throws {
            assert(!Thread.isMainThread)

            id = UUID()
            name = url.lastPathComponent
            size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            originalURL = url
            copiedDate = Date()
            workspacePreviewImageData = url.snapshotPreview().pngRepresentation

            try FileManager.default.createDirectory(
                at: duplicatedURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try FileManager.default.copyItem(at: url, to: duplicatedURL)
        }
    }
}

extension TrayDrop.DropItem {
    static let mainDir = "CopiedItems"

    var duplicatedURL: URL {
        documentsDirectory
            .appendingPathComponent(Self.mainDir)
            .appendingPathComponent(id.uuidString)
            .appendingPathComponent(originalURL.lastPathComponent)
    }

    var workspacePreviewImage: NSImage {
        .init(data: workspacePreviewImageData) ?? .init()
    }

    var decisionURL: URL {
        if FileManager.default.fileExists(atPath: originalURL.path) {
            return originalURL
        }
        return duplicatedURL
    }

    var shouldClean: Bool {
        if !FileManager.default.fileExists(atPath: decisionURL.path) { return true }
        if !FileManager.default.fileExists(atPath: duplicatedURL.path) { return true }
        if Date().timeIntervalSince(copiedDate) > TrayDrop.keepInterval { return true }
        return false
    }
}
