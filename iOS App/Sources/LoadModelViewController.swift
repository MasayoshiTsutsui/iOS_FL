//
//  LoadModelViewController.swift
//  Gestures
//
//  Created by Masayoshi Tsutsui on 2023/06/23.
//  Copyright © 2023 MachineThink. All rights reserved.
//

import SwiftUI
import UIKit
import CoreML

class LoadModelViewController: UIViewController {
    @IBOutlet var loadModelButton: UIButton!


    @IBAction func loadLatestModel() {
        print("loadLatestModel called!")
        self.loadModelButton.setTitle("モデルを\nロード中...", for: .normal)
        self.loadModelButton.setTitleColor(.systemBlue, for: .normal)
        
        loadModelFromServer { success in
            DispatchQueue.main.async {
                if success {
                    self.loadModelButton.setTitle("最新のモデルが\nロードされました！", for: .normal)
                    self.loadModelButton.setTitleColor(.systemGreen, for: .normal)
                    print("最新のモデルがloadされました！")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.performSegue(withIdentifier: "toMenuView", sender: nil)
                    }
                } else {
                    self.loadModelButton.setTitle("モデルのロードに失敗しました.\n通信環境を確認してください.", for: .normal)
                    self.loadModelButton.setTitleColor(.systemRed, for: .normal)
                    print("モデルの読み込みに失敗しました.")
                }
            }
        }
    }
    private func loadModelFromServer(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://mobile-federated-learning.com/load-model") else {
            completion(false)
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }

            // ファイルのダウンロードが成功した場合、urlに保存されているローカルファイルにアクセスできます
            if let localURL = url {
                let fileManager = FileManager.default
                let destinationURL = self.getDestinationURL(for: "Hands2num_latest.mlmodel")
                let compiledDestURL = self.getDestinationURL(for: "Hands2num_latest.mlmodelc")
                do {
                    try? fileManager.removeItem(at: destinationURL) // 既存のファイルがある場合は削除
                    try fileManager.moveItem(at: localURL, to: destinationURL) // mlmodelファイルをリネームして移動
                    try? fileManager.removeItem(at: compiledDestURL) // 既存のファイルがある場合は削除
                    let compiledURL = try MLModel.compileModel(at: destinationURL)
                    try fileManager.moveItem(at: compiledURL, to: compiledDestURL) // ファイルをリネームして移動
                    print("Compiled mlmodel file: \(compiledDestURL.lastPathComponent)")
                    print("Downloaded file: \(destinationURL.lastPathComponent)")
                    completion(true)
                } catch {
                    print("Error moving file: \(error)")
                    completion(false)
                }
            } else {
                print("Error: Failed to download the file")
                completion(false)
            }
        }
        task.resume()
    }

    private func getDestinationURL(for fileName: String) -> URL {
        // ファイルを保存するディレクトリのパスを取得
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // ファイル名を結合して保存先のURLを生成
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)
        return destinationURL
    }
}

func printFilesInDocumentsDirectory() {
    let fileManager = FileManager.default
    do {
        let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        for fileURL in fileURLs {
            print(fileURL.lastPathComponent)
        }
    } catch {
        print("Error accessing Documents directory: \(error)")
    }
}

