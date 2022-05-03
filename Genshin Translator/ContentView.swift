//
//  ContentView.swift
//  Genshin Translator
//
//  Created by shiki on 2022/05/03.
//  ver 1.0
//

import SwiftUI

struct Example: Codable, Hashable {
    var en: String
    var ja: String
    var ref: String
    var refURL: String
}

struct Word: Codable, Hashable{
    var id: String
    var en: String
    var ja: String
    var pronunciationJa: String?
}

extension String {
    var kana: String? {
        return self.applyingTransform(.hiraganaToKatakana, reverse: false)
    }
    var hiragana: String? {
        return self.applyingTransform(.hiraganaToKatakana, reverse: true)
    }
}

struct ContentView: View {
    
    @State var searchText: String = ""
    @State var enToJa: Bool = false
    @State var count = 1
    @State var showCopyMessage = false
    
    let words: [Word] = Bundle.main.decodeJSON("words.json")
    
    var suggest: [Word] {

        return words.filter {
            
            if !enToJa {
                if $0.pronunciationJa != nil {
                    return $0.pronunciationJa!.hiragana!.uppercased().contains(searchText.uppercased().hiragana!) || $0.ja.hiragana!.uppercased().contains(searchText.uppercased().hiragana!)
                } else {
                    return $0.ja.hiragana!.uppercased().contains(searchText.uppercased().hiragana!)
                }
            } else {
                return $0.en.uppercased().contains(searchText.uppercased())
            }
        }
    }
    
    var body: some View {
        
        
        
        VStack{
            
            TextField("調べたい言葉を入力", text: $searchText)
                .padding(10)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Toggle("英語で検索", isOn: $enToJa)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .padding()
            
            if self.showCopyMessage {
                Text("コピーしました")
            } else {
                Text("タップして英語をコピー")
            }
            
            List {
                ForEach(suggest, id: \.self) { data in
                    Button {
                        UIPasteboard.general.string = data.en
                        self.showCopyMessage = true
                        self.count = 1
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {timer in
                                        self.count -= 1
                                        if self.count == 0 {
                                            // 現在のカウントが0になったらtimerを終了させ、カントダウン終了状態に更新
                                            timer.invalidate()
                                            self.showCopyMessage = false
                                        }
                                    }
                    } label: {
                        VStack{
                            Text(data.ja)
                            Text(data.en)
                            
                        }
                            .frame(maxWidth: .infinity, maxHeight:.infinity)
                            .padding(10)
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
