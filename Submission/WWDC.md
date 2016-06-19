# Dean or Principal’s Contact Information

* Prof. Dr. Peter Barth
* peter.barth@hs-rm.de
* +49 611 9495-1256 

# App
## Why did you choose the features and technologies that you used in your app? What were your biggest technical challenges in implementing these features and technologies, and how did you overcome them? If given more time, what would you add or improve upon?

I love to travel and I love taking pictures to show them to friends. Inspired by my journeys I decided to build an app to share my stories in an appealing and simple way. 

What makes photos interesting is the location they were taken at and the history behind them. I really wanted to include this information but didn't want to loose to much space for the photo. The 3D Touch technology offered an amazing way to archive both. Showing a written text, a map and the picture side by side and letting the user dive into the picture or map with 3D Touch was the ideal solution. Another technology I was really keen to integrate were Live Photos. They add a lot of context to an image and are a wonderful addition to still pictures. In combination with 3D touch they are really fun to explore.

The most challenging problem was the extraction of meta-data (date and location) out of the photos. Different sources, like the app-bundle, the camera and the photo album, have different ways of how meta-data is stored and accessed. I solved the problem by defining a struct which stores the meta-data in a generic way (along with a image- and thumbnail reference) and one factory function per photo source. After an image was imported it could be used throughout the application without having to worry about the source.

In the app I emphasized typography in contrast to the bold presentation of the photos and tried to seamlessly integrate all UI-elements. While I reached my goal in each screen separately, the transitions between the screens offer room for improvement. When opening a story, for example, the preview photo could be smoothly transformed to match the location and size of the image in the target screen during the transition. To give the locations of the images more context, I plan to calculate an approximate travel route based on the image locations and dates instead of showing separated annotations.

To allow sharing stories with others, I have a feature in mind to publish stories to social media and the web. Since the app works completely offline, impressions can by immediately captured as image and text and uploaded in badge as soon as an internet connection is available. This is a lot more convenient then having to wait for a wifi network to post the images manually. The social media integration would make sure that sharing is as easy or even easier then with existing apps.

To offer a way to share stories aside social media platforms I want to offer a simple cloud service to upload a story and receive a static URL in response. This URL can be distributed via existing channels and can even be used to update existing stories when new images are added. The website would show the images, Live Photos and the additional information in same beautiful way the app does. 


# Travel Assistance (optional)
## If you have extenuating circumstances that would require travel assistance to attend the conference, let us know.

When I had to choose a company for the internship, which is part of my study, my choice fell on a StartUp. I had the feeling that I would learn the most there and could get a good overview over the challenges in programming, design and business. These expectations were fully fulfilled and I'm really happy that I made this choice. However, they are only able to provide a relative low compensation, especially compared to the high living costs in Frankfurt (Germany). 

I'm always seeking for new experiences, regardless if these are backpacking-journeys, new jobs or conferences. I would be more than happy if you could make it possible for me to attend the WWDC and get in touch with all the bright people there.

# Comments (optional)

The proof of enrollment is unfortunately only available in German. The verification link that is part of the document (http://www.hs-rm.de/verifizierung) in combination with the verification number (AQXE QQRX XHFK) can be used to verify my enrollment.