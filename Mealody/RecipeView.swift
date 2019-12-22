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
    @IBOutlet weak var recipeTextView: UITextView!
    
    
    func setUpView() {
        recipeTextView.isScrollEnabled = false
        recipeTextView.isUserInteractionEnabled = false
        recipeTextView.text = """
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

}
