//
//  NotchSeetingsView.swift
//  NotchDrop
//
//  Created by 曹丁杰 on 2024/7/29.
//

import SwiftUI
import LaunchAtLogin

struct NotchSettingsView: View {
    @StateObject var vm: NotchViewModel

    var body: some View {
        VStack(spacing: vm.spacing) {
            HStack {
                Picker("Language: " , selection: $vm.selectedLanguage) {
                    ForEach(NotchViewModel.Language.allCases) { language in
                        Text(language.localized).tag(language)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: vm.selectedLanguage == .simplifiedChinese || vm.selectedLanguage == .traditionalChinese ? 220 : 160)
                
                LaunchAtLogin.Toggle{
                    Text(NSLocalizedString("Launch at Login", comment: ""))
                
                }
                    .padding(.leading, 60) // Adjust the padding to reduce the space
                Spacer()
            }
            .padding(.vertical, 5)

            HStack {
                Picker("File Storage Time: ", selection: $vm.selectedFileStorageTime) {
                    ForEach(NotchViewModel.FileStorageTime.allCases) { time in
                        Text(time.localized).tag(time)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200)

                // Custom Storage Time (if custom is selected)
                if vm.selectedFileStorageTime == .custom {
                    TextField("Days", value: $vm.customStorageTime, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .padding(.leading, 10)
                    Picker("", selection: $vm.customStorageTimeUnit) {
                        ForEach(NotchViewModel.CustomstorageTimeUnit.allCases) { unit in
                            Text(unit.localized).tag(unit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 90)
                }
                Spacer()
            }
            .padding(.vertical, 5)
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
