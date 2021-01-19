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
    @State var dataNumber : String = ""     // 追加するデータ数
    @State var count : Int64 = 0            // データ数
    @State var lightInterval: Double = 0    // 軽い版の読み取り時間
    @State var fatInterval: Double = 0      // 重い版の読み取り時間
    @State var lightDataList : LightDataList?
    @State var fatDataList : FatDataList?
    
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
            Spacer()
            // 速度調査：重いデータ、軽いデータの読み込み時間
            HStack {
                // 追加
                Button(action: {
                    getData()
                }) { Text("データ取得") }
                Text("データ数： \(count)")
            }
            HStack{
                Text("軽い場合： \(lightInterval)")
                Text("重い場合： \(fatInterval)")
            }
            HStack {
                TextField("追加するデータ数を入力してください", text: $dataNumber)
                    .keyboardType(.numberPad)
                // 追加
                Button(action: {
                    // 軽い版の追加
                    guard var lightDataList = lightDataList else {
                        return
                    }
                    var start = Int64(lightDataList.list.count)
                    var number = Int64(dataNumber) ?? 0
                    lightDataList.add(start: start, number: number)
                    // 重い版の追加
                    guard var fatDataList = fatDataList else {
                        return
                    }
                    start = Int64(fatDataList.list.count)
                    number = Int64(dataNumber) ?? 0
                    fatDataList.add(start: start, number: number)
                }) { Text("追加") }
            }
            Spacer()
        }
        .onAppear{
            getData()   // 軽いデータと重いデータをCoreDataから取得
        }
    }
    // 軽いデータと重いデータを取得して、取得時間を設定
    func getData(){
        var startDate : Date
        // 軽い版の時間の計測
        startDate = Date()
        // データの取得
        self.lightDataList?.list = []
        self.lightDataList = LightDataList(viewContext:viewContext)
        self.lightInterval = Date().timeIntervalSince(startDate)
        
        // 重い版の時間の計測
        startDate = Date()
        // データの取得
        self.fatDataList?.list = []
        self.fatDataList = FatDataList(viewContext:viewContext)
        self.fatInterval = Date().timeIntervalSince(startDate)
        
        self.count = Int64((lightDataList?.list.count)!)
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
