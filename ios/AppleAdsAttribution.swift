//
//  AppleAdsAttribution.swift
//  AppleAdsAttribution
//
//  Created by Garry on 17/09/24.
//  Copyright © 2024 Facebook. All rights reserved.
//

import Foundation
import AdServices
import React

// Error domain used for rejection errors
let RNAAAErrorDomain = "RNAAAErrorDomain"
let NUM_RETRIES = 3

@objc(AppleAdsAttribution)
class AppleAdsAttribution: NSObject, RCTBridgeModule {

  // MARK: - Queue

  static var methodQueue: DispatchQueue {
    return DispatchQueue.main
  }

  // MARK: - Error Handling

  static func rejectPromise(with error: Error?, using reject: @escaping RCTPromiseRejectBlock) {
    if let error = error {
      reject("unknown", error.localizedDescription, error)
    } else {
      reject("unknown", "Failed with unknown error", nil)
    }
  }

  static func rejectPromise(with userInfo: [String: Any], using reject: @escaping RCTPromiseRejectBlock) {
    let error = NSError(domain: RNAAAErrorDomain, code: 100, userInfo: userInfo)
    reject(userInfo["code"] as? String ?? "", userInfo["message"] as? String ?? "", error)
  }

  // MARK: - Simulator Check

  static func isSimulator() -> Bool {
    #if targetEnvironment(simulator)
      return true
    #else
      return false
    #endif
  }

  // MARK: - AdServices API Calls

  @available(iOS 14.3, *)
  static func requestAdServicesAttributionData(using token: String, retriesLeft: Int, completion: @escaping (NSDictionary?, Error?) -> Void) {
    var urlRequest = URLRequest(url: URL(string: "https://api-adservices.apple.com/api/v1/")!)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("text/plain", forHTTPHeaderField: "Content-Type")
    urlRequest.httpBody = token.data(using: .utf8)

    let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
      guard let response = response as? HTTPURLResponse else { return }

      // Check for successful status code (200)
      if response.statusCode != 200 {
        if (response.statusCode == 404 || response.statusCode == 500) && retriesLeft > 0 {
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            requestAdServicesAttributionData(using: token, retriesLeft: retriesLeft - 1, completion: completion)
          }
        } else {
          let details = ["NSLocalizedDescriptionKey": String(format: "Request to get data from Adservices API failed with status code %ld. Re-tried %i times", response.statusCode, NUM_RETRIES - retriesLeft)]
          let error = NSError(domain: RNAAAErrorDomain, code: 100, userInfo: details)
          completion(nil, error)
        }
        return
      }

      if let error = error {
        completion(nil, error)
        return
      }

      guard let data = data else {
        let details = ["NSLocalizedDescriptionKey": "Request to Adservices API failed with unknown error"]
        let error = NSError(domain: RNAAAErrorDomain, code: 100, userInfo: details)
        completion(nil, error)
        return
      }

      do {
        let attributionData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        completion(attributionData, nil)
      } catch {
        completion(nil, error)
      }
    }
    dataTask.resume()
  }

  // MARK: - AdServices Token Generation

  static func getAdServicesAttributionToken() -> String? {
    if isSimulator() {
      let details = ["NSLocalizedDescriptionKey": "Error getting token, not available in Simulator"]
      let error = NSError(domain: RNAAAErrorDomain, code: 100, userInfo: details)
      return nil
    }

    if #available(iOS 14.3, *) {
      let AAAttributionClass = NSClassFromString("AAAttribution")
      if let AAAttributionClass = AAAttributionClass {
        do {
          let attributionToken = try AAAttributionClass.attributionToken()
          return attributionToken
        } catch {
          let details = ["NSLocalizedDescriptionKey": "Error getting token, AAAttributionClass not found"]
          let error = NSError(domain: RNAAAErrorDomain, code: 100, userInfo: details)
          return nil
        }
      } else {
        let details = ["NSLocalizedDescriptionKey": "Error getting token, AAAttributionClass not found"]
        let error = NSError(domain: RNAAAErrorDomain, code: 100, userInfo: details)
        return nil
      }
    } else {
      let details = ["NSLocalizedDescriptionKey": "Error getting token, AdServices not available pre iOS 14.3"]
      let error = NSError(domain: RNAAAErrorDomain, code: 100, userInfo: details)
      return nil
    }
  }

  // MARK: - React Native Module Methods

/**
 * Tries to get attribution data first using the AdServices API. If it fails it fallbacks to the old iAd API.
 * Rejected with error if both fails
 */
  @objc(getAttributionData)
  func getAttributionData(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    if #available(iOS 14.3, *) {
      getAdServicesAttributionDataWithCompletionHandler { attributionData, adServicesError in
        if let attributionData = attributionData {
          resolve(attributionData)
        } else {
          getiAdAttributionDataWithCompletionHandler { data, iAdError in
            if let data = data {
              resolve(data)
            } else {
              let combinedErrorMessage = "Ad services error: \(adServicesError?.localizedDescription ?? "no error message"). \niAD error: \(iAdError?.localizedDescription ?? "no error message")"
              rejectPromise(with: ["code": "unknown", "message": combinedErrorMessage], using: reject)
            }
          }
        }
      }
    } else {
      getiAdAttributionDataWithCompletionHandler { data, error in
        if let data = data {
          resolve(data)
        } else {
          rejectPromise(with: error, using: reject)
        }
      }
    }
  }

/**
 * Tries to get attribution data using the old iAd API.
 * Rejected with error if it failed to get data
 *  */
  @objc(getiAdAttributionData)
  func getiAdAttributionData(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    getiAdAttributionDataWithCompletionHandler { data, error in
      if let data = data {
        resolve(data)
      } else {
        rejectPromise(with: error, using: reject)
      }
    }
  }

/**
 * Tries to generate an attribution token that then can be used for calls to Apples AdServices API.
 * Rejected with error if token couldn't be generated.
 */
  @objc(getAdServicesAttributionToken)
  func getAdServicesAttributionToken(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    if let attributionToken = getAdServicesAttributionToken() {
      resolve(attributionToken)
    } else {
      rejectPromise(with: error, using: reject)
    }
  }

/**
 * Tries to get attribution data from apples AdServices API.
 * Rejected with error if data couldn't be fetched.
 */
  @objc(getAdServicesAttributionData)
  func getAdServicesAttributionData(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    getAdServicesAttributionDataWithCompletionHandler { attributionData, error in
      if let attributionData = attributionData {
        resolve(attributionData)
      } else {
        rejectPromise(with: error, using: reject)
      }
    }
  }

  // MARK: - iAd API Calls

/**
 * Gets attribution data from the old iAd API.
 * completionHandler will return nil with an error if attribution data couldn't be retrieved. Reasons for failing may be that the user disabled tracking or that the iOS version is < 10.
 */
  static func getiAdAttributionDataWithCompletionHandler(completion: @escaping (NSDictionary?, Error?) -> Void) {
    if #available(iOS 10, *) {
      ADClient.shared.requestAttributionDetails { attributionDetails, error in
        if let error = error {
          completion(nil, error)
        } else {
          completion(attributionDetails, nil)
        }
      }
    } else {
      let details = ["NSLocalizedDescriptionKey": "iAd ADClient not available"]
      let error = NSError(domain: RNAAAErrorDomain, code: 100, userInfo: details)
      completion(nil, error)
    }
  }
}
