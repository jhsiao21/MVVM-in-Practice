//
//  ThreatsViewModel.swift
//  MVVM
//
//  Created by Eric Cerney on 2/3/16.
//  Copyright © 2016 Eric Cerney. All rights reserved.
//

import Foundation

protocol ThreatsViewModelDelegate: AnyObject {
  func threatsChanged()
}

class ThreatsViewModel {
  private var threats = [Threat]() {
    didSet {
      delegate?.threatsChanged()
    }
  }

  weak var delegate: ThreatsViewModelDelegate?
}

extension ThreatsViewModel {
  func fetchThreats() {
    SpyService.getNearbyThreats { threats in
      self.threats = threats
      print("Gathered threats: \(threats)")
    }
  }

  func clearThreats() {
    threats.removeAll()
  }
}

extension ThreatsViewModel {
  func numberOfThreats() -> Int {
    return threats.count
  }

  func imagePathsForThreatAtIndex(index: Int) -> [String] {
      if threats.count > 0 {
          return threats[index].imagePaths
      }
      else {
          return []
      }
  }

  func nameForThreatAtIndex(index: Int) -> String {
    let threat = threats[index]
    return threat.lastName + ", " + threat.firstName
  }
}
