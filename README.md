# Moai Community SDK

The community SDK bundles a tested version of libmoai and a suite of tools to allow you to quickly create moai projects and export to multiple platforms.

Start by grabbing the latest Community SDK with
```bash
git clone https://github.com/moai/moai-community --recursive
```

##Building Moai

The community releases for windows and osx include a precompiled moai desktop binary in the bin folder to help you get started quickly and can be grabbed from here: [here](https://github.com/moaiforge/moai-community/releases). 

Follow the instructions for Configuring the SDK below and create a `env-local.sh|env-local.bat` file and build a moai binary for your platform using `.\scripts\build-windows.bat` or `scripts\build-osx.sh` or `scripts\build-linux.sh`. These scripts will drop a copy of the moai binary produced into the bin folder.

You can add the bin folder to your path and you will be able to run any Moai script from any folder.

While you can use the moai desktop binary provided to run your moai lua code, you will eventually want to build your own host. Building your own host is required to run and deploy your project on other platforms (android, ios, html) or to customize the desktop version with your own icon and customisations or in preparation for submission to an app store.

###Install prerequisites 

To build/rebuild the moai libraries ensure you have the prequisites for your target operating system installed:

####Windows Requirements
* [Visual Studio 2015 (Community edition is free)](https://www.visualstudio.com/en-us/products/visual-studio-community-vs.aspx)

####OSX and iOS Requirements
* Xcode 7+

####Linux Requirements
* [CMake 3.1+](https://cmake.org/download)
* `apt-get install cmake git-core build-essential libglu1-mesa-dev libxmu-dev libxi-dev libxxf86vm-dev libxcb-util0-dev`

####Android Requirements
* [Oracle Java JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [Android Studio and SDK](http://developer.android.com/sdk/index.html)
* [Android NDK r10e+](http://developer.android.com/ndk/downloads/index.html)

####HTML/JS Requirements
* [Emscripten SDK 1.37+](http://kripken.github.io/emscripten-site/docs/getting_started/downloads.html) 
* [CMake 3.1+](https://cmake.org/download)
* _(windows only)_ [mingw32-make](http://tdm-gcc.tdragon.net/download)

###Configure the SDK

Once the prerequisites are installed, you will need to tell the SDK where to find all the pieces. 
In the `scripts` folder of the SDK, there is a `env-local.(bat|sh).template` file which contains the 
environment variables that the SDK uses to find its prerequisites. Create a copy the file and remove the `.template` suffix.
Edit the values in there to point to the required locations. Note that not all of the variables are mandatory.


###Build Libmoai for your platform

The first step is to compile libmoai for your desired platforms.
From the SDK/scripts directory run `env-win.bat` or `source env-osx.sh` or 
`source env-linux.sh` to setup your environment.

To build the library for each platform run the corresponding `build-xxxxx` file in the script folder:
Note start with your current platform before building mobile or html libs.

* For Windows: `build-windows`, `build-android`, `build-html`
* For Linux: `build-linux`, `build-android`, `build-html`
* For OSX: `build-osx`, `build-ios`, `build-android`, `build-html`

`build-windows`, `build-osx`, `build-linux` also build the basic SDL host for the platform as well as the libraries

if these cause problems it might be because you didn't clone with `--recursive`.  No problems, just run 

```bash
git submodule update --init --recursive
```
from the root of the checkout and try again.

###Create A Project

You now should have a Moai binary for your current host and a libmoai built for each platform.
We can use the `pito` command to manage our projects and hosts going forward.

To create a project with pito:

* Ensure that the `sdk\bin` folder is on your path. 
* Find or create a folder (with no spaces in the path) to place your moai project
* Create a new project using `pito new-project <project-name>`
* cd into `<project-name>` folder to see the new project.

###Write and Run your game code

With the project setup, you can write your lua game code. Put a main.lua file in the `src` subfolder.
```lua
print("Hello World")
```

You can run this now by typing `moai` from the src folder. You should see the Moai version followed by `Hello World`.

###Create project specific hosts

Although you can just use the moai binary from the sdk to ship your product, the odds are you will want to create a custom host.

Managing and building these per platform hosts can be a headache and repeating the process for each project can get annoying. 
Thankfully this sdk provides a set of utility scripts to help with building and creating moai projects called `pito`.

    pito: https://en.wiktionary.org/wiki/pito


####Edit hostconfig.lua

`pito` uses a lua based config file `hostconfig.lua` to create host projects with the correct settings and correct lua src location.
The `hostconfig.lua` file in your project directory contains default settings for each platform, and should be edited to setup the name, source location, icon etc for the project you wish to build.


####Creating a host project for a platform

You can create (or recreate) a host project for a particular platform by running 

```bash
pito host create <host-name>
```

where `host-name` is the name of the host you want to create (normally named after the target plaform). For a list of supported host-names run 

```bash
pito host list
```

The created host will be in a subfolder called `hosts\<host-name>` in your current project. 


#### Customising the created host project

To customize the created host, you can just edit the files in `hosts\<host-name>` using either the ide (xcode, visual studio, android studio) for the project, or just with a text editor. 

A better option (when applicable) is to just update the `hostconfig.lua` with new values and run `pito host create <host-name>` again. 
This will remove your old `hosts/<host-name>` folder and create a new host with new settings. 
The advantage of this method is that you can recreate your host projects after updating the moai sdk to get all the latest fixes or customisations you have made to the sdk.


#### Building the created host projects

To build the created hosts you can launch the created project in the relevant ide (xcode, visual studio, android studio) or you can run 

```bash
pito host build <host-name>
```

or 

```bash
pito host run <host-name>
```

These scripts will create the host if it doesn't exist, then build it using the build.sh|bat script in the host directory. 
The run command will also call the run.bat|sh script in the host directory (if available) to launch the build application.
_NB You may need to ensure you environment is configured via the `env-xxxx` script again)_


###Done

You can now build moai from source and create games. You have full control over your build.
Time to grab your favourite editor, IDE and produce that next/first title.

Brush up on how the Moai SDK works from a lua perspective by reading [the basics](../basics/moai-sdk-basics-part-one.html) 

Or

Update your hello world application you just made into a real game by following 
the [Rocket Lobster](your-first-game-rocket-lobster.html) tutorial
