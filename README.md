<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
# Garden Companion

A app which helps users identify plants, do a health assement of their plants, make posts to share with the community and chat with their friends. A one stop app for all your home gardening needs.

This app is the project work for Software Engineering Course - CS302L

## How to install

This project is made is using flutter sdk. Download the latest version of the flutter sdk [[here]](https://docs.flutter.dev/get-started/install).
The sdk versions used are:
~~~yaml
environment:
  sdk: '>=3.0.6 <4.0.0'
  min_sdk_android: 21
~~~

The exact versions of the dependencies used can be found in the 'pubspec.yaml' file. 

To download the repo simply navigate to the folder where you want to install the app, in the terminal enter:

~~~bash
git clone https://github.com/teJab-2610/garden_companion.git
~~~

Note: you must have git installed on your system.

Now, run the following commands on the terminal.
~~~bash
cd .\garden_companion\
flutter pub get
flutter run
~~~
Note: Although a emulator can be used for testing the app, we reccomend the use of a physical device as then you can test the camera ad picture upload feature.

To set up a physical device you will have to enable _developer_ _mode_ on your phone and enable USB(or Wireless) debugging. Click yes for any additional permissions if asked.

##App Flow
```mermaid
graph TD;
    A[Startup] --> B[Welcome Screen];
    B --> C[Login/Register/google sign in page];
    C --> |Login| D[Login Page];
    C --> |Register| E[Register Page];
    C --> |Google sign-in| F 
    E --> D;
    D --> F[Home Page];
    F --> |Bottom Search icon| G[Plant Search]
    F --> |Top Search icon| K[User Search]
    K --> |If valid user| P[User Profile]
    P --> |Group Icon| Q[Group Chat]
    F --> |Cam icon| H[Plant Id & Health assesment]
    F --> |Posts icon| I[Posts Page]
    F --> |Produce icon| J[Offerings page]
    H --> |upload pic from cam/gallery|L[Suggestions]
    L --> |Click on one suggestion| M[Suggestion details]
    M --> |More Details| N[Care Guide & FAQs]
    I --> |Plus icon| O[New post screen]
```````

##Features

The following are the features in our app. They are discussed in detail later in this document.

1. **Sign-in page**: The sign in page has 3 options, to login (for existing users), to register a new account (for new users) and Google sign-in.
2. **Home Page**: Once logged in, The user is directed to the home page. As per the app flow user can navigate from here to any feature of the app.
3. **Plant Search**: The plant searcher feature can be used to search for any plants among a database of over 10,000 plants! You just need to enter the common/scientific name of the plant and it will show the best suggestions. further details can be expanded by clicking upon one suggestion.
4. **User Search**: search your gardening friends my just entering their email-id! A valid email will open the profile page where you can see their recent posts and follow them.
5. **Plant Id**: Search any plant by just their photo! upload using camera or gallery. Suggestion will contain probability with highest probability at top. Users can click on any suggestion to get more details. They can also get info about care guides and FAQs!
6. **Posts**: Users will see the posts from accounts they follow. They can also create posts by uploading images or just plain text!
7. **Offerings**: Users can put up their produce for exchange on the offerings page, here other users can view and finalize deals.

