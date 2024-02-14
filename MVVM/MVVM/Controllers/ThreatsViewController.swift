/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class ThreatsViewController: UIViewController {
  private let cellIdentifier = "ImageCell"
  private let headerIdentifier = "HeaderView"

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  private var viewModel = ThreatsViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    viewModel.delegate = self
  }

    override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if !LoginService.isAuthenticated {
      presentLoginViewController()
    }
  }
}

// MARK: UICollectionViewDataSource
extension ThreatsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! ImageCollectionViewCell

        let threatImagePaths = viewModel.imagePathsForThreatAtIndex(index: indexPath.section)
      let imagePath = threatImagePaths[indexPath.item]
        cell.imageView.setImageFromPath(path: imagePath)

      return cell
    }
    
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return viewModel.numberOfThreats()
  }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return viewModel.imagePathsForThreatAtIndex(index: section).count
  }

//    private func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! ImageCollectionViewCell
//
//      let threatImagePaths = viewModel.imagePathsForThreatAtIndex(index: indexPath.section)
//    let imagePath = threatImagePaths[indexPath.item]
//      cell.imageView.setImageFromPath(path: imagePath)
//
//    return cell
//  }

    private func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
      if kind == UICollectionView.elementKindSectionHeader {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath as IndexPath)
        as! ResultsHeaderView

        headerView.titleLabel.text = viewModel.nameForThreatAtIndex(index: indexPath.section)

      return headerView
    }

    assert(false, "Unexpected element kind")
  }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ThreatsViewController: UICollectionViewDelegateFlowLayout {
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let cellWidth = (collectionView.bounds.width - CGFloat(30)) / 2.0
    return CGSize(width: cellWidth, height: cellWidth)
  }
}

// MARK: Actions
extension ThreatsViewController {
  @IBAction func logoutPressed() {
    LoginService.logout {
      self.presentLoginViewController() {
        self.viewModel.clearThreats()
      }
    }
  }
}

// MARK: Private Methods
private extension ThreatsViewController {
    func presentLoginViewController(completion: (() -> Void)? = nil) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.loginSuccess = {
            self.activityIndicator.startAnimating()
            self.dismiss(animated: true) {
                self.viewModel.fetchThreats()
            }
        }
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.navigationController?.isNavigationBarHidden = false
        present(loginVC, animated: true, completion: completion)
    }
}

// MARK: - ThreatListViewModelDelegate
extension ThreatsViewController: ThreatsViewModelDelegate {
  func threatsChanged() {
    self.collectionView?.reloadData()
    self.activityIndicator.stopAnimating()
  }
}
