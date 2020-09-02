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
}
