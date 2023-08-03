////
////  UserDefaultsManager.swift
////  dayMind
////
////  Created by 강영민 on 2023/07/19.
////
//
//import Foundation
//import Dispatch
//
//class UserDefaultsManager {
//    static let shared = UserDefaultsManager()
//    
//    private let semaphore: DispatchSemaphore
//    private let userDefaults: UserDefaults
//    
//    init() {
//        self.semaphore = DispatchSemaphore(value: 1)
//        guard let userDefaults = UserDefaults(suiteName: "group.kr.co.daymind.daymind") else {
//            fatalError("Failed to create UserDefaults.")
//        }
//        self.userDefaults = userDefaults
//    }
//    
//    func set(_ value: Any?, forKey defaultName: String) {
//        semaphore.wait()
//        defer { semaphore.signal() }
//        userDefaults.set(value, forKey: defaultName)
//    }
//    
//    func data(forKey defaultName: String) -> Data? {
//        semaphore.wait()
//        defer { semaphore.signal() }
//        return userDefaults.data(forKey: defaultName)
//    }
//}
