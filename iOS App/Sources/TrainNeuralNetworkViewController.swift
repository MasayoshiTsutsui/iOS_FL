import UIKit
import CoreML

/**
  View controller for the "Training Neural Network" screen.
 */
class TrainNeuralNetworkViewController: UIViewController {
  @IBOutlet var oneEpochButton: UIButton!
  @IBOutlet var tenEpochsButton: UIButton!
  @IBOutlet var stopButton: UIButton!
  @IBOutlet var learningRateLabel: UILabel!
  @IBOutlet var learningRateSlider: UISlider!
  @IBOutlet var augmentationSwitch: UISwitch!
  @IBOutlet var statusLabel: UILabel!
  @IBOutlet var tableView: UITableView!
  @IBOutlet var headerLabel: UILabel!
  @IBOutlet var graphView: GraphView!
  @IBOutlet var submitButton: UIButton!

  var model: MLModel!
  var trainingDataset: ImageDataset!
  var validationDataset: ImageDataset!
  var trainer: NeuralNetworkTrainer!
  var isTraining = false
  var doneTraining = false

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = 32
    tableView.separatorInset = .zero
    tableView.contentInset = .zero

    stopButton.isEnabled = false
    statusLabel.text = "Paused"
    augmentationSwitch.isOn = settings.isAugmentationEnabled

    learningRateSlider.value = Float(log10(settings.learningRate))
    learningRateLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
    updateLearningRateLabel()

    headerLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    headerLabel.sizeToFit()

    /*trainer = NeuralNetworkTrainer(modelURL: Models.trainedNeuralNetworkURL,
                                   trainingDataset: trainingDataset,
                                   validationDataset: validationDataset,
                                   imageConstraint: imageConstraint(model: model))
     */
    printFilesInDocumentsDirectory()
    print(Models.Hands2numURL)
    trainer = NeuralNetworkTrainer(modelURL: Models.Hands2numURL,
                                   trainingDataset: trainingDataset,
                                   validationDataset: validationDataset,
                                   imageConstraint: imageConstraint(model: model))

    assert(model.modelDescription.isUpdatable)
    //print(model.modelDescription.trainingInputDescriptionsByName)

    NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
  }

  deinit {
    print(self, #function)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print(self, #function)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // The user tapped the back button.
    stopTraining()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    graphView.update()
  }

  @objc func appWillResignActive() {
    stopTraining()
  }

  @IBAction func oneEpochTapped(_ sender: Any) {
    startTraining(epochs: 1)
  }

  @IBAction func tenEpochsTapped(_ sender: Any) {
    startTraining(epochs: 10)
  }

  @IBAction func stopTapped(_ sender: Any) {
    stopTraining()
  }
  @IBAction func submitTapped(_ sender: Any) {
    if submitModelParams(self.model) {
      self.performSegue(withIdentifier: "toSubmitSucceed", sender: nil)
    }
  }

  @IBAction func learningRateSliderMoved(_ sender: UISlider) {
    settings.learningRate = pow(10, Double(sender.value))
    updateLearningRateLabel()
  }

  @IBAction func augmentationSwitchTapped(_ sender: UISwitch) {
    settings.isAugmentationEnabled = sender.isOn
  }

  func updateLearningRateLabel() {
    learningRateLabel.text = String(String(format: "%.6f", settings.learningRate).prefix(8))
  }

  func updateButtons() {
    oneEpochButton.isEnabled = !isTraining
    tenEpochsButton.isEnabled = !isTraining
    learningRateSlider.isEnabled = !isTraining
    augmentationSwitch.isEnabled = !isTraining
    stopButton.isEnabled = isTraining
    submitButton.isEnabled = doneTraining && !isTraining
  }
}

extension TrainNeuralNetworkViewController {
  func startTraining(epochs: Int) {
    guard trainingDataset.count > 0 else {
      statusLabel.text = "No training images"
      return
    }

    isTraining = true
    statusLabel.text = "Training..."
    updateButtons()

    trainer.train(epochs: epochs, learningRate: settings.learningRate, callback: trainingCallback)
  }

  func stopTraining() {
    trainer.cancel()
    trainingStopped()
  }

  func trainingStopped() {
    isTraining = false
    doneTraining = true
    statusLabel.text = "Paused"
    updateButtons()
  }

  func trainingCallback(callback: NeuralNetworkTrainer.Callback) {
    DispatchQueue.main.async {
      switch callback {
      case let .epochEnd(trainLoss, valLoss, valAcc):
        history.addEvent(trainLoss: trainLoss, validationLoss: valLoss, validationAccuracy: valAcc)

        let indexPath = IndexPath(row: history.count - 1, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .fade)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        self.graphView.update()

      case .completed(let updatedModel):
        self.trainingStopped()

        // Replace our model with the newly trained one.
        self.model = updatedModel

      case .error:
        self.trainingStopped()
      }
    }
  }
}

extension TrainNeuralNetworkViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    history.count
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    32
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
    cell.textLabel?.text = history.events[indexPath.row].displayString
    return cell
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.textLabel?.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
  }
}

fileprivate extension History.Event {
  var displayString: String {
    var s = String(format: "%5d   ", epoch + 1)
    s += String(String(format: "%6.4f", trainLoss).prefix(6))
    s += "   "
    s += String(String(format: "%6.4f", validationLoss).prefix(6))
    s += "     "
    s += String(String(format: "%5.2f", validationAccuracy * 100).prefix(5))
    return s
  }
}
    
func submitModelParams(_ model: MLModel) -> Bool {
  guard let weights = try? model.parameterValue(for: MLParameterKey.weights.scoped(to: "fullyconnected0")) as? MLMultiArray else {
      print("Failed to retrieve weights of the fullyconnected0 layer")
      return false
  }
    
  guard let biases = try? model.parameterValue(for: MLParameterKey.biases.scoped(to: "fullyconnected0")) as? MLMultiArray else {
      print("Failed to retrieve biases of the fullyconnected0 layer")
      return false
  }

  let rawWeights = convertToRegularArray(weights)
  let rawBiases = convertToRegularArray(biases)

  guard let url = URL(string: "https://mobile-federated-learning.com/submit-params") else {
      print("Invalid URL")
      return false
  }
    
  // Create the request body as a dictionary
  let requestBody: [String: Any] = [
      "weights": rawWeights,
      "biases": rawBiases
  ]
    
  do {
      // Convert the request body to JSON data
      let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
      // Create the URL request
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = jsonData
        
      // Perform the request
      let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
          if let error = error {
              print("Error: \(error)")
              return
          }
            
          // Handle the response if needed
          if let httpResponse = response as? HTTPURLResponse {
              print("Response status code: \(httpResponse.statusCode)")
              // Handle the response data if needed
              if let responseData = data {
                  let responseString = String(data: responseData, encoding: .utf8)
                  print("Response data: \(responseString ?? "")")
              }
          }
      }
      task.resume()
  } catch {
      print("Error creating JSON data: \(error)")
  }
  return true
}


func convertToRegularArray(_ multiArray: MLMultiArray) -> [Float] {
  var array = [Float]()
  let count = multiArray.count
  let pointer = UnsafeMutablePointer<Float>(OpaquePointer(multiArray.dataPointer))
  for i in 0..<count {
      let value = pointer[i]
      array.append(value)
  }
  return array
}
