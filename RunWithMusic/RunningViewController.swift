//
//  RunningViewController.swift
//  RunWithMusic
//
//  Created by Rocky Leo on 12/8/18.
//  Copyright © 2018 Mingze Sun. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import CoreMotion
import CoreML

class RunningViewController: UIViewController {
    var musicTalbleVC: MuiscListViewController!
    private var mainVC: MainMusicViewController!
    
    fileprivate var modalVC :DetailMusicViewController!
    private var animator : ARNTransitionAnimator?
    var musicModel:Music?
    var musicArry:Array<Music>!
    var musicnumber:Int!
    var nowNum:Int!

    var startTime: NSDate?
    var cadenceArray: [Double] = []
    var count = 1
    var ringBuffer = RingBuffer()
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let pedometer1 = CMPedometer()
    var modelRf = RandomForestAccel()
    
    
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var predictResult: UILabel!
    @IBOutlet weak var currentCadenceLabel: UILabel!
    @IBOutlet weak var dataStatus: UILabel!
    @IBOutlet weak var musicList: UITextField!
    @IBOutlet weak var RunningDistance: UILabel!
    @IBOutlet weak var AveragePace: UILabel!
    @IBOutlet weak var runningTime: UILabel!
    var isCadenceAvailable:Bool {
        get { return CMPedometer.isCadenceAvailable()}
    }
    
    var isDistanceAvailable:Bool {
        get { return CMPedometer.isDistanceAvailable() }
    }
    
    var isPaceAvailable:Bool {
        get { return CMPedometer.isPaceAvailable() }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.button0.layer.cornerRadius = 4.5
        button0.layer.cornerRadius = 6
        button0.layer.borderWidth = 1
        button0.layer.borderColor = UIColor.black.cgColor
        
        button1.layer.cornerRadius = 6
        button1.layer.borderWidth = 1
        button1.layer.borderColor = UIColor.black.cgColor
        
        startTime = NSDate()
        NSLog("startTiem: ")
        print(startTime!)
        //startPedometerMonitoring()
        self.dataStatus.text = ("Wait to Collect Data! ")
        self.musicArry=Music.getALL()
        
    }
    
    // Do any additional setup after loading the view.
    func startPedometerCadenceMonitoring(){
        //separate out the handler for better readability
        if CMPedometer.isCadenceAvailable(){
            pedometer.startUpdates(from: Date(),
                                   withHandler: handlePedometer)
        }
        //        if CMPedometer.isPaceAvailable(){
        //            pedometer.startUpdates(from: Date(),
        //                                   withHandler: handlePedometer)
        //        }
    }
    
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?)->(){
        if let currentCadence = pedData?.currentCadence{
            //self.RunningCadence.text = "Cadence : \(pedData?.currentCadence ?? 0)"
            let dCadence = Double(currentCadence)
            NSLog("***************currentCadence  %f", dCadence)
            var RunBPM:Double = 60.0 * dCadence
            cadenceArray.append(RunBPM)
            self.ringBuffer.addNewData(xData: RunBPM)
            DispatchQueue.main.async {
                self.currentCadenceLabel.text = "currentCadence : " + String (RunBPM)
                if( self.cadenceArray.count == 20){
                    self.stopUpdates()
//                //cadenceArray = []
                NSLog(" finish collecting test1 data ")
                
                // predict
                    let seq = self.toMLMultiArray(self.ringBuffer.getDataAsVector())
                    guard let outputRf = try? self.modelRf.prediction(input: seq) else {
                    fatalError("Unexpected runtime error.")
                        
                    }
                    DispatchQueue.main.async{
                    self.dataStatus.text = ("We finished collect data!")
                    self.predictResult.text = ("Predict result:  " + String(outputRf.classLabel))
                    }
                    NSLog("prediction result  %d", outputRf.classLabel)
                    self.musicnumber = Int(outputRf.classLabel)
                    self.nowNum=self.musicnumber-1
                    if self.musicnumber>=self.musicArry.count{
                        self.nowNum=1
                    }
                    if AudioPlayer.nextsong(num: self.nowNum){
                    
                    //  reflashView(num: self.nowNum)
                    }
                }
            }
        }
    }
    
    func startPedometerMonitoring(){
        //separate out the handler for better readability
        if CMPedometer.isPaceAvailable(){
            pedometer1.startUpdates(from: Date(),
                                   withHandler: handlePedometer1)
        }
    }
    func handlePedometer1(_ pedData:CMPedometerData?, error:Error?)->(){
        if let runningDistance = pedData?.distance{
            DispatchQueue.main.async{
            print("pedometer1 is monitoring")
            self.RunningDistance.text = "Running Distance : \(pedData?.distance ?? 0)"
            var endTime : NSDate
            endTime = NSDate()
            let second = endTime.timeIntervalSince(self.startTime! as Date)
            let second_copy = round(second)
            self.runningTime.text = "Running Time : " + String(second_copy) + "s"
            self.AveragePace.text = "Average Pace : \(pedData?.averageActivePace ?? 0)"
            }
        }
    }
    
    
    func stopUpdates(){
        pedometer.stopUpdates()
    }
    
    // convert to ML Multi array
    // https://github.com/akimach/GestureAI-CoreML-iOS/blob/master/GestureAI/GestureViewController.swift
    private func toMLMultiArray(_ arr: [Double]) -> MLMultiArray {
        guard let sequence = try? MLMultiArray(shape:[20], dataType:MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray could not be created")
        }
        let size = Int(truncating: sequence.shape[0])
        for i in 0..<size {
            sequence[i] = NSNumber(floatLiteral: arr[i])
        }
        return sequence
    }
    
    
    @IBAction func musicChooseButton(_ sender: UIButton) {
        self.dataStatus.text = ("We are collecting Data!")
        NSLog("Start collecting! ")
        cadenceArray = []
        startPedometerCadenceMonitoring()
    }
    
    @IBAction func pdeometer1(_ sender: UIButton) {
        startPedometerMonitoring()
    }
    
}



/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */
