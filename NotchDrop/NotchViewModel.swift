//
//  NotchViewModel.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import Cocoa
import Combine
import Foundation
import SwiftUI

class NotchViewModel: ObservableObject {
    var cancellables: Set<AnyCancellable> = []

    init() {
        setupCancellables()
    }

    deinit {
        print("[*] NotchViewModel deinit")
        destroy()
    }

    let animation: Animation = .interactiveSpring(
        duration: 0.5,
        extraBounce: 0.25,
        blendDuration: 0.125
    )

    let notchOpenedSize: CGSize = .init(width: 600, height: 150)

    let dropDetectorRange: CGFloat = 24

    enum Status {
        case closed
        case opened
        case popping
    }

    @Published var status: Status = .closed

    @Published var spacing: CGFloat = 16
    @Published var cornerRadius: CGFloat = 16

    var notchOpenedRect: CGRect {
        .init(
            x: screenRect.width / 2 - notchOpenedSize.width / 2,
            y: screenRect.height - notchOpenedSize.height,
            width: notchOpenedSize.width,
            height: notchOpenedSize.height
        )
    }

    @Published var deviceNotchRect: CGRect = .zero

    @Published var screenRect: CGRect = .zero

    @Published var optionKeyPressed: Bool = false
}

extension NotchViewModel {
    func setupCancellables() {
        let events = EventMonitors.shared
        events.mouseDown
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let mouseLocation: NSPoint = NSEvent.mouseLocation
                switch status {
                case .opened:
                    // touch outside, close
                    if !notchOpenedRect.contains(mouseLocation) {
                        status = .closed
                        // click where user open the panel
                    } else if deviceNotchRect.contains(mouseLocation) {
                        status = .closed
                        // for the same height as device notch, open the url of project
                    } else {
                        var checkRect = deviceNotchRect
                        checkRect.origin.x = 0
                        checkRect.size.width = screenRect.width
                        if checkRect.contains(mouseLocation) {
                            status = .closed
                            print("[*] open the project url")
                            NSWorkspace.shared.open(productPage)
                        }
                    }
                case .closed, .popping:
                    // touch inside, open
                    if deviceNotchRect.contains(mouseLocation) {
                        print("[*] notch is opening, clicked at \(mouseLocation)")
                        status = .opened
                    }
                }
            }
            .store(in: &cancellables)

        events.mouseUp
            .delay(for: 0.1, scheduler: DispatchQueue.main)
            .sink {
                let pasteboard = NSPasteboard(name: .drag)
                pasteboard.prepareForNewContents()
                pasteboard.writeObjects([])
            }
            .store(in: &cancellables)

        events.optionKeyPress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] input in
                guard let self else { return }
                optionKeyPressed = input
            }
            .store(in: &cancellables)

        events.mouseLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mouseLocation in
                guard let self else { return }
                let mouseLocation: NSPoint = NSEvent.mouseLocation
                let aboutToOpen = deviceNotchRect.contains(mouseLocation)
                if status == .closed, aboutToOpen { status = .popping }
                if status == .popping, !aboutToOpen { status = .closed }
            }
            .store(in: &cancellables)
//
        Publishers.CombineLatest(
            events.mouseLocation,
            events.mouseDraggingFile
        )
        .receive(on: DispatchQueue.main)
        .map { _, _ in
            let location: NSPoint = NSEvent.mouseLocation
            let draggingFile = NSPasteboard(name: .drag)
                .pasteboardItems ?? []
            return (location, draggingFile)
        }
        .sink { [weak self] location, draggingFile in
            guard let self else { return }
            switch status {
            case .opened:
                if deviceNotchRect.insetBy(dx: -14, dy: -14).contains(location) {
                    break
                }
                if !notchOpenedRect.insetBy(dx: -32, dy: -32).contains(location) {
                    print("[*] dragging out of range \(location) notch at \(notchOpenedRect)")
                    if status == .opened { status = .closed }
                }
            case .closed, .popping:
                guard !draggingFile.isEmpty else { return }
                if deviceNotchRect.insetBy(dx: -14, dy: -14).contains(location) {
                    print("[*] notch is opening, dragged at \(location), files \(draggingFile)")
                    status = .opened
                }
            }
        }
        .store(in: &cancellables)
    }

    func destroy() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
