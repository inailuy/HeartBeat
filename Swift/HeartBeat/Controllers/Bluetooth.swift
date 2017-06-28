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
    var activePeripheral : CBPeripheral?
    var peripheralStatusString = String()
    var peripheralArray = NSMutableArray()
    var isFirstLaunch = Bool()
    var isWorkoutControllerActive = Bool()
    
    func load() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        let myServiceUUID = CBUUID(string: HeartRate.Service.rawValue)
        centralManager.scanForPeripherals(withServices: [myServiceUUID], options: nil)
        isFirstLaunch = true
    }  
    //MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        peripheralStatusString = "centralManagerDidUpdateState " + String(describing: central.state)
        if central.state == .poweredOn {
            peripheralStatusString = "Scanning For Peripherals"
            let myServiceUUID = CBUUID(string: HeartRate.Service.rawValue)
            centralManager.scanForPeripherals(withServices: [myServiceUUID], options: nil)
        }
        printStatus()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralStatusString = "Did Discorver Peripheral"
        activePeripheral = peripheral
        peripheralArray.add(peripheral)
        peripheral.delegate = self
        if isWorkoutControllerActive || isFirstLaunch {
            centralManager.connect(activePeripheral!, options: nil)
            isFirstLaunch = false
        }
        printStatus()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralStatusString = "Did Connect Peripheral"
        peripheral.discoverServices(nil)
        printStatus()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheralStatusString = "Did Disconnect Peripheral";
        printStatus()
    }
    //MARK: CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            let errorMessage = "Error discovering service: " + (error?.localizedDescription)!
            print(errorMessage)
            return
        }
        for service in peripheral.services! as [CBService] {
            if service.uuid == CBUUID(string: HeartRate.Service.rawValue) {
                peripheralStatusString = "Did Discover Service"
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        printStatus()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            let errorMessage = "Error discovering service: " + (error?.localizedDescription)!
            print(errorMessage)
            return
        }
        if service.uuid == CBUUID(string: HeartRate.Service.rawValue) {
            for characteristic in service.characteristics! as [CBCharacteristic] {
                peripheralStatusString = "Did Discover Characteristic For Service"
                if characteristic.uuid == CBUUID(string: HeartRate.Measurement.rawValue) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
        printStatus()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            let errorMessage = "Error discovering service: " + (error?.localizedDescription)!
            print(errorMessage)
            return
        }
        //updated value for heart rate measurement received
        if characteristic.uuid == CBUUID(string: PolarCharacteristicUUID.Measurement.rawValue) {
            //get the Heart Rate Monitor BPM
            getHeartBPMData(characteristic)
        }
        printStatus()
    }
    
    func getHeartBPMData(_ characteristic: CBCharacteristic) {
        let data = characteristic.value
        let count = data!.count / MemoryLayout<__uint8_t>.size
        var array = [__uint8_t](repeating: 0, count: count)
        
        (data as NSData?)?.getBytes(&array, length: count * MemoryLayout<__uint8_t>.size)
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
            centralManager.connect(activePeripheral!, options: nil)
        }
    }
    
    func disconnectPeripheral() {
        if activePeripheral != nil {
            centralManager.cancelPeripheralConnection(activePeripheral!)
        }
    }
    
    func isPeripheralConnected() -> Bool {
        var connected = false
        if activePeripheral?.state == .connected {
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
