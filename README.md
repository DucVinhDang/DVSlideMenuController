# DVSlideMenuController
DVSlideMenuController is a third party help you to slide another view from left or right.
## Setup
Both left menu and right menu:
```
var containerView = DVSlideMenuController(centerViewController: nav, leftViewController: leftVC, rightViewController: rightVC)
window?.rootViewController = containerView
```

Just left menu:
```
var containerView = DVSlideMenuController(centerViewController: nav, leftViewController: leftVC)
window?.rootViewController = containerView
```

Just right menu:
```
var containerView = DVSlideMenuController(centerViewController: nav, rightViewController: rightVC)
window?.rootViewController = containerView
```

## DVSlideMenuController object
```
dvSlideMenuController()
```

## Toggle buttons
>Add with image:
```
addLeftToggleButtonWithImage(imageName: String)
addRightToggleButtonWithImage(imageName: String)
```

>Add with title:
```
addLeftToggleButtonWithTitle(title: String)
addRightToggleButtonWithTitle(title: String)
```

## Show panel
```
toggleLeftPanel()
toggleRightPanel()
```

## Hide panel
```
hideThisPanel()
```

## Change center view
```
dvSlideMenuController()?.setCenterViewController(newCenterViewController)
```

## Detect DVSlideMenuController states
```
optional func dvSlideMenuControllerWillShowLeftPanel()
optional func dvSlideMenuControllerDidShowLeftPanel()
optional func dvSlideMenuControllerWillHideLeftPanel()
optional func dvSlideMenuControllerDidHideLeftPanel()

optional func dvSlideMenuControllerWillShowRightPanel()
optional func dvSlideMenuControllerDidShowRightPanel()
optional func dvSlideMenuControllerWillHideRightPanel()
optional func dvSlideMenuControllerDidHideRightPanel()
```
