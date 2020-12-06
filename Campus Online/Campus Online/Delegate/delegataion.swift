//
//  delegataion.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//
import Foundation

protocol HomeControllerDelegate : class {
    func handleMenuToggle(forMenuOption menuOption : MenuOption?)
}
protocol CoControllerDelegate : class {
    func handleMenuToggle(forMenuOption menuOption : COMenuOption?)
}
protocol SlideMenuDelegate : class  {
    func handleSlideMenuItems(for cell : HomeMenuCell)
}
protocol CoSlideMenuDelegate : class{
    func handleSlideMenuItems(for cell : CoMenuCell)
}
protocol CoSlideHeaderDelegate : class{
    func dismisMenu()
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
protocol DismisDelegate : class {
    func dismisMenu()
}
protocol ASMainPostLaungerDelgate : class {
    func didSelect(option : ASCurrentUserMainPostOptions)
}
protocol ActionSheetOtherUserLauncherDelegate : class {
    func didSelect(option : ActionSheetOtherUserOptions)
}
protocol ASMainOtherUserDelegate : class {
    func didSelect(option : ASMainPostOtherUserOptions)
}
protocol NotificationLauncherDelegate : class {
    func didSelect(option : NotificationOptions)
}
protocol PopUpDelegate : class {
    func handleDismissal()
    func addTarget(_ target : String?)
    func goDrive(_ target : String?)
}
protocol PopUpNumberDelegate : class {
    func handleDismissal()
    func addValue(_ target : String?)
 
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
protocol DeleteImageSetNewBuySell : class  {
    func deleteImage( for cell : BuySellCell)
}
protocol DeleteImageSetNewFoodMeSell : class  {
    func deleteImage( for cell : FoodMeCell)
}
protocol DeleteImageNewNoticesSell : class  {
    func deleteImage( for cell : NoticesNewCell)
}
protocol DeleteImageCampingCell : class  {
    func deleteImage( for cell : CampingCell)
}
protocol EditStudentPostDelegate : class {
     func deleteImage( for cell : StudentEditPostImageCell)
    func deleteDoc(for cell : StudentEditPostDocCell)
     func deletePdf (for cell : StudentEditPostPdfCell)
}
protocol EditFoodMePostDelegate : class {
     func deleteImage( for cell : EditFoodMeCell)

}
protocol EditCampingPostDelegate : class {
     func deleteImage( for cell : EditCampingCell)

}
protocol EditBuySellPostDelegate : class {
     func deleteImage( for cell : EditSellBuyCell)

}
protocol NewPostHomeVCDelegate : class {
    func options ( for cell : NewPostHomeVC)
    func like ( for cell : NewPostHomeVC)
    func dislike ( for cell : NewPostHomeVC)
    func fav ( for cell : NewPostHomeVC)
    func comment ( for cell : NewPostHomeVC)
    func linkClick(for cell : NewPostHomeVC)
    func showProfile(for cell : NewPostHomeVC)
    func goProfileByMention (userName : String)
    func clickMention(username : String)
    
}
protocol NewPostHomeVCDataDelegate : class {
    func options ( for cell : NewPostHomeVCData)
    func like ( for cell : NewPostHomeVCData)
    func dislike ( for cell : NewPostHomeVCData)
    func fav ( for cell : NewPostHomeVCData)
    func comment ( for cell : NewPostHomeVCData)
    func linkClick(for cell : NewPostHomeVCData)
    func showProfile(for cell : NewPostHomeVCData)
    func goProfileByMention (userName : String)
}

protocol NewPostNoticesVCDelegate : class {
    func options ( for cell : NoticesCell)
    func like ( for cell : NoticesCell)
    func dislike ( for cell : NoticesCell)
    func comment ( for cell : NoticesCell)
    func showProfile(for cell : NoticesCell)
    func goProfileByMention (userName : String)
    func clickMention(username : String)
    
}
protocol NewPostNoticesDataVCDelegate : class {
    func options ( for cell : NoticesDataCell)
    func like ( for cell : NoticesDataCell)
    func dislike ( for cell : NoticesDataCell)
    func comment ( for cell : NoticesDataCell)

    func showProfile(for cell : NoticesDataCell)
    func goProfileByMention (userName : String)
}



protocol BuySellVCDelegate : class {
    func options ( for cell : BuyAndSellView)
    func like ( for cell : BuyAndSellView)
    func dislike ( for cell : BuyAndSellView)
    
    func comment ( for cell : BuyAndSellView)
    func linkClick(for cell : BuyAndSellView)
    func showProfile(for cell : BuyAndSellView)
    func mapClick(for cell : BuyAndSellView)
    func goProfileByMention (userName : String)
}
protocol BuySellVCDataDelegate : class {
    func options ( for cell : BuyAndSellDataView)
    func like ( for cell : BuyAndSellDataView)
    func dislike ( for cell : BuyAndSellDataView)

    func comment ( for cell : BuyAndSellDataView)
    func linkClick(for cell : BuyAndSellDataView)
    func mapClick(for cell : BuyAndSellDataView)
    func showProfile(for cell : BuyAndSellDataView)
    func goProfileByMention (userName : String)
}

protocol FoodMeVCDelegate : class {
    func options ( for cell : FoodMeView)
    func like ( for cell : FoodMeView)
    func dislike ( for cell : FoodMeView)
    
    func comment ( for cell : FoodMeView)
    func linkClick(for cell : FoodMeView)
    func showProfile(for cell : FoodMeView)
    func mapClick(for cell : FoodMeView)
    func goProfileByMention (userName : String)
}
protocol FoodMeVCDataDelegate : class {
    func options ( for cell : FoodMeViewData)
    func like ( for cell : FoodMeViewData)
    func dislike ( for cell : FoodMeViewData)

    func comment ( for cell : FoodMeViewData)
    func linkClick(for cell : FoodMeViewData)
    func mapClick(for cell : FoodMeViewData)
    func showProfile(for cell : FoodMeViewData)
    func goProfileByMention (userName : String)
}
protocol CampingVCDataDelegate : class {
    func options ( for cell : CampingDataView)
    func like ( for cell : CampingDataView)
    func dislike ( for cell : CampingDataView)

    func comment ( for cell : CampingDataView)
    func linkClick(for cell : CampingDataView)
    func mapClick(for cell : CampingDataView)
    func showProfile(for cell : CampingDataView)
    func goProfileByMention (userName : String)
}
protocol CampingVCDelegate : class {
    func options ( for cell : CampingView)
    func like ( for cell : CampingView)
    func dislike ( for cell : CampingView)
    
    func comment ( for cell : CampingView)
    func linkClick(for cell : CampingView)
    func showProfile(for cell : CampingView)
    func mapClick(for cell : CampingView)
    func goProfileByMention (userName : String)
}

protocol CommentVCDataDelegate : class {

    func like (for header : CommentVCDataHeader)
    func dislike (for header : CommentVCDataHeader)
    func fav (for header : CommentVCDataHeader)

    func linkClick(for header : CommentVCDataHeader)
    func showProfile(for header : CommentVCDataHeader)
    func goProfileByMention (userName : String)
}
protocol CommentVCHeaderDelegate : class {
    func like (for header : CommentVCHeader)
    func dislike (for header : CommentVCHeader)
    func fav (for header : CommentVCHeader)
    func linkClick(for header : CommentVCHeader)
    func showProfile(for header : CommentVCHeader)
    func goProfileByMention (userName : String)
    func clickMention(username : String)
}

protocol SellBuyCommentHeaderDelegate : class {
    func like (for header : SellBuyCommentHeader)
    func dislike (for header : SellBuyCommentHeader)
    func showProfile(for header : SellBuyCommentHeader)
    func clickMention(username : String)
    func mapClik(for header : SellBuyCommentHeader)
}
protocol FoodMeCommentHeaderDelegate : class {
    func like (for header : FoodMeCommentHeader)
    func dislike (for header : FoodMeCommentHeader)
    func showProfile(for header : FoodMeCommentHeader)
    func clickMention(username : String)
    func mapClik(for header : FoodMeCommentHeader)
}
protocol CampingCommentHeaderDelegate : class {
    func like (for header : CampingCommentHeader)
    func dislike (for header : CampingCommentHeader)
    func showProfile(for header : CampingCommentHeader)
    func clickMention(username : String)
    func mapClik(for header : CampingCommentHeader)
}
protocol SellBuyDataCommentHeaderDelegate : class {
    func like (for header : SellBuyDataCommentHeader)
    func dislike (for header : SellBuyDataCommentHeader)
    func showProfile(for header : SellBuyDataCommentHeader)
    func clickMention(username : String)
    func mapClik(for header : SellBuyDataCommentHeader)
}
protocol FoodMeDataCommentHeaderDelegate : class {
    func like (for header : FoodMeDataCommentHeader)
    func dislike (for header : FoodMeDataCommentHeader)
    func showProfile(for header : FoodMeDataCommentHeader)
    func clickMention(username : String)
    func mapClik(for header : FoodMeDataCommentHeader)
}
protocol CampingDataCommentHeaderDelegate : class {
    func like (for header : CampingDataCommentHeader)
    func dislike (for header : CampingDataCommentHeader)
    func showProfile(for header : CampingDataCommentHeader)
    func clickMention(username : String)
    func mapClik(for header : CampingDataCommentHeader)
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
protocol ProfileHeaderMenuBarDelegate : class {
    func getMajorPost()
    func getSchoolPost()
    func getVayeAppPost()
    func getFavPost()
}
protocol OtherUserProfileHeaderDelegate : class {
  
    func getMajorPost()
    func getSchoolPost()
    func getCoPost()

}
protocol UserProfileMenuBarDelegate : class {
    func didSelectOptions(option : ProfileFilterOptions)
}
protocol UserProfileFilterDelegate : class {
    func didSelectOption(option : ProfileFilterViewOptions)
}
protocol OtherUserProfileFilterDelegate : class {
    func didSelectOption(option : OtherProfileFilterViewOptions)
}
protocol CommentDelegate : class {
    func likeClik(cell : CommentMsgCell)
    func replyClick(cell : CommentMsgCell)
    func seeAllReplies(cell :  CommentMsgCell)
    func goProfile(cell : CommentMsgCell)
    func clickMention(username : String)
}
