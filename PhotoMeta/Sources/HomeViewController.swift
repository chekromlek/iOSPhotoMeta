//
//  ViewController.swift
//  PhotoMeta
//
//  Created by Veasna Sreng on 7/27/19.
//  Copyright © 2019 Veasna Sreng. All rights reserved.
//

import UIKit
import Photos

class HomeViewController: UIViewController {

    @IBOutlet weak var naviItems: UINavigationItem!
    @IBOutlet weak var collection: UICollectionView!

    var listPhotosData: [PhotoDataCollection]?
    var allPhotoCount: Int?
    
    var selectBtn: UIBarButtonItem!
    var cancelBtn: UIBarButtonItem!
    var sortBtn: UIBarButtonItem!
    
    var openIndexPath: IndexPath!
    
    var sortStateAscending: Bool! = true
    
    var gesture: UITapGestureRecognizer!
    
    let columnLayout = UIColumnFlowLayout(
        cellsPerRow: 3,
        minimumInteritemSpacing: 2,
        minimumLineSpacing: 2,
        sectionInset: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update view
        self.setView()
        //
        self.collection.dataSource = self
        self.collection.delegate = self
        self.collection.collectionViewLayout = columnLayout
        self.collection.contentInsetAdjustmentBehavior = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fetch all photo
        self.fetchPhoto(ascending: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if #available(iOS 11, *) {
            //Do nothing
        }
        else {
            
            //Support for devices running iOS 10 and below
            
            //Check to see if the view is currently visible, and if so,
            //animate the frame transition to the new orientation
            if self.viewIfLoaded?.window != nil {
                
                coordinator.animate(alongsideTransition: { _ in
                    
                    //This needs to be called inside viewWillTransition() instead of viewWillLayoutSubviews()
                    //for devices running iOS 10.0 and earlier otherwise the frames for the view and the
                    //collectionView will not be calculated properly.
                    self.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                    self.collection.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                    
                }, completion: { _ in
                    
                    //Invalidate the collectionViewLayout
                    self.collection.collectionViewLayout.invalidateLayout()
                    
                })
                
            }
                //Otherwise, do not animate the transition
            else {
                
                self.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                self.collection.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                
                //Invalidate the collectionViewLayout
                self.collection.collectionViewLayout.invalidateLayout()
                
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewphoto" {
            let vc = segue.destination as! FullPhotoViewController
            vc.asset = self.listPhotosData?[self.openIndexPath.section].assets[self.openIndexPath.row]
        }
    }

}

// Initial View
extension HomeViewController {
    
    func setView() {
        self.sortBtn = UIBarButtonItem(title: Bundle.main.localizedString(forKey: "SORT_BUTTON", value: nil, table: "lgn"), style: .plain, target: self, action: #selector(self.sortPhoto))
        self.selectBtn = UIBarButtonItem(title: Bundle.main.localizedString(forKey: "SELECT_BUTTON", value: nil, table: "lgn"), style: .plain, target: self, action: #selector(self.enableSelection))
        self.cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelection))
        
        self.naviItems.setRightBarButton(self.selectBtn, animated: false)
        self.naviItems.setLeftBarButton(self.sortBtn, animated: false)
        
        if let layout = self.collection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
        }
        
        self.collection.allowsSelection = false
        self.collection.allowsMultipleSelection = false
        
        self.gesture = UITapGestureRecognizer(target: self, action: #selector(self.photoTap))
        self.gesture.cancelsTouchesInView = false
        
        self.collection.addGestureRecognizer(self.gesture)
    }
    
    func updateSelectionTitle(show: Bool) {
        let title = Bundle.main.localizedString(forKey: "QRI-lT-Ih5.title", value: nil, table: "Main")
        if (show) {
            if (self.collection.indexPathsForSelectedItems?.count == self.allPhotoCount) {
                self.naviItems.title = "\(title) (\(Bundle.main.localizedString(forKey: "ALL_SELECTED", value: nil, table: "lgn")))"
            }else {
                self.naviItems.title = "\(title) (\(self.collection.indexPathsForSelectedItems?.count ?? 0))"
            }
        } else {
            self.naviItems.title = title
        }
    }
    
}

// Button action
extension HomeViewController {
    
    @objc func sortPhoto(_ sender: Any) {
        
        let title = Bundle.main.localizedString(forKey: "SORT_BUTTON", value: nil, table: "lgn")
        let message = Bundle.main.localizedString(forKey: "SORT_CHOICE", value: nil, table: "lgn")
        let asc = Bundle.main.localizedString(forKey: "SORT_ASCENDING", value: nil, table: "lgn")
        let dsc = Bundle.main.localizedString(forKey: "SORT_DESCENDING", value: nil, table: "lgn")
        let cancel = Bundle.init(for: UIButton.self).localizedString(forKey: "Cancel", value: nil, table: nil)
        
        let sheetAlert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        if (self.sortStateAscending) {
            sheetAlert.addAction(UIAlertAction(title: dsc, style: .default, handler: self.sortDescending))
        } else {
            sheetAlert.addAction(UIAlertAction(title: asc, style: .default, handler: self.sortAscending))
        }
        sheetAlert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
        
        self.present(sheetAlert, animated: true, completion: nil)
    }
    
    func sortAscending(_ sender: UIAlertAction) {
        self.fetchPhoto(ascending: true)
        self.sortStateAscending = true
    }
    
    func sortDescending(_ sender: UIAlertAction) {
        self.fetchPhoto(ascending: false)
        self.sortStateAscending = false
    }
    
    @objc func selectEntireGroup(_ sender: UIButton) {
        let headerCell = sender.superview as! UIPhotoCellHeader
        let indexPath = headerCell.indexPath
        let photoCellData = self.listPhotosData?[indexPath!.section]
        
        photoCellData?.selectAll = false
        headerCell.isShowSelectAll = false

        for i in 0..<photoCellData!.assets.count {
            self.collection.selectItem(at: IndexPath(row: i, section: headerCell.indexPath.section), animated: false, scrollPosition: .centeredHorizontally)
        }
        
        self.updateSelectionTitle(show: true)
    }
    
    @objc func deselectEntireGroup(_ sender: UIButton) {
        let headerCell = sender.superview as! UIPhotoCellHeader
        let indexPath = headerCell.indexPath
        let photoCellData = self.listPhotosData?[indexPath!.section]
        
        photoCellData?.selectAll = true
        headerCell.isShowSelectAll = true

        for i in 0..<photoCellData!.assets.count {
            self.collection.deselectItem(at: IndexPath(row: i, section: headerCell.indexPath.section), animated: false)
        }
        
        self.updateSelectionTitle(show: true)
    }
    
    @objc func enableSelection(_ sender: Any) {
        self.naviItems.setRightBarButton(self.cancelBtn, animated: true)
        self.naviItems.setLeftBarButton(nil, animated: true)
        
        self.listPhotosData?.forEach({ (photoCellData) in
            photoCellData.selectAll = true
        })
        
        self.collection.allowsSelection = true
        self.collection.allowsMultipleSelection = true
        
        self.collection.reloadData()
        
        self.updateSelectionTitle(show: true)
    }
    
    @objc func cancelSelection(_ sender: Any) {
        self.naviItems.setRightBarButton(self.selectBtn, animated: true)
        self.naviItems.setLeftBarButton(self.sortBtn, animated: true)
        
        self.collection.allowsSelection = false
        self.collection.allowsMultipleSelection = false
        
        self.collection.indexPathsForSelectedItems?.forEach({ (indexPath) in
            self.collection.deselectItem(at: indexPath, animated: false)
        })
        self.collection.reloadData()
        
        self.updateSelectionTitle(show: false)
    }
    
    @objc func photoTap(_ sender: UITapGestureRecognizer) {
        if !self.collection.allowsMultipleSelection {
            if let indexPath = self.collection?.indexPathForItem(at: sender.location(in: self.collection)) {
                self.openIndexPath = indexPath
                self.performSegue(withIdentifier: "viewphoto", sender: self)
            }
        }
    }

}

// Load Photo List and Metadata
extension HomeViewController {
    
    private func fetchPhoto(ascending: Bool = true) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
                let listPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                if (listPhotos.count > 0) {
                    if (self.listPhotosData != nil) {
                        self.listPhotosData?.removeAll()
                    } else {
                        self.listPhotosData = []
                    }
                    var date: Date? = nil
                    var headerSection: PhotoDataCollection? = nil
                    
                    self.allPhotoCount = listPhotos.count

                    listPhotos.enumerateObjects({ (asset, index, up) in
                        // new header if no date or a new month
                        let cal = Calendar.current
                        
                        if (date == nil ||
                            cal.component(.year, from: date!) != cal.component(.year, from: asset.creationDate!) ||
                            cal.component(.month, from: date!) != cal.component(.month, from: asset.creationDate!)) {

                            let section = DateFormatter.localizedString(from: asset.creationDate!, dateStyle: .long, timeStyle: .none)
                            headerSection = PhotoDataCollection(header: section, asset: asset)
                            self.listPhotosData?.append(headerSection!)
                            date = asset.creationDate

                        } else {
                            headerSection?.assets.append(asset)
                        }
                    })
                }
                
                DispatchQueue.main.async {
                    self.collection.reloadData()
                }
                
            case .denied, .restricted, .notDetermined:
                print("not decide")
                
            default:
                print("new ?")
            }
        }
    }
    
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectItemInSection = 0
        self.collection.indexPathsForSelectedItems?.forEach({ (selectedIndexPath) in
            if (indexPath.section == selectedIndexPath.section) {
                selectItemInSection += 1
            }
        })
        if (selectItemInSection == self.listPhotosData?[indexPath.section].assets.count) {
            let sectionIndexPath = IndexPath(row: 0, section: indexPath.section)
            let headerCell = self.collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: sectionIndexPath) as? UIPhotoCellHeader
            
            headerCell?.isShowSelectAll = false
            self.listPhotosData?[indexPath.section].selectAll = false
        }
        self.updateSelectionTitle(show: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let sectionIndexPath = IndexPath(row: 0, section: indexPath.section)
        let headerCell = self.collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: sectionIndexPath) as? UIPhotoCellHeader
        
        headerCell?.isShowSelectAll = true
        self.listPhotosData?[indexPath.section].selectAll = true
        self.updateSelectionTitle(show: true)
    }

}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.listPhotosData == nil ? 0 : self.listPhotosData!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listPhotosData![section].assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sections", for: indexPath) as! UIPhotoCellHeader
            
            cell.title.text = self.listPhotosData?[indexPath.section].headerTitle
            cell.indexPath = indexPath
            cell.isSelectEnabled = self.collection.allowsMultipleSelection
            cell.isShowSelectAll = self.listPhotosData?[indexPath.section].selectAll ?? true
            
            cell.selectAllBtn.addTarget(self, action: #selector(self.selectEntireGroup), for: .touchUpInside)
            cell.deselectAllBtn.addTarget(self, action: #selector(self.deselectEntireGroup), for: .touchUpInside)

            return cell
        }
        // there is no footer or anything else beside normal cell, so let it crash
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as! UIPhotoCell

        let asset = self.listPhotosData?[indexPath.section].assets[indexPath.row]
        cell.imageView.fetchImage(asset: asset!, targetSize: cell.imageView.frame.size, contentMode: .aspectFill)
        
        cell.setMeta(asset: asset!)

        return cell
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 40.5)
    }
    
}

extension HomeViewController: UIZoomImageViewComponentDelegate {
    
    func referenceImageView() -> UIImageView? {
        let photoCell = self.collection.cellForItem(at: self.openIndexPath) as! UIPhotoCell
        return photoCell.imageView
    }
    
    func referenceImageViewFrame() -> CGRect? {
        let photoCell = self.collection.cellForItem(at: self.openIndexPath) as! UIPhotoCell
        return self.collection.convert(photoCell.frame, to: self.view)
    }
    
}
