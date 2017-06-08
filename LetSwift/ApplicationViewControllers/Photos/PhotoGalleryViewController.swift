//
//  PhotosViewController.swift
//  LetSwift
//
//  Created by Kinga Wilczek on 15.05.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import UIKit
import MWPhotoBrowser

protocol PhotoGalleryViewControllerDelegate: class {
    func presentGallery(with: PhotoGalleryViewControllerViewModel)
}

final class PhotoGalleryViewController: AppViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    fileprivate var viewModel: PhotoGalleryViewControllerViewModel!
    fileprivate var mwPhotos: [MWPhoto]?
    
    private let disposeBag = DisposeBag()
    
    override var viewControllerTitleKey: String? {
        return "PHOTOS_TITLE"
    }
    
    override var shouldHideShadow: Bool {
        return true
    }
    
    fileprivate var columnNumber: Int {
        return DeviceScreenHeight.deviceHeight > DeviceScreenHeight.inch4¨7.rawValue ? 3 : 2
    }
    
    convenience init(viewModel: PhotoGalleryViewControllerViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        collectionView.registerCells([SinglePhotoCell.self])
        collectionView.delegate = self
        
        setupViewModel()
    }
    
    private func setupViewModel() {
        viewModel.photosObservable.subscribeNext(startsWithInitialValue: true) { [weak self] photos in
            guard let weakSelf = self else { return }
            
            photos.bindable.bind(to: weakSelf.collectionView.items() ({ collectionView, index, element in
                let indexPath = IndexPath(row: index, section: 0)
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SinglePhotoCell.cellIdentifier, for: indexPath) as! SinglePhotoCell
                cell.imageURL = element.thumb
                
                return cell
            }))
            
            weakSelf.mwPhotos = photos.map { MWPhoto(url: $0.big) }
        }
        .add(to: disposeBag)
    }
}

extension PhotoGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0.0
        let cellPadding = itemSpacing * CGFloat(columnNumber + 1)
        let cellSize = (collectionView.bounds.width - cellPadding) / CGFloat(columnNumber)
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = RotatingMVPhotoBrowser(delegate: self)
        browser?.coordinatorDelegate = coordinatorDelegate
        browser?.displayActionButton = false
        browser?.enableGrid = false
        browser?.lightMode = true
        browser?.setCurrentPhotoIndex(UInt(indexPath.row))
        
        navigationController?.pushViewController(browser!, animated: true)
    }
}

extension PhotoGalleryViewController: MWPhotoBrowserDelegate {
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(mwPhotos?.count ?? 0)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        return mwPhotos?[Int(index)]
    }
    
    func translation(for string: String!, withDescription description: String!) -> String! {
        switch string {
        case "of": return localized("PHOTOS_OF")
        default: return string
        }
    }
}
