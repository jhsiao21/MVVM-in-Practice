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

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var codeLabel: UILabel!
    
    @IBOutlet weak var topVaultView: UIView!
    @IBOutlet weak var bottomVaultView: UIView!
    @IBOutlet weak var lockView: UIImageView!
    
    private var transitionCordinator = LockAnimator()
    private var viewModel = UserViewModel()
    
    var loginSuccess: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = transitionCordinator
        
        viewModel.accessCode.bind { [unowned self] in
            self.codeLabel.text = $0
        }
    }
}

// MARK: Actions
extension LoginViewController {
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func authenticate() {
        dismissKeyboard()
        
        switch viewModel.validate() {
        case .Valid:
            viewModel.login() { errorMessage in
                if let errorMessage = errorMessage {
                    self.displayErrorMessage(errorMessage: errorMessage)
                } else {
                    self.loginSuccess?()
                }
            }
        case .Invalid(let error):
            displayErrorMessage(errorMessage: error)
        }
    }
}

// MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usernameField {
            textField.text = viewModel.username
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == usernameField {
            textField.text = viewModel.protectedUsername
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else {
            authenticate()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if textField == usernameField {
            viewModel.updateUsername(username: newString)
        } else if textField == passwordField {
            viewModel.updatePassword(password: newString)
        }
        
        return true
    }
}

// MARK: Private Methods
private extension LoginViewController {
    func displayErrorMessage(errorMessage: String) {
        let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
