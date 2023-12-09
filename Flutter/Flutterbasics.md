# Flutter Basics


appbar : AppBar()
body: 
drawer: MySideBar()    ... return Drawer()

all the dependencies have to be added in pubspec.yaml




container for gen stuff like <div>
## Questions

- what is the 'context' every function takes
- what is the flutter way to defining structure to the application

SingleChildScrollView() : for scoling 
	scrollAxis : axis.horizto / vertial

if not working : 
	wrap in expaned widget

SCSV misbehaves insdie column

GridView.count() -> best constructor
crossaxisspacing & mainaxisspacing,
corssaxiscount -> how many cross axix items

show dialog with alert dialog can be used as ovelay

add scrollable in alertdialog (dont add)

### cool to get size of the device
MediaQuery.of(context).size.width * .7

### problem with dialog box showing listview
- wrap gridview in container
- inside gridview, shrinkWrap : true
- dont add scrollabe, or scroll axis

### adding http for oauth and api
flutter pub add http

### failed, using oauth1 now

### .toList() when saying userData.map( ) not returning proper 

### safe area to avoid notches 

### image.asset to load image from a file