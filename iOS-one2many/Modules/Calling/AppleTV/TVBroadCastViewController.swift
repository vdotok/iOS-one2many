//  
//  TVBroadCastViewController.swift
//  Many-to-many-call
//
//  Created by usama farooq on 23/08/2021.
//

import UIKit

public class TVBroadCastViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: TVBroadCastViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindViewModel()
        viewModel.viewModelDidLoad()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewModelWillAppear()
    }
    
    fileprivate func bindViewModel() {

        viewModel.output = { [unowned self] output in
            //handle all your bindings here
            switch output {
            default:
                break
            }
        }
    }
}

extension TVBroadCastViewController {
    func configureAppearance() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "TVBroadcastCell", bundle: nil), forCellWithReuseIdentifier: "TVBroadcastCell")
    }
}

extension TVBroadCastViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.userStreams.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TVBroadcastCell", for: indexPath) as! TVBroadcastCell
        let stream = viewModel.userStreams[indexPath.row]
        cell.configureCell(with: stream)
        return cell
    }
    
}
extension TVBroadCastViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getCellSize(index: indexPath.row)
    }
}

extension TVBroadCastViewController {
    func getCellSize(index: Int) -> CGSize {
        
        let cellWidth: CGFloat = getRowWidth(index: index)
        let cellHeight: CGFloat = getRowHeight()
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    private func getRowWidth(index: Int) -> CGFloat {
        
        let width = self.collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        
        let cellWidth: CGFloat
        
        // Max width of the cell can be half of the width of collectionView
        // For one/two cell(s) width should be equal to width of collectionView
        // For odd numbers of cells width of the last cell will be equal to the width of collectionView and width of all others cells will be equal to the half of the width of collectionView
        // For even number of all cells width will be equal to the half of the width of collectionView
        if viewModel.userStreams.count == 1 {
            cellWidth = width
        } else {
            cellWidth = (width - 12) / 2
        }
//            || viewModel.userStreams.count == 2 {
//
//        } else if viewModel.userStreams.count % 2 == 0 {
//            cellWidth = width/2
//        } else if viewModel.userStreams.count == index + 1 {
//            cellWidth = width
//        } else {
//            cellWidth = width/2
//        }
        
        return cellWidth
    }
    
    private func getRowHeight() -> CGFloat {
        let extraNumber: CGFloat = 0
        let height = collectionView.bounds.size.height
        let rowHeight: CGFloat
        
        // Added in version 1.0
        // Added in build 1
        // Height of cell will be equal to the height of collectionView in case of single cell. Height of cell will be equal to the half of the height of collectionView in case of more than one cell
        if viewModel.userStreams.count == 1 {
            rowHeight = height - extraNumber
        } else {
            rowHeight = (height - extraNumber)
        }
        
        return rowHeight
    }
}
