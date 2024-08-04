//
//  NotchSettingsView.swift
//  NotchDrop
//
//  Created by 曹丁杰 on 2024/7/29.
//

import LaunchAtLogin
import SwiftUI

struct NotchSettingsView: View {
    @StateObject var vm: NotchViewModel
    @StateObject var tvm: TrayDrop = .shared

    var body: some View {
        VStack(spacing: vm.spacing) {
            HStack {
                Picker("Language: ", selection: $vm.selectedLanguage) {
                    ForEach(Language.allCases) { language in
                        Text(language.localized).tag(language)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: vm.selectedLanguage == .simplifiedChinese || vm.selectedLanguage == .traditionalChinese ? 220 : 160)

                LaunchAtLogin.Toggle {
                    Text(NSLocalizedString("Launch at Login", comment: ""))
                }
                .padding(.leading, 60) // Adjust the padding to reduce the space

                Spacer()
            }

            HStack {
                Picker("File Storage Time: ", selection: $tvm.selectedFileStorageTime) {
                    ForEach(TrayDrop.FileStorageTime.allCases) { time in
                        Text(time.localized).tag(time)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200)
                if tvm.selectedFileStorageTime == .custom {
                    TextField("Days", value: $tvm.customStorageTime, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .padding(.leading, 10)
                    Picker("Time Unit", selection: $tvm.customStorageTimeUnit) {
                        ForEach(TrayDrop.CustomstorageTimeUnit.allCases) { unit in
                            Text(unit.localized).tag(unit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                }
                Spacer()
            }
        }
        .padding()
        .transition(.scale(scale: 0.8).combined(with: .opacity))
    }
}

#Preview {
    NotchSettingsView(vm: .init())
        .padding()
        .frame(width: 600, height: 150, alignment: .center)
        .background(.black)
        .preferredColorScheme(.dark)
}
