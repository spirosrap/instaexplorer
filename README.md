# Instaexplorer

Insta explorer is an app that allows a user to explore images on instagram using a map, searching for related hastags and 
create favorites without notifying users of that. Also the user can see these photos in a detail view and then share these photos in social media or save them to 
the device.

The app consists of 3 tabs:

1st tab (Map):
--------------
1)A user can create an annotation(a pin) using a long press to create an album of images (in both collection and table view).
  Annotation views appear for each placed annotation and an album is saved. User can later tap on annotation views and
  see again the saved albums.
2) Delete annotations(pins). In left top there is the button delete which allows the user to delete existing albums and it's 
   associated images. When the user has deleted an annotation they can press return to the mode of adding new annotations by
   long press again.
3) Dragging annotations. All annotation can be moved around the map(by long press). When moved the previous album is erased and a new
   one is created. When a pin is placed somewhere where there are no images around the pin is deleted.
4) The user also ,besides zooming,panning,pinching, can go to any location by geocoding in the search bar.
5) The map is can be shown in standard, satellite and hybrid mode

2nd tab (Favorites):
--------------------
Every favorited image is shown in the Favorites tab in collection view and table view. They can be removed there by taping
in the detail view's star or by simply by deleting in collection view and table view. The edit button can be used to delete images 
in collection view or table view.

3d tab (search)
-----------------
Like searching on a map, the user can search by a hashtag. After displaying a hastag an album for that hashtag is created
and saved. the user can see tha saved hashtags, delete them, add new ones and see the saved related images.
Deletion can be done simply by the usual left swipe in table view or by tapping at edit in top left corner.

Image detail view
-----------------
For each image there is an image detail view. Which presents the images pretty much like the instagram (but not exactly like it)
User can favorite an image and also see the comment the originator of the image has created.
If the image originator has left a comment with hastags in it, they can click on the hashtag like a link and see associated images.
The image can also be shared to social media and also saved to disk Unlike instagram which only alows to share it and copy
link's image.

Limitations:
------------
As of April 2015 instagram api doesn't allow posting so functionality that would post data to instagram was not created.


![alt tag](https://raw.githubusercontent.com/spirosrap/insta/master/sc1.png)
![alt tag](https://raw.githubusercontent.com/spirosrap/insta/master/sc2.png)
![alt tag](https://raw.githubusercontent.com/spirosrap/insta/master/sc3.png)
