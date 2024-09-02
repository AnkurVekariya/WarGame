# WarGame
Welcome to the WarGame project! This README will guide you on how to get the project up and running on your local machine.

## Demo

[Click here to watch the demo video](https://github.com/AnkurVekariya/WarGame/blob/main/war_game_demo.mp4)
[demo video](./main/war_game_demo.mp4)

## Running This Project
To get started with the WarGame project, follow these steps:

1. **Clone the Repository:** Clone the WarGame repository to your local machine using Git:

```shell
git clone https://github.com/AnkurVekariya/WarGame
```

2. **Open the Project:** Navigate to the cloned directory and open the WarGame.xcworkspace file using Xcode. This will allow you to view the full project source code.

3. **Build the SDK:** 

    - In Xcode, select the WarGameSDK target from the scheme selector.
    - Build the SDK by going to the menu and selecting Product > Build. This step compiles the SDK which is linked to the WarGameApp.
    
4. **Run the WarGame App:** 

    - After building the WarGameSDK, switch the target to WarGameApp.
    - Select a simulator or a physical device as the run destination.
    - Run the WarGame app by selecting Product > Run or by pressing Cmd + R. This will launch the app and you can start gameplay.

## Build and share Framework/SDK for other projects
WarGameSDK uses DeckOfCards API. To build Framework that can be sent to other developers and be used by them, folloew these steps:

Open Terminal client and navigate to the project’s folder on your disk where the .xcworkspace file is.

In this repository, I have added build_framework.sh file to include all required script to genrate universal WarGameSDK framework.

run below command
```shell
sh {path_to_file}/build_framework.sh 
```

This will run everything and output an .xcframework file. 

Add that .xcframework to any project and add with Target->Frameworks,Libraries, and Embedded Content -> add 'WarGameSDK.Framework'

okay so SDK setup is Done. Utilize WarGame Core feature from WarGameSDk.

## Additional Information

**Development:** if you wish to make changes to the SDK or the app, ensure to switch between the WarGameSDK and WarGameApp targets as needed.

**Testing:** you can run tests by selecting the appropriate test targets and running them in Xcode..

