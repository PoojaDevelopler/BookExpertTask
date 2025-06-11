//
//  NotificationView.swift
//  BookExpertTask
//
//  Created by pnkbksh on 12/06/25.
//

import SwiftUI

struct NotificationView: View {
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true

    var body: some View {
        Form {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NotificationView()
}
