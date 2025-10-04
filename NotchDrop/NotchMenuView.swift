//
//  NotchMenuView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/11.
//

import ColorfulX
import SwiftUI

struct NotchMenuView: View {
    @StateObject var vm: NotchViewModel
    @StateObject var tvm = TrayDrop.shared

    var body: some View {
        HStack(spacing: vm.spacing) {
            close
            settings
            clear
        }
    }

    var close: some View {
        ColorButton(
            color: [.red],
            image: Image(systemName: "xmark"),
            title: "Exit"
        )
        .onTapGesture {
            vm.notchClose()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                NSApp.terminate(nil)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
    }

    var clear: some View {
        ColorButton(
            color: [.red],
            image: Image(systemName: "trash"),
            title: "Clear"
        )
        .onTapGesture {
            tvm.removeAll()
            vm.notchClose()
        }
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
    }

    var settings: some View {
        ColorButton(
            color: ColorfulPreset.colorful.colors.map { .init($0) },
            image: Image(systemName: "gear"),
            title: LocalizedStringKey("Settings")
        )
        .onTapGesture {
            vm.showSettings()
        }
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
    }
}

private struct ColorButton: View {
    let color: [Color]
    let image: Image
    let title: LocalizedStringKey

    @State var hover: Bool = false

    var body: some View {
        Color.white
            .opacity(0.1)
            .overlay(
                ColorfulView(
                    color: .constant(color),
                    speed: .constant(0)
                )
                .mask {
                    VStack(spacing: 8) {
                        Text("888888")
                            .hidden()
                            .overlay {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        Text(title)
                    }
                    .font(.system(.headline, design: .rounded))
                }
                .contentShape(Rectangle())
                .scaleEffect(hover ? 1.05 : 1)
                .animation(.spring, value: hover)
                .onHover { hover = $0 }
            )
            .aspectRatio(1, contentMode: .fit)
            .contentShape(Rectangle())
    }
}

#Preview {
    NotchMenuView(vm: .init())
        .padding()
        .frame(width: 600, height: 150, alignment: .center)
        .background(.black)
        .preferredColorScheme(.dark)
}
