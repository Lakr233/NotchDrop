//
//  NotchView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import SwiftUI

struct NotchView: View {
    @StateObject var vm: NotchViewModel

    var finalSize: CGSize { .init(width: 600, height: 150) }

    var notchSize: CGSize {
        if vm.isOpened { return finalSize }
        if vm.isAboutOpen { return .init(
            width: vm.deviceNotchRect.width,
            height: vm.deviceNotchRect.height + 4
        ) }
        var ans = CGSize(
            width: vm.deviceNotchRect.width - 4,
            height: vm.deviceNotchRect.height - 4
        )
        if ans.width < 0 { ans.width = 0 }
        if ans.height < 0 { ans.height = 0 }
        return ans
    }

    var notchCornerRadius: CGFloat {
        if vm.isOpened { return 32 }
        if vm.isAboutOpen { return 10 }
        return 8
    }

    var body: some View {
        ZStack(alignment: .top) {
            notch
                .zIndex(0)
                .disabled(true)
            Group {
                if vm.isOpened {
                    VStack(spacing: vm.spacing) {
                        NotchHeaderView(vm: vm)
                        NotchContentView(vm: vm)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(vm.spacing)
                    .frame(maxWidth: finalSize.width, maxHeight: finalSize.height)
                    .zIndex(1)
                    .onAppear {
                        vm.notchRectIfOpen = .init(
                            x: vm.screenRect.width / 2 - finalSize.width / 2,
                            y: vm.screenRect.height - finalSize.height,
                            width: finalSize.width,
                            height: finalSize.height
                        )
                    }
                }
            }
            .transition(
                .scale.combined(
                    with: .opacity
                ).combined(
                    with: .offset(y: -finalSize.height / 2)
                ).animation(vm.animation)
            )
//            .blur(radius: vm.isOpened ? 0 : 32)
        }
        .animation(vm.animation, value: vm.isOpened)
        .animation(vm.animation, value: vm.isAboutOpen)
        .preferredColorScheme(.dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var notch: some View {
        Rectangle()
            .foregroundStyle(.black)
            .mask(notchBackgroundMaskGroup)
            .frame(
                width: notchSize.width + notchCornerRadius * 2,
                height: notchSize.height
            )
            .shadow(
                color: .black.opacity((vm.isOpened || vm.isAboutOpen) ? 1 : 0),
                radius: 16
            )
    }

    var notchBackgroundMaskGroup: some View {
        Rectangle()
            .foregroundStyle(.black)
            .frame(
                width: notchSize.width,
                height: notchSize.height
            )
            .clipShape(.rect(
                bottomLeadingRadius: notchCornerRadius,
                bottomTrailingRadius: notchCornerRadius
            ))
            .overlay {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .frame(width: notchCornerRadius, height: notchCornerRadius)
                        .foregroundStyle(.black)
                    Rectangle()
                        .clipShape(.rect(topTrailingRadius: notchCornerRadius))
                        .foregroundStyle(.white)
                        .frame(
                            width: notchCornerRadius + vm.spacing,
                            height: notchCornerRadius + vm.spacing
                        )
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .offset(x: -notchCornerRadius - vm.spacing + 0.5, y: -0.5)
            }
            .overlay {
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .frame(width: notchCornerRadius, height: notchCornerRadius)
                        .foregroundStyle(.black)
                    Rectangle()
                        .clipShape(.rect(topLeadingRadius: notchCornerRadius))
                        .foregroundStyle(.white)
                        .frame(
                            width: notchCornerRadius + vm.spacing,
                            height: notchCornerRadius + vm.spacing
                        )
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: notchCornerRadius + vm.spacing - 0.5, y: -0.5)
            }
    }
}
