//
//  RecipeView.swift
//  Mealody
//
//  Created by Gyorgy Borz on 2019. 12. 22..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class RecipeView: UIView {
    
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var blurView: UIView!
    
    
    func setUpView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 18
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addSubview(blurEffectView)
        blurView.sendSubviewToBack(blurEffectView)
        blurView.layer.masksToBounds = true
        blurView.layer.cornerRadius = blurView.frame.height / 2
        
        saveButton.setImage(UIImage(systemName: "book", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)), for: .normal)
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        saveButton.backgroundColor = .systemOrange
        saveButton.layer.shadowOffset = CGSize(width: 1.5, height: 3)
        saveButton.layer.shadowRadius = 0.7
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOpacity = 0.2
        
        mealLabel.text = "Meal Label"
        ingredientsTextView.isScrollEnabled = false
        ingredientsTextView.isUserInteractionEnabled = false
        ingredientsTextView.text = """
        asjdklféasdjfaklsdéfjaldséfasdfasdfasdfasdfasdf
        asdfjkasdlféajsdkflaésdjfklasédjflasédjfklasdf
        asdgjfkalsdféajsdkflaésjdfklasdégjfklésdjgkl
        asdfjkalsdéfjkalsdf
        asdfjkalsédfj fjkalsdfjaskdl fjaksdlfja kfjsdklaf jsakdlf jasdlk fjalsdéf
        sdfkaldsfjaksldfj asldkf jlasédf
        asd
        fa
        sd
        fa
        sfdasjklfédsajfkladsfjkldsaéfjadkslfjaksdlféjsadgklsadéfjsad
        f sda
        f
        dsa
        f
        sadfjaskdlfgéjasdklgaésjdfkladséjfklasdéjfkléasdf sdaf sdf asdf asdf as
        dfsadfk lsdafj sad jfaklj   k   jkj fjsdkalféjak sldfa
        sdfjkalsdéfajk sdlfé j
        dfajsdkflaésdjfklasdéfjkalsdéjgklsfdéagj sad f
        dsafjklasdéfjaksdlféjaksdlféjasdklféjasdkl gjsdakléfds
        asdfjkladsjfkalsdéjireoqéghnklfdéajklsdaf
        sdafjaksdlféjaseiwqéjksdlégsafd
        fdsajfklasdéfjwieqoréjdsklféjasdf saf
        sd
        afjaksdlféjskdaléjewkrlqéjwqléefsda
        fasdjkflaésdjfk lasjdkl éweqrq
        sadjfkladséjfioewéqjkdsléajfkléadsaf
        dsajkflésadf
        asdfjkaldséfjkla
        """
        instructionsTextView.isScrollEnabled = false
        instructionsTextView.isUserInteractionEnabled = false
        instructionsTextView.text = """
        asjdklféasdjfaklsdéfjaldséf
        asdfjkasdlféajsdkflaésdjfklasédjflasédjfklasdf
        asdgjfkalsdféajsdkflaésjdfklasdégjfklésdjgkl
        asdfjkalsdéfjkalsdf
        asdfjkalsédfj fjkalsdfjaskdl fjaksdlfja kfjsdklaf jsakdlf jasdlk fjalsdéf
        sdfkaldsfjaksldfj asldkf jlasédf
        asd
        fa
        sd
        fa
        sfdasjklfédsajfkladsfjkldsaéfjadkslfjaksdlféjsadgklsadéfjsad
        f sda
        f
        dsa
        f
        sadfjaskdlfgéjasdklgaésjdfkladséjfklasdéjfkléasdf sdaf sdf asdf asdf as
        dfsadfk lsdafj sad jfaklj   k   jkj fjsdkalféjak sldfa
        sdfjkalsdéfajk sdlfé j
        dfajsdkflaésdjfklasdéfjkalsdéjgklsfdéagj sad f
        dsafjklasdéfjaksdlféjaksdlféjasdklféjasdkl gjsdakléfds
        asdfjkladsjfkalsdéjireoqéghnklfdéajklsdaf
        sdafjaksdlféjaseiwqéjksdlégsafd
        fdsajfklasdéfjwieqoréjdsklféjasdf saf
        sd
        afjaksdlféjskdaléjewkrlqéjwqléefsda
        fasdjkflaésdjfk lasjdkl éweqrq
        sadjfkladséjfioewéqjkdsléajfkléadsaf
        dsajkflésadf
        asdfjkaldséfjkla
        """
    }
    
    func changeSaveButton() {
        saveButton.setImage(UIImage(systemName: "book.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)), for: .normal)
        saveButton.backgroundColor = .systemGreen
    }

}
