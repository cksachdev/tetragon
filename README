
      _________  __      __
    _/        / / /____ / /________ ____ ____  ___
   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
              readme.txt           /___/
 	
tetragon - Game Engine for web- & desktop-based Flash projects.
-----------------------------------------------------------------------------------------

CONTENTS
	1. Project Structure


-----------------------------------------------------------------------------------------

1. PROJECT STRUCTURE
The tetragon project folder structure is organized as follows:

/art	Contains art assets that are created and maintained by the project artists.
		Designated as 'art' are any kind of media files that are being used by the
		resulting application, this can include images, video, audio files etc. These
		art assets are not the final files used by the application but 'work' files
		used by the artists, for example Photoshop files or uncompressed audio files.
		The art folder's hirachy depends on the needs of the artists and they may
		organize sub-folders in any way they see practical. It is the developers
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
