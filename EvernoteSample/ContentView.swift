//
//  ContentView.swift
//  EvernoteSample
//
//  Created by 小田匠 on 2022/04/09.
//
//

import SwiftUI
import EvernoteSDK

struct ContentView: View {
    @State var prepareSentEvernote = false
    @State var text = ""
    @State var bookName = ""
    @State var noteName = ""
    @State var noteBook: ENNotebook?

    var body: some View {
        EvernoteViewControllerWrapper().frame(height: 0)
        VStack {
            TextEditor(text: $text).frame(width: 300, height: 300).border(Color.gray, width: 1)
            if (prepareSentEvernote) {
                EvernoteViewControllerWrapper().frame(height: 0)
            } else {
                // 認証確認
                Button(action: {
                    prepareSentEvernote = true
                }) {
                    Text("認証確認")
                }
            }
            if (prepareSentEvernote) {
                VStack {
                    Button(action: {
                        setNoteBookIfExist()
                        //var searchText = "intitle:\"\(noteName)\""
                        var enNoteSearch = ENNoteSearch(search: noteName)
                        //enNoteSearch.searchString = noteName
                        //print("searchText:\(noteName.description)")
                        print("noteName:\(noteName.description)")
                        print("noteBook:\(noteBook?.description)")
                        var filter = EDAMNoteFilter()
                        filter.words = noteName
                        let store = ENSession.shared.noteStore(for: noteBook!)
                        let resultSpec = EDAMNotesMetadataResultSpec()
                        resultSpec.includeTitle = 1
                        store?.findNotesMetadata(with: filter, maxResults: 5, resultSpec: resultSpec, success: { metaLists in
                            for result in metaLists ?? [] {
                                print(result.description)
                            }
                            print("success")
                        }
                                , failure: {
                            error in print(error)
                        })
                        // ENSession.shared.findNotesだとENNoteSearchを使ってもうまくいかない。これをnilにすればいけるけど。。
                        //https://stackoverflow.com/questions/57938109/how-do-i-list-notes-from-evernotenotestoreclient-findnotes-when-the-notefilt

                        //https://discussion.evernote.com/forums/topic/120740-searching-is-not-working-in-sandbox-environment/
//                        ENSession.shared.findNotes(with: enNoteSearch,
//                                in: noteBook,
//                                orScope: [],
//                                sortOrder: .recentlyCreated,
//                                maxResults: 5) { (findNotesResults: [ENSessionFindNotesResult]?, error: Error?) in
//                            if (findNotesResults == nil || findNotesResults!.isEmpty) {
//                                print("not Found")
//                            } else {
//                                for result in findNotesResults ?? [] {
//                                    print(result.description)
//                                }
//                            }
//                        }
//                        let note = ENNote()
//                        note.content = ENNoteContent(string: text)
//                        note.title = noteName
//                        ENSession.shared.upload(note, notebook: noteBook) { (noteRef: ENNoteRef?, error: Error?) in
//                            print("created note")
//                        }
                    }) {
                        Text("ノートがあるか")
                    }
                    Button(action: {
                        var hasNote = setNoteBookIfExist()
                        if (!hasNote) {
                            createNoteBook()
                        }

                        let note = ENNote()
                        note.content = ENNoteContent(string: text)
                        note.title = noteName
                        ENSession.shared.upload(note, notebook: noteBook) { (noteRef: ENNoteRef?, error: Error?) in
                            print("created note")
                        }
                    }) {
                        Text("ノート新規追加")
                    }
                    Button(action: {
                        let noteBook = ENNotebook()
                        ENSession.shared.listNotebooks { notebooks, listNotebooksError in
                            if let notebooks = notebooks {
                                for book in notebooks {
                                    print(book)
                                }
                            }
                        }
                    }) {
                        Text("ノートブック一覧")
                    }
                    Button(action: {
                        var hasNote = setNoteBookIfExist()
                        if (!hasNote) {
                            createNoteBook()
                        }
                    }) {
                        Text("ノートブック設定")
                    }
                    Button(action: {
                        createNoteBook()
                    }) {
                        Text("ノートブック作成")
                    }
                    Button(action: {
                        ENSession.shared.unauthenticate()
                    }) {
                        Text("ログアウト")
                    }
                }

            }
        }
                .onAppear {
                    ENSession.setSharedSessionConsumerKey(accessTokenKey, consumerSecret: accessTokenSecret, optionalHost: nil)
                    let bookFormatter = DateFormatter()
                    bookFormatter.dateFormat = "yyyy"
                    bookName = bookFormatter.string(from: Date())
                    let noteFormatter = DateFormatter()
                    noteFormatter.dateFormat = "yyyyMMdd"
                    noteName = noteFormatter.string(from: Date())
                }
    }

    private func setNoteBookIfExist() -> Bool {
        var hasNote = false
        ENSession.shared.listNotebooks { notebooks, listNotebooksError in
            if let notebooks = notebooks {
                for book in notebooks {
                    if (book.name == bookName) {
                        noteBook = book
                        hasNote = true
                    }
                }
            }
        }
        return hasNote
    }

    private func createNoteBook() {
        let noteContext = EDAMNotebook()
        noteContext.name = bookName
        noteBook = ENNotebook(notebook: noteContext)
        var storeClient = ENSession.shared.noteStore(for: noteBook!)
        storeClient!.create(noteContext, completion: { notebook, error in
            print(error)
            print("ノートブック作成完了")
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
