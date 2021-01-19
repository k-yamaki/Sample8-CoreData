//
//  ContentView.swift
//  Sample8-CoreData
//
//  Created by keiji yamaki on 2021/01/13.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var fileDataList : FileDataArray?
    @State var key : String = ""
    @State var data : String = ""
    @State var dataNumber : String = "" // 追加するデータ数
    
    var body: some View {
        VStack {
            // 基本機能：CoreDataへの追加、読み込み
            TextField("キーを入力してください", text: $key)
                .padding()
            Text(data)
                .padding()
            HStack {
                Spacer()
                // 追加
                Button(action: {
                    fileDataList!.add(key: key)
                }) { Text("追加") }
                Spacer()
                // 読み込み
                Button(action: {
                    fileDataList = FileDataArray(key: key, viewContext: viewContext)
                    data = fileDataList!.getStringData()
                }) { Text("読み込み") }
                Spacer()
            }
            // 速度調査：重いデータ、軽いデータの読み込み時間
            HStack {
                TextField("追加するデータ数を入力してください", text: $dataNumber)
                    .keyboardType(.numberPad)
                // 追加
                Button(action: {
                    fileDataList!.add(key: key)
                }) { Text("追加") }
            }
        }
        .onAppear{
            fileDataList = FileDataArray(viewContext:viewContext)
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
