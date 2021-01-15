//
//  Sample8_CoreDataApp.swift
//  Sample8-CoreData
//
//  Created by keiji yamaki on 2021/01/13.
//

import SwiftUI

@main
struct Sample8_CoreDataApp: App {
    @State var fileDataList = FileDataArray()
    let persistenceController = MyPersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(fileDataList: $fileDataList)
                // 共有のCoreData
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
