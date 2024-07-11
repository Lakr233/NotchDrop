//
//  AirDrop+View.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import ColorfulX
import Pow
import SwiftUI
import UniformTypeIdentifiers

struct AirDropView: View {
    @StateObject var vm: NotchViewModel

    @State var trigger: UUID = .init()
    @State var targeting = false

    var body: some View {
        dropArea
            .onDrop(of: [.data], isTargeted: $targeting) { providers in
                trigger = .init()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    vm.notchClose()
                }
                DispatchQueue.global().async { beginDrop(providers) }
                return true
            }
    }

    var dropArea: some View {
        ColorfulView(
            color: .init(get: {
                if targeting {
                    ColorfulPreset.neon.colors
                } else {
                    ColorfulPreset.aurora.colors
                }
            }, set: { _ in }),
            speed: .init(get: {
                targeting ? 1.5 : 0
            }, set: { _ in }),
            transitionSpeed: .constant(25)
        )
        .opacity(0.5)
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
        .overlay { dropLabel }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .changeEffect(
            .spray(origin: UnitPoint(x: 0.5, y: 0.5)) {
                Image(systemName: "paperplane")
                    .foregroundStyle(.white)
            },
            value: trigger
        )
    }

    var dropLabel: some View {
        VStack(spacing: 8) {
            Image(systemName: "airplayaudio")
            Text("AirDrop")
        }
        .font(.system(.headline, design: .rounded))
        .contentShape(Rectangle())
        .onTapGesture {
            trigger = .init()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                vm.notchClose()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let picker = NSOpenPanel()
                picker.allowsMultipleSelection = true
                picker.canChooseDirectories = true
                picker.canChooseFiles = true
                picker.begin { response in
                    if response == .OK {
                        let drop = AirDrop(files: picker.urls)
                        drop.begin()
                    }
                }
            }
        }
    }

    func beginDrop(_ providers: [NSItemProvider]) {
        assert(!Thread.isMainThread)
        guard let urls = providers.interfaceConvert() else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let drop = AirDrop(files: urls)
            drop.begin()
        }
    }
}
