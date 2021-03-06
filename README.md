# Beautiful drawer designs 

## Features

- Custom drawer UI
- Simple to use
- Compatible with all platforms
- Follows `stable` Flutter channel
- Sound null-safety

## Example Project

There is a pretty sweet example project in the [`example`](https://github.com/amitzero/flutter_drawers/tree/master/example) folder. Check it out. Otherwise, keep reading to get up and running.

## Getting started

First include `flutter_drawers` then enjoy as built-in widget:

```dart
import 'package:flutter_drawers/flutter_drawers.dart';

// other stuffs

BoxDrawer(
    drawer: MyDrawer(),
    alignment: DrawerAlignment.start,
    showDrawerOpener: true,
    drawerOpenerTopMargin: 8,
    animatedHeader: MyDrawerHeader(),
    headerHeight: 50,
    child: MyHomePage(),
),
```

Author [`AMIT HASAN`](https://github.com/amitzero)
<!--
## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
-->
