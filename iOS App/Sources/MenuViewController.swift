import UIKit
import CoreML

/**
  The app's main screen.
 */
class MenuViewController: UITableViewController {
  @IBOutlet var backgroundTrainingSwitch: UISwitch!

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: nil, action: nil)

    Models.copyEmptyNearestNeighbors()
    Models.copyEmptyNeuralNetwork()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "TrainingData" {
      let viewController = segue.destination as! DataViewController
      viewController.imagesByLabel = ImagesByLabel(dataset: trainingDataset)
      viewController.title = "Training Data"
    }
    else if segue.identifier == "TestingData" {
      let viewController = segue.destination as! DataViewController
      viewController.imagesByLabel = ImagesByLabel(dataset: testingDataset)
      viewController.title = "Testing Data"
    }
    else if segue.identifier == "TrainNeuralNetwork" {
      let viewController = segue.destination as! TrainNeuralNetworkViewController
      viewController.model = Models.loadTrainedNeuralNetwork()
      viewController.trainingDataset = trainingDataset
      viewController.validationDataset = testingDataset
    }
    else if segue.identifier == "EvaluateNeuralNetwork" {
      let viewController = segue.destination as! EvaluateViewController
      viewController.model = Models.loadTrainedNeuralNetwork()
      viewController.dataset = testingDataset
      viewController.title = "Neural Network"
    }
    else if segue.identifier == "CameraPredictNeuralNetwork" {
      let viewController = segue.destination as! CameraPredictViewController
      //viewController.model = Models.loadTrainedNeuralNetwork()
      //viewController.title = "Neural Network"
    }
  }

  @IBAction func loadBuiltInDataSet() {
    trainingDataset.copyBuiltInImages()
    testingDataset.copyBuiltInImages()
  }

  @IBAction func resetToEmptyNearestNeighbors() {
    Models.deleteTrainedNearestNeighbors()
    Models.copyEmptyNearestNeighbors()
  }

  @IBAction func resetToEmptyNeuralNetwork() {
    Models.deleteTrainedNeuralNetwork()
    Models.copyEmptyNeuralNetwork()
    history.delete()
  }

  @IBAction func resetToTuriNeuralNetwork() {
    Models.deleteTrainedNeuralNetwork()
    Models.copyTuriNeuralNetwork()
    history.delete()
  }

}
