//
//  PresentedViewController.swift
//  CustomTransition
//
//  Created by naru on 2016/07/27.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

class PresentedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        
        self.navigationItem.titleView = self.titleLabel
        self.navigationItem.leftBarButtonItem = self.backItem
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.closeButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let gestureRecognizers = self.view.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
                    panGestureRecognizer.delegate = self
                }
            }
        }
    }
    
    // MARK: Elements
    
    weak var transitionController: TransitionController!
    
    lazy var collectionView: UICollectionView = {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = self.view.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView: UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.register(PresentedCollectionViewCell.self, forCellWithReuseIdentifier: "presented_cell")
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    lazy var closeButton: UIButton = {
        let frame: CGRect = CGRect(x: 0.0, y: 20.0, width: 60.0, height: 40.0)
        let button: UIButton = UIButton(frame: frame)
        button.setTitle("Close", for: UIControlState())
        button.setTitleColor(self.view.tintColor, for: UIControlState())
        button.addTarget(self, action: #selector(onCloseButtonClicked(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let font: UIFont = UIFont.boldSystemFont(ofSize: 16.0)
        let label: UILabel = UILabel()
        label.font = font
        label.text = "Detail"
        label.sizeToFit()
        return label
    }()
    
    lazy var backItem: UIBarButtonItem = {
        let item: UIBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(onBackItemClicked(_:)))
        return item
    }()
    
    // MARK: CollectionView Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PresentedCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "presented_cell", for: indexPath) as! PresentedCollectionViewCell
        cell.contentView.backgroundColor = UIColor.white
        
        let number: Int = indexPath.item%4 + 1
        cell.content.image = UIImage(named: "image\(number)")
        
        return cell
    }
    
    // MARK: Actions
    
    func onCloseButtonClicked(_ sender: AnyObject) {
        
        let indexPath: IndexPath = self.collectionView.indexPathsForVisibleItems.first!
        self.transitionController.userInfo = ["destinationIndexPath": indexPath as AnyObject, "initialIndexPath": indexPath as AnyObject]
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func onBackItemClicked(_ sender: AnyObject) {
        
        let indexPath: IndexPath = self.collectionView.indexPathsForVisibleItems.first!
        self.transitionController.userInfo = ["destinationIndexPath": indexPath as AnyObject, "initialIndexPath": indexPath as AnyObject]
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    // MARK: Gesture Delegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let indexPath: IndexPath = self.collectionView.indexPathsForVisibleItems.first!
        self.transitionController.userInfo = ["destinationIndexPath": indexPath as AnyObject, "initialIndexPath": indexPath as AnyObject]
        
        let panGestureRecognizer: UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
        let translate: CGPoint = panGestureRecognizer.translation(in: self.view)
        return Double(abs(translate.y)/abs(translate.x)) > M_PI_4
    }
}

extension PresentedViewController: View2ViewTransitionPresented {
    
    func destinationFrame(userInfo: [String: Any]?, isPresenting: Bool) -> CGRect {
        
        let indexPath: IndexPath = userInfo!["destinationIndexPath"] as! IndexPath
        let cell: PresentedCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! PresentedCollectionViewCell
        return cell.content.frame
    }
    
    func destinationView(userInfo: [String: Any]?, isPresenting: Bool) -> UIView {
        
        let indexPath: IndexPath = userInfo!["destinationIndexPath"] as! IndexPath
        let cell: PresentedCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! PresentedCollectionViewCell
        return cell.content
    }
    
    func prepareDestinationView(userInfo: [String: Any]?, isPresenting: Bool) {
        
        if isPresenting {
            
            let indexPath: IndexPath = userInfo!["destinationIndexPath"] as! IndexPath
            let contentOfffset: CGPoint = CGPoint(x: self.collectionView.frame.size.width*CGFloat(indexPath.item), y: 0.0)
            self.collectionView.contentOffset = contentOfffset
            
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        }
    }
}

open class PresentedCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.content)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var content: UIImageView = {
        let margin: CGFloat = 2.0
        let width: CGFloat = (UIScreen.main.bounds.size.width - margin*2.0)
        let height: CGFloat = (UIScreen.main.bounds.size.height - 160.0)
        let frame: CGRect = CGRect(x: margin, y: (UIScreen.main.bounds.size.height - height)/2.0, width: width, height: height)
        let view: UIImageView = UIImageView(frame: frame)
        view.backgroundColor = UIColor.gray
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
}
