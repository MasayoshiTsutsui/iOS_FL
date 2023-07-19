import UIKit
import CoreML

class CameraPredictViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var model: MLModel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /// UIImagePickerController カメラを起動する
    /// - Parameter sender: "UIImagePickerController"ボタン
    @IBAction func startUiImagePicker(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        // UIImagePickerController カメラを起動する
        present(picker, animated: true, completion: nil)
        print("camera on!")
    }

    /// シャッターボタンを押下した際、確認メニューに切り替わる
    /// - Parameters:
    ///   - picker: ピッカー
    ///   - info: 写真情報
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("image picker !!!")
        let image = info[.originalImage] as! UIImage

        dismiss(animated: true) {
            self.performSegue(withIdentifier: "showPrediction", sender: image)
            print("to showPrediction!!!!")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPrediction" {
            let predictionViewController = segue.destination as! PredictionViewController
            predictionViewController.image = sender as? UIImage
            predictionViewController.model = model
        }
    }
}

