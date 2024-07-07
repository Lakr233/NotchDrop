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

    let animation: Animation = .interactiveSpring(
        duration: 0.5,
        extraBounce: 0.25,
        blendDuration: 0.125
    )

    @Published var isOpened: Bool = false
    @Published var isAboutOpen: Bool = false

    @Published var spacing: CGFloat = 16
    @Published var cornerRadius: CGFloat = 16

    @Published var notchRectIfOpen: CGRect = .zero
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
                if isOpened {
                    // touch outside, close
                    if !notchRectIfOpen.contains(mouseLocation) {
                        isOpened = false
                        // click where user open the panel
                    } else if deviceNotchRect.contains(mouseLocation) {
                        isOpened = false
                        // for the same height as device notch, open the url of project
                    } else {
                        var checkRect = deviceNotchRect
                        checkRect.origin.x = 0
                        checkRect.size.width = screenRect.width
                        if checkRect.contains(mouseLocation) {
                            if isOpened { isOpened = false }
                            print("[*] open the project url")
                            NSWorkspace.shared.open(productPage)
                        }
                    }
                } else {
                    // touch inside, open
                    if deviceNotchRect.contains(mouseLocation) {
                        print("[*] notch is opening, clicked at \(mouseLocation)")
                        isOpened = true
                    }
                }
            }
            .store(in: &cancellables)

        events.mouseLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mouseLocation in
                guard let self else { return }
                let mouseLocation: NSPoint = NSEvent.mouseLocation
                let aboutToOpen = deviceNotchRect.contains(mouseLocation)
                if isAboutOpen != aboutToOpen { isAboutOpen = aboutToOpen }
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

        Publishers.CombineLatest(
            events.mouseLocation,
            events.mouseDraggingFile
        )
        .receive(on: DispatchQueue.main)
        .map { _, _ in
            let location: NSPoint = NSEvent.mouseLocation
            let draggingFile = NSPasteboard(name: .drag)
                .pasteboardItems?
                .compactMap { $0.string(forType: .fileURL) }
                .compactMap { URL(string: $0) } ?? []
            return (location, draggingFile)
        }
        .sink { [weak self] location, draggingFile in
            guard let self else { return }
            if isOpened, !notchRectIfOpen.contains(location) {
                isOpened = false
                return
            }
            guard deviceNotchRect.contains(location) else { return }
            guard !draggingFile.isEmpty else { return }
            print("[*] notch is opening, dragged at \(location), files \(draggingFile)")
            isOpened = true
        }
        .store(in: &cancellables)

        $isOpened
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOpened in
                guard let self else { return }
                print("[*] notch is switching status \(isOpened)")
                if isOpened, isAboutOpen { isAboutOpen = false }
            }
            .store(in: &cancellables)
    }
}
