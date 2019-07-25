//
//  MainViewController.swift
//  SheetModalSample
//
//  Created by Shin Yamamoto on 2019/07/16.
//  Copyright © 2019 Shin Yamamoto. All rights reserved.
//

import UIKit

enum MainViewMode {
    case normal
    case withNewMessage
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var newMessageView: MessageView!
    var mode: MainViewMode = .normal {
        didSet {
            switch mode {
            case .normal:
                bottomConstraint.constant = -view.safeAreaInsets.bottom
                break
            case .withNewMessage:
                bottomConstraint.constant = 48.0
            }
        }
    }
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    // var ob: NSKeyValueObservation?
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        newMessageView.addGestureRecognizer(tapGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mode = .normal
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mode = .normal
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    @IBAction func buttonTapped(_ sender: Any) {
        guard let modalVC = storyboard?.instantiateViewController(withIdentifier: "ModalViewController") else {
            assertionFailure()
            return
        }

        print("Default presentation style = \(modalVC.modalPresentationStyle.rawValue)")
        #if canImport(SwiftUI)
        if #available(iOS 13, *) {
            print("automatic - \(UIModalPresentationStyle.automatic.rawValue)")
        }
        #endif
        print("fullScreen - \(UIModalPresentationStyle.fullScreen.rawValue)")
        print("pageSheet - \(UIModalPresentationStyle.pageSheet.rawValue)")
        print("formSheet - \(UIModalPresentationStyle.formSheet.rawValue)")
        
        // Not working
        /*
        ob = modalVC.view.observe(\.frame) { (view, _) in
            print("ModalViewController.view -- \(view.frame)")
        }
         */
        present(modalVC, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { }
}

class MessageView: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = UIColor(white: 0.90, alpha: 1.0)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        backgroundColor = .white
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        backgroundColor = .white
    }
}

class ModalViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    @IBOutlet weak var newMessageSmallLabel: UILabel!
    @IBOutlet weak var newMessageLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var textView: UITextView!
    var observation: NSKeyValueObservation?
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = switcher.isOn
        newMessageSmallLabel.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentationController?.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("PresentationController -- \(self.presentationController!)")
        // -> _UIPageSheetPresentationController
        print("presentedView = \(presentationController!.presentedView!.self))")
        // -> UIDropShadowView
        
        if let gesture = presentationController?.presentedView?.gestureRecognizers?[0] {
            // -> _UISheetInteractionBackgroundDismissRecognizer
            gesture.addTarget(self, action: #selector(handle(panGesture:)))
        }
        textView.panGestureRecognizer.addTarget(self, action: #selector(handle(panGesture:)))

        let presenting = presentationController?.presentingViewController as! MainViewController

        observation = presentationController?.presentedView?.observe(\.frame) { (view, _) in
            print("presentedView -- \(view.frame)")

            guard presenting.mode == .withNewMessage else { return }

            if UIScreen.main.bounds.height - view.frame.minY < 44.0 + view.safeAreaInsets.bottom {
                view.frame.origin.y = UIScreen.main.bounds.height - (44.0 + view.safeAreaInsets.bottom)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func hideBarButtons() {
        cancelButton.isHidden = true
        switcher.isHidden = true
        newMessageLabel.isHidden = true
        newMessageSmallLabel.isHidden = false
    }
    
    // MARK: - Actions
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        (presentingViewController as? MainViewController)?.mode = .normal
        dismiss(animated: true, completion: nil)
    }
    @IBAction func modeChanged(_ sender: UISwitch) {
        isModalInPresentation = sender.isOn
    }
    
    // MARK: -  _UISheetInteractionBackgroundDismissRecognizer handler
    @objc func handle(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            print("_UISheetInteractionBackgroundDismissRecognizer -- began")
        case .changed:
            print("_UISheetInteractionBackgroundDismissRecognizer -- changed")
        case .ended:
            print("_UISheetInteractionBackgroundDismissRecognizer -- ended")
            let velocity = panGesture.velocity(in: view)
            let presenting = presentationController?.presentingViewController as! MainViewController
            if presenting.mode == .withNewMessage, // For ScrollView.panGestureRecognizer
                isModalInPresentation == false, velocity.y > 0 {
                hideBarButtons()
            }
        default:
            break
        }
    }
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print("presentationControllerWillDismiss")
        let presenting = presentationController.presentingViewController as! MainViewController
        presenting.mode = .withNewMessage
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        print("presentationControllerShouldDismiss")
        return true
    }
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("presentationControllerDidAttemptToDismiss")
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("presentationControllerDidDismiss")
    }
}
