//
//  MessageUIPresenter.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-11.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit
import MessageUI

class MessageUIPresenter: NSObject {

    weak var presenter: UIViewController?

    func presentMailCompose(address: String, image: UIImage) {
        guard MFMailComposeViewController.canSendMail() else { return }
        originalTitleTextAttributes = UINavigationBar.appearance().titleTextAttributes
        UINavigationBar.appearance().titleTextAttributes = nil
        let emailView = MFMailComposeViewController()
        emailView.setMessageBody("bitcoin: \(address)", isHTML: false)
        if let data = UIImagePNGRepresentation(image) {
            emailView.addAttachmentData(data, mimeType: "image/png", fileName: "bitcoinqr.png")
        }
        emailView.mailComposeDelegate = self
        present(emailView)
    }

    func presentMessageCompose(address: String, image: UIImage) {
        guard MFMessageComposeViewController.canSendText() else { return }
        originalTitleTextAttributes = UINavigationBar.appearance().titleTextAttributes
        UINavigationBar.appearance().titleTextAttributes = nil
        let textView = MFMessageComposeViewController()
        textView.body = "bitcoin: \(address)"
        if let data = UIImagePNGRepresentation(image) {
            textView.addAttachmentData(data, typeIdentifier: "public.image", filename: "bitcoinqr.png")
        }
        textView.messageComposeDelegate = self
        present(textView)
    }

    fileprivate var originalTitleTextAttributes: [String: Any]?

    private func present(_ viewController: UIViewController) {
        presenter?.view.isFrameChangeBlocked = true
        viewController.view.tintColor = C.defaultTintColor
        presenter?.present(viewController, animated: true, completion: {})
    }

    fileprivate func dismiss(_ viewController: UIViewController) {
        UINavigationBar.appearance().titleTextAttributes = originalTitleTextAttributes
        viewController.dismiss(animated: true, completion: {
            self.presenter?.view.isFrameChangeBlocked = false
        })
    }
}

extension MessageUIPresenter: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(controller)
    }
}

extension MessageUIPresenter: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(controller)
    }
}
