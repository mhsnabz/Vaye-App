//
//  delegataion.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//


protocol HomeControllerDelegate : class {
    func handleMenuToggle(forMenuOption menuOption : MenuOption?)
}
protocol SlideMenuDelegate {
    func handleSlideMenuItems(for cell : HomeMenuCell)
}
protocol MenuHeaderDelegate : class {
    func dismisMenu()
    func showProfile()
    func editProfile()
    func editImage(for header : SlideMenuHeader)
}
protocol ActionSheetLauncherDelegate : class {
    func didSelect(option : ActionSheetOptions)
}
protocol PopUpDelegate : class {
    func handleDismissal()
    func addTarget(_ target : String?)
    func goDrive(_ target : String?)
}
protocol AddUserDelegate : class {
    func addUser(username : String?)
}
protocol DeletePdf : class {
    func deletePdf (for cell : NewPostPdfCell)
}
protocol DeleteDoc : class {
    func deleteDoc(for cell : NewPostDocCell)
}
protocol DeleteImage : class  {
    func deleteImage( for cell : NewPostImageCell)
}
protocol NewPostHomeVCDelegate : class {
    func options ( for cell : NewPostHomeVC)
    func like ( for cell : NewPostHomeVC)
    func dislike ( for cell : NewPostHomeVC)
    func fav ( for cell : NewPostHomeVC)
    func comment ( for cell : NewPostHomeVC)
}
protocol NewPostHomeVCDataDelegate : class {
    func options ( for cell : NewPostHomeVCData)
    func like ( for cell : NewPostHomeVCData)
    func dislike ( for cell : NewPostHomeVCData)
    func fav ( for cell : NewPostHomeVCData)
    func comment ( for cell : NewPostHomeVCData)
}
protocol DataViewClick : class {
    
    func imageClik ( for cell : DataViewImageCell)
    func pdfClick( for cell : DataViewPdfCell)
//    func like ( for cell : NewPostHomeVCData)
//    func dislike ( for cell : NewPostHomeVCData)
//    func fav ( for cell : NewPostHomeVCData)
//    func comment ( for cell : NewPostHomeVCData)
}
