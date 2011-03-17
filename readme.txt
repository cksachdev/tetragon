
IMPORTANT NOTE: tetragon is open source and available for anyone to use, fork or
modify. However since it is currently under 'early' development and not regarded
as being ready for public usage there will be no support as of now.


      _________  __      __
    _/        / / /____ / /________ ____ ____  ___
   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
              readme.txt           /___/
 	
tetragon - Game Engine for web- & desktop-based Flash projects.
-----------------------------------------------------------------------------------------

CONTENTS
	1. About tetragon
	2. Features
	3. Requirements
	4. Project Setup
	5. Project Structure


-----------------------------------------------------------------------------------------

1. ABOUT TETRAGON

tetragon is a game engine written in ActionScript 3 for development of games for
the Adobe Flash and AIR platforms. While it is possible to use it for small projects,
it's main focus lies clearly on more extensive game projects that may use a large
amount of assets. It can also be used for non-game projects like infographics and
microsites etc.

The structure of tetragon is pre-defined to be able to quickly set up a project and
get started without the need to write fundamental code. It offers a resource
management with that data (XML) and media files are being loaded when required and
unloaded after they aren't needed anymore. The view structure is organized in
screens and displays where a screen acts as a container for any number of display
objects (displays).

tetragon's build process relies fully on the use of Apache Ant. It offers several
build targets to compile debug and release builds and a publish target to create
distribution packages of both web-based Flash and desktop-based AIR at the same
time.


-----------------------------------------------------------------------------------------

2. FEATURES

Current features:

- Well-organized project structure.
- Comfortable build process to configure project via build.properties file and build
  both web versions (Flash) and desktop versions (AIR) all from the same code base.
- Flexible resource management. Can load from loose files, resource packages (AIR)
  and embedded files. Resource index file is used as a 'table of contents'.
- Application ini file to configure the application/game externally.
- Screens and displays view structure.
- Debug console incl. logging, command-line interface (CLI) and app monitor that
  measures FPS, MS and memory.
- Commands that can be used with the CLI or from anywhere else in the code.
- Preloader structure (web-based Flash only).
- Window bounds management. Stores window position and size (AIR only).
- Integrated Update Manager (Air only).
- Modular design. Organized in base package, game package etc.
- Error-free source code! (Yes, it's a feature ;) ).

Planned/under development features:

- Tile-based rendering engine 'Decadence'.
- Entity/Component system based object architecture.
- Unified mouse and keyboard input systems.
- Basic collision and physics system.
- Integration of 3D engines (Alternativa3D, Away3D).
- AI system.
- Last but not least: Scripting.


-----------------------------------------------------------------------------------------

3. REQUIREMENTS

tetragon is currently being developed using FDT. It will build without much
adaption if you're using FDT but you might be required to adapt the build file
if you want to build with any other tool. Build files for Flash Builder and
FlashDevelop are planned.

- FDT, Flash Builder, FlashDevelop (plus Ant) or any other AS3 development environment
  that supports Apache Ant. (The Adobe Flash IDE is not supported!)
- Adobe Flex SDK 4.1 or later.


-----------------------------------------------------------------------------------------

4. PROJECT SETUP

TODO


-----------------------------------------------------------------------------------------

5. PROJECT STRUCTURE
The tetragon project folder structure is organized as follows:

/art	Contains art assets that are created and maintained by the project artists.
		Designated as 'art' are any kind of media files that are being used by the
		resulting application, this can include images, video, audio files, 3D models
		etc. These art assets are not the final files used by the application but
		'work' files used by the artists, for example Photoshop files or uncompressed
		audio files. The art folder's hirachy depends on the needs of the artists and
		they may organize sub-folders in any way they see practical. It is the developers
		task to take any of the art files and process them into their final format
		for use in the build.

/bin	The bin folder (for 'binary') is the temporary build location for the
		application. When the project is built, the compiled application and all
		it's resources are placed into the bin folder, either for test launching
		or for further packaging. The bin folder is cleaned anytime the project
		is built (unless only re-compile is choosen) so users should NEVER copy
		any content manually to this folder. Also this folder should be excluded
		from any revision control system or file repository.

/bld	The bld folder (short for build) contains build files and templates used
		to compile and build the application. It also contains the build.properties
		file which is the first file to edit and adapt to project specifications
		before a project is first build.

/doc	Can contain project-internal documentation, for example design documents,
		spreadsheets, diagrams etc. This folder IS NOT meant for any documentation
		that might be shipped with the final application. The sub-folder structure
		of the doc folder might be adapted to suit the project's needs.

/pub	The publish folder is used to contain any resulting distribution packages
		after the project has been built for 'publish'.

/src	The src folder contains all files that are necessary to successfully build
		the application. This includes source code as well as any resource files
		that are packed along with the application. The resource files may include
		data files and finalized media files. It also contains library files
		(SWC) that are used for compilation and it may contain theme files too
		(currently theme.css is only included to supress a warning output by the
		Flex compiler).
