//
//  Bluetooth.swift
//  HeartBeat
//
//  Created by inailuy on 6/30/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import CoreBluetooth

class Bluetooth: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    enum HeartRate: String {
        case Service = "180D"
        case Measurement = "2A37"
    }
    enum PolarCharacteristicUUID: String {
        case Measurement = "2A37"
        case BodyLocation = "2A38"
        case ManufacturerName = "2A29"
    }
    
    static let sharedInstance = Bluetooth()
    var beatPerMinuteValue = 0
    var centralManager = CBCentralManager()
    var activePeripheral : CBPeripheral!
    var peripheralStatusString = String()
    var peripheralArray = NSMutableArray()
    var isFirstLaunch = Bool()
    var isWorkoutControllerActive = Bool()
    
    func load() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        let myServiceUUID = CBUUID(string: HeartRate.Service.rawValue)
        centralManager.scanForPeripheralsWithServices([myServiceUUID], options: nil)
        isFirstLaunch = true
    }  
    //MARK: CBCentralManagerDelegate
    @objc func centralManagerDidUpdateState(central: CBCentralManager) {
        peripheralStatusString = "centralManagerDidUpdateState " + String(central.state)
        if central.state == .PoweredOn {
            peripheralStatusString = "Scanning For Peripherals"
            let myServiceUUID = CBUUID(string: HeartRate.Service.rawValue)
            centralManager.scanForPeripheralsWithServices([myServiceUUID], options: nil)
        }
        printStatus()
    }
    
    @objc func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        peripheralStatusString = "Did Discorver Peripheral"
        activePeripheral = peripheral
        peripheralArray.addObject(peripheral)
        peripheral.delegate = self
        if isWorkoutControllerActive || isFirstLaunch {
            centralManager.connectPeripheral(activePeripheral, options: nil)
            isFirstLaunch = false
        }
        printStatus()
    }
    
    @objc func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheralStatusString = "Did Connect Peripheral"
        peripheral.discoverServices(nil)
        printStatus()
    }
    
    @objc func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        peripheralStatusString = "Did Disconnect Peripheral";
        printStatus()
    }
    //MARK: CBPeripheralDelegate
    @objc func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error != nil {
            let errorMessage = "Error discovering service: " + (error?.localizedDescription)!
            print(errorMessage)
            return
        }
        for service in peripheral.services! as [CBService] {
            if service.UUID == CBUUID(string: HeartRate.Service.rawValue) {
                peripheralStatusString = "Did Discover Service"
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
        printStatus()
    }
    
    @objc func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error != nil {
            let errorMessage = "Error discovering service: " + (error?.localizedDescription)!
            print(errorMessage)
            return
        }
        if service.UUID == CBUUID(string: HeartRate.Service.rawValue) {
            for characteristic in service.characteristics! as [CBCharacteristic] {
                peripheralStatusString = "Did Discover Characteristic For Service"
                if characteristic.UUID == CBUUID(string: HeartRate.Measurement.rawValue) {
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
            }
        }
        printStatus()
    }
    
    @objc func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            let errorMessage = "Error discovering service: " + (error?.localizedDescription)!
            print(errorMessage)
            return
        }
        //updated value for heart rate measurement received
        if characteristic.UUID == CBUUID(string: PolarCharacteristicUUID.Measurement.rawValue) {
            //get the Heart Rate Monitor BPM
            getHeartBPMData(characteristic)
        }
        printStatus()
    }
    
    func getHeartBPMData(characteristic: CBCharacteristic) {
        let data = characteristic.value
        let count = data!.length / sizeof(__uint8_t)
        var array = [__uint8_t](count:count, repeatedValue:0)
        
        data?.getBytes(&array, length: count * sizeof(__uint8_t))
        if(( (characteristic.value)) != nil) {
            beatPerMinuteValue = Int(array[1])
            if UserSettings.sharedInstance.debug {
                beatPerMinuteValue += 75
            }
        }
    }
    //MARK: Misc
    func connectPeripheral() {
        if activePeripheral != nil {
            centralManager.connectPeripheral(activePeripheral, options: nil)
        }
    }
    
    func disconnectPeripheral() {
        if activePeripheral != nil {
            centralManager.cancelPeripheralConnection(activePeripheral)
        }
    }
    
    func isPeripheralConnected() -> Bool {
        var connected = false
        if activePeripheral.state == .Connected {
            connected = true
        }
        return connected
    }
    
    func printStatus() {
        if UserSettings.sharedInstance.debug {
            //print(peripheralStatusString)
        }
    }
}