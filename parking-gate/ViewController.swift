//
//  ViewController.swift
//  parking-gate
//
//  Created by Srikanth Srinivas on 27/12/2020.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var openGateButton: UIButton!
    
    var centralManager: CBCentralManager!
    var bluefruit: CBPeripheral!
    var service: CBService!
    var characteristic: CBCharacteristic!
    var peripheral: CBPeripheral!
    var MAX_BLE_PACKET_SIZE: Int! = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        setButtonToDisabaled()
    }
    
    
    @IBAction func openGatePressed(_ sender: Any) {
        let iphoneID = UIDevice.current.identifierForVendor?.uuidString
        if let iphoneID = iphoneID {
            let data = iphoneID.data(using: .utf8)
            
            let size = data!.count
            var startIndex = 0
            var endIndex = 20
            while endIndex != data!.count{
                if endIndex > size{
                    self.peripheral.writeValue(data![startIndex ..< size], for: characteristic, type: .withResponse)
                    endIndex = size
                }else{
                    self.peripheral.writeValue(data![startIndex ..< endIndex], for: characteristic, type: .withResponse)
                    startIndex = endIndex
                    endIndex += self.MAX_BLE_PACKET_SIZE
                }
            }
        }
    }
    
    func setButtonToDisabaled() {
        openGateButton.isEnabled = false
        openGateButton.setTitle("Please wait", for: .normal)
        openGateButton.backgroundColor = .lightText
        openGateButton.setTitleColor(.darkGray, for: .normal)
    }
    
    func setButtonToEnabled() {
        openGateButton.isEnabled = true
        openGateButton.setTitle("Open Gate", for: .normal)
        openGateButton.backgroundColor = .systemBlue
        openGateButton.setTitleColor(.white, for: .normal)
    }
}


extension ViewController: CBPeripheralDelegate, CBCentralManagerDelegate{
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(error)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth turned on")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        default:
            print("Default")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "Adafruit Bluefruit LE"{
            bluefruit = peripheral
            central.connect(peripheral, options: nil)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.properties.contains(.write){
                    self.characteristic = characteristic
                    self.peripheral = peripheral
                    self.setButtonToEnabled()
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services{
            for service in services{
                if service.uuid.uuidString == "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"{
                    self.service = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
}
