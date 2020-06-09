# Mealody

A simple recipe app. The users can request a random recipe or browse the available ones by categories or countries. 
The users can select ingredients and get recipes which contain those ingredients.
All the recipes can be saved.

Technologies: Swift, UIKit, Core Data, PopupDialog, NVActivityIndicator

Third party libraries I used:

- for the popup error messages: https://github.com/Orderella/PopupDialog

- for the activity indicators: https://github.com/ninjaprox/NVActivityIndicatorView

The api for the recipes: https://www.themealdb.com

<a href="https://apps.apple.com/app/id1492125687" rel="some text">![download](https://user-images.githubusercontent.com/44786735/70862038-112c4e00-1f37-11ea-9694-7b46c3404b3a.png)</a>

------

The users can request random recipes in 'Random'. Tapping on the button initiates a request which returns a recipe.

![picture_1](https://user-images.githubusercontent.com/44786735/73124120-c8d16880-3f97-11ea-8324-b7288c29a01d.png)

In 'Browse' the user can pick any recipe from different categories and countries.

![picture_2](https://user-images.githubusercontent.com/44786735/73124154-4f864580-3f98-11ea-9b78-e4a7f7e4af08.png)

In 'Ingredients' the users can search and select ingredients. There are quite a lot so there is a card-like view which 
shows all the selected ingredients. Here the users can delete them and thus they get deselected simultaneously on the main screen too.
As soon as one ingredient gets selected, a 'Recipes' button appears, which upon tapping returns recipes that contain the chosen
ingredients. The users can select as many as they want, but currently the api can only accept 4 different ingredients at once.
This warning shows up in a popup message before requesting the recipes.

![picture_3](https://user-images.githubusercontent.com/44786735/73124516-81011000-3f9c-11ea-97c9-0522d1dc3638.png)

In 'Saved' the users can see and delete their saved recipes.

![picture_4](https://user-images.githubusercontent.com/44786735/73124532-d9381200-3f9c-11ea-9f3b-e1827fd1da24.png)


