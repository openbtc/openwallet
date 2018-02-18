//
//  EnterPhraseCollectionViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-02-23.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import UIKit

class EnterPhraseCollectionViewController : UICollectionViewController {

    //MARK: - Public
    var didFinishPhraseEntry: ((String) -> Void)?

    init(walletManager: WalletManager) {
        self.walletManager = walletManager
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: (screenWidth - C.padding[4])/3.0, height: 50.0)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = .zero
        super.init(collectionViewLayout: layout)
    }

    //MARK: - Private
    private let cellIdentifier = "CellIdentifier"
    private let walletManager: WalletManager
    private var phrase: String {
        return (0...11).map { index in
                guard let phraseCell = collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? EnterPhraseCell else { return ""}
                return phraseCell.textField.text ?? ""
            }.joined(separator: " ")
    }

    override func viewDidLoad() {
        collectionView?.backgroundColor = .white
        collectionView?.register(EnterPhraseCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.layer.borderColor = UIColor.secondaryBorder.cgColor
        collectionView?.layer.borderWidth = 1.0
        collectionView?.layer.cornerRadius = 8.0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder(atIndex: 0)
    }

    //MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let item = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        guard let enterPhraseCell = item as? EnterPhraseCell else { return item }
        enterPhraseCell.index = indexPath.row
        enterPhraseCell.didTapNext = { [weak self] in
            self?.becomeFirstResponder(atIndex: indexPath.row + 1)
        }
        enterPhraseCell.didTapPrevious = { [weak self] in
            self?.becomeFirstResponder(atIndex: indexPath.row - 1)
        }
        enterPhraseCell.didTapDone = { [weak self] in
            guard let phrase = self?.phrase else { return }
            self?.didFinishPhraseEntry?(phrase)
        }
        enterPhraseCell.isWordValid = { [weak self] word in
            guard let myself = self else { return false }
            return myself.walletManager.isWordValid(word)
        }
        return item
    }

    //MARK: - Extras
    private func becomeFirstResponder(atIndex: Int) {
        guard let phraseCell = collectionView?.cellForItem(at: IndexPath(item: atIndex, section: 0)) as? EnterPhraseCell else { return }
        phraseCell.textField.becomeFirstResponder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
