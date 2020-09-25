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
protocol ActionSheetHomeLauncherDelegate : class {
    func didSelect(option : ActionSheetHomeOptions)
}
protocol ActionSheetOtherUserLauncherDelegate : class {
    func didSelect(option : ActionSheetOtherUserOptions)
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
protocol EditStudentPostDelegate : class {
     func deleteImage( for cell : StudentEditPostImageCell)
    func deleteDoc(for cell : StudentEditPostDocCell)
     func deletePdf (for cell : StudentEditPostPdfCell)
}
protocol NewPostHomeVCDelegate : class {
    func options ( for cell : NewPostHomeVC)
    func like ( for cell : NewPostHomeVC)
    func dislike ( for cell : NewPostHomeVC)
    func fav ( for cell : NewPostHomeVC)
    func comment ( for cell : NewPostHomeVC)
    func linkClick(for cell : NewPostHomeVC)
    func showProfile(for cell : NewPostHomeVC)
}
protocol NewPostHomeVCDataDelegate : class {
    func options ( for cell : NewPostHomeVCData)
    func like ( for cell : NewPostHomeVCData)
    func dislike ( for cell : NewPostHomeVCData)
    func fav ( for cell : NewPostHomeVCData)
    func comment ( for cell : NewPostHomeVCData)
        func linkClick(for cell : NewPostHomeVCData)
    func showProfile(for cell : NewPostHomeVCData)
}
protocol DataViewClick : class {
    
    func imageClik ( for cell : DataViewImageCell)
    func pdfClick( for cell : DataViewPdfCell)

}
protocol ProfileHeaderDelegate : class {
  
    func getMajorPost()
    func getSchoolPost()
    func getCoPost()
    func getFav()
}
protocol UserProfileFilterDelegate : class {
    func didSelectOption(option : ProfileFilterViewOptions)
}
protocol CommentDelegate : class {
    func likeClik(cell : CommentMsgCell)
    func replyClick(cell : CommentMsgCell)
    func seeAllReplies(cell :  CommentMsgCell)
}
