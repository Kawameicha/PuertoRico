//
//  iOSCheckboxToggleStyle.swift
//  PuertoRico
//
//  Created by Christoph Freier on 04.04.26.
//

import SwiftUI

struct iOSCheckboxToggleStyle: ToggleStyle {

        func makeBody(configuration: Configuration) -> some View {

            Button(action: {
                configuration.isOn.toggle()
            }, label: {
                HStack {
                    Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    configuration.label
                }
            })
        }
    }
