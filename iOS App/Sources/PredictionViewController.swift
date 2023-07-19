//
//  PredictionViewController.swift
//  Gestures
//
//  Created by Masayoshi Tsutsui on 2023/07/14.
//  Copyright © 2023 MachineThink. All rights reserved.
//
import CoreML
import Vision
import SwiftUI

class PredictionViewController: UIViewController {
    @IBOutlet var imageview: UIImageView!
    var image: UIImage!
    @IBOutlet var predictedLabel: UILabel!
    @IBOutlet var confidence: UILabel!
    
    var model: MLModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageview.image = self.image

        if let image = self.image {
            performPrediction(image)
        }
    }

    func performPrediction(_ image: UIImage) {
        guard let model = try? VNCoreMLModel(for: self.model) else {
            print("Failed to create VNCoreMLModel")
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Prediction error: \(error)")
                return
            }

            guard let results = request.results as? [VNClassificationObservation], let firstResult = results.first else {
                print("No results found")
                return
            }

            self.predictedLabel.text = firstResult.identifier
            self.confidence.text = "Confidence: " + String(Int(firstResult.confidence * 100)) + " %"

            print("Predicted label: \(self.predictedLabel.text!), confidence: \(self.confidence.text!)")
        }

        guard let ciImage = CIImage(image: image) else {
            print("Failed to create CIImage from the input image")
            return
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print("Prediction request failed: \(error)")
        }
    }

}
