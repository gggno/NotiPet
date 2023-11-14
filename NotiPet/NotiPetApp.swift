//
//  NotiPetApp.swift
//  NotiPet
//
//  Created by 정근호 on 11/14/23.
//

import SwiftUI

@main
struct NotiPetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
