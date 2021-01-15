//
//  ContentView.swift
//  Sample8-CoreData
//
//  Created by keiji yamaki on 2021/01/13.
//

import SwiftUI

var testData = TestData(name:"aaa", favoriteColor: .white, rect: CGRect(x:10, y:20, width:100, height:50))

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var fileDataList : FileDataArray
    @State var key : String = ""
    @State var data : String = ""

    
    var body: some View {
        VStack {
            TextField("キーを入力してください", text: $key)
                .padding()
            Text(data)
                .padding()
            HStack {
                Spacer()
                // 追加
                Button(action: {
                    
                    testData = TestData(name:"aaa", favoriteColor: .white, rect: CGRect(x:10, y:20, width:100, height:50))

                }) {
                    Text("画像追加")
                    }
                Spacer()
                // 追加
                Button(action: {
                    fileDataList.add(key: key)
                }) {
                    Text("追加")
                    }
                Spacer()
                // 読み込み
                Button(action: {
                    fileDataList.load(viewContext: viewContext, key: key)
                    data = fileDataList.getStringData()
                }) {
                    Text("読み込み")
                    }
                Spacer()
                // 保存
                Button(action: {
                    fileDataList.save(viewContext: viewContext)
                }) {
                    Text("保存")
                    }
                Spacer()
            }
        }
    }
}
/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .onAppear{
                
            }
    }
}
*/
