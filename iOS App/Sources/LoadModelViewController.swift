//
//  LoadModelViewController.swift
//  Gestures
//
//  Created by Masayoshi Tsutsui on 2023/06/23.
//  Copyright © 2023 MachineThink. All rights reserved.
//

import SwiftUI
import UIKit

class LoadModelViewController: UIViewController {
    @IBOutlet var loadModelButton: UIButton!


    @IBAction func loadLatestModel() {
        print("loadLatestModel called!")
        self.loadModelButton.setTitle("Loading the latest model...", for: .normal)
        self.loadModelButton.setTitleColor(.systemBlue, for: .normal)
        
        loadModelFromServer { success in
            DispatchQueue.main.async {
                if success {
                    self.loadModelButton.setTitle("Load Successful", for: .normal)
                    self.loadModelButton.setTitleColor(.systemGreen, for: .normal)
                    print("最新のモデルがloadされました！")
                } else {
                    self.loadModelButton.setTitle("Load Failed", for: .normal)
                    self.loadModelButton.setTitleColor(.systemRed, for: .normal)
                    print("モデルの読み込みに失敗しました.")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.performSegue(withIdentifier: "toMenuView", sender: nil)
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
                
                do {
                    try? fileManager.removeItem(at: destinationURL) // 既存のファイルがある場合は削除
                    try fileManager.moveItem(at: localURL, to: destinationURL) // ファイルをリネームして移動
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
