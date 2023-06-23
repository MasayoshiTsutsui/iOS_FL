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
        self.performSegue(withIdentifier: "toMenuView", sender: nil)
    }
}
