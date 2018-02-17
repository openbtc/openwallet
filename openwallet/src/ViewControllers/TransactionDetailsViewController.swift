//
//  TransactionDetailsViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-02-09.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import UIKit

class TransactionDetailsViewController : UICollectionViewController, Subscriber {

    //MARK: - Public
    init(store: Store, transactions: [Transaction], selectedIndex: Int) {
        self.store = store
        self.transactions = transactions
        self.selectedIndex = selectedIndex
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width-C.padding[4], height: UIScreen.main.bounds.height - C.padding[1])
        layout.sectionInset = UIEdgeInsetsMake(C.padding[1], 0, 0, 0)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = C.padding[1]
        super.init(collectionViewLayout: layout)
    }

    //MARK: - Private
    fileprivate let store: Store
    fileprivate var transactions: [Transaction]
    fileprivate let selectedIndex: Int
    fileprivate let cellIdentifier = "CellIdentifier"
    fileprivate var currency: Currency = .bitcoin

    //The secretScrollView is to help with the limitation where if isPagingEnabled
    //is true, the page size has to be the bounds.width of the collectionview.
    //We want a portion of the next transaction to be visible, so we can use
    //a hidden scrollview with isPagingEnbabled=true, which forwards its scroll events
    //to the collectionview
    fileprivate let secretScrollView = UIScrollView()
    private var hasShownInitialIndex = false

    deinit {
        store.unsubscribe(self)
    }

    override func viewDidLoad() {
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsetsMake(C.padding[2], C.padding[2], C.padding[2], C.padding[2])
        setupScrolling()
        store.subscribe(self, selector: { $0.currency != $1.currency }, callback: { self.currency = $0.currency })
        store.lazySubscribe(self, selector: { $0.walletState.transactions != $1.walletState.transactions }, callback: {
            self.transactions = $0.walletState.transactions
            self.collectionView?.reloadData()
        })
    }

    private func setupScrolling() {
        view.addSubview(secretScrollView)
        secretScrollView.isPagingEnabled = true

        //This scrollview needs to be off screen so that it doesn't block touches meant for the transaction details
        //card. We are just using this scrollview for its gesture recognizer, so that we can se a preview of the next card
        //and also have paging enabled for the scrollview.
        secretScrollView.frame = CGRect(x: C.padding[2] - 4.0, y: -1000, width: UIScreen.main.bounds.width - C.padding[3], height: UIScreen.main.bounds.height - C.padding[1])
        secretScrollView.showsHorizontalScrollIndicator = false
        secretScrollView.alwaysBounceHorizontal = true
        collectionView?.addGestureRecognizer(secretScrollView.panGestureRecognizer)
        collectionView?.panGestureRecognizer.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasShownInitialIndex {
            guard let contentSize = collectionView?.contentSize else { return }
            guard let collectionView = collectionView else { return }
            secretScrollView.contentSize = contentSize
            var contentOffset = collectionView.contentOffset
            contentOffset.x = contentOffset.x + collectionView.contentInset.left
            contentOffset.y = contentOffset.y + collectionView.contentInset.top
            secretScrollView.contentOffset = contentOffset

            //The scrollview's delegate has to be set late here so we can set the initial position
            //without causing any side effects.
            secretScrollView.delegate = self

            hasShownInitialIndex = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !hasShownInitialIndex {
            collectionView?.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView else { return }
        guard scrollView == secretScrollView else { return }
        var contentOffset = scrollView.contentOffset
        contentOffset.x = contentOffset.x - collectionView.contentInset.left
        contentOffset.y = contentOffset.y - collectionView.contentInset.top
        collectionView.contentOffset = contentOffset
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UICollectionViewDataSource
extension TransactionDetailsViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        item.backgroundColor = .clear

        //TODO - make these recycle properly
        let view = TransactionDetailView(currency: currency)
        view.transaction = transactions[indexPath.row]
        view.closeCallback = { [weak self] in
            if let delegate = self?.transitioningDelegate as? ModalTransitionDelegate {
                delegate.reset()
            }
            self?.dismiss(animated: true, completion: nil)
        }
        item.addSubview(view)
        view.constrain(toSuperviewEdges: nil)
        return item
    }
}
