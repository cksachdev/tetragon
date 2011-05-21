/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * tetragon : Engine for Flash-based web and desktop games.
 * Licensed under the MIT License.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package base.setup
{
	import base.command.cli.*;
	import base.command.env.*;
	import base.command.file.*;
	import base.state.*;
	import base.view.splash.*;
	
	
	/**
	 * base setup registry class.
	 */
	public class BaseSetupRegistry extends SetupRegistry implements ISetupRegistry
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * CLI commands that should be available for all build types.
		 */
		override public function registerCLICommands():void
		{
			registerCommand("cli", "commands", "c", ListCLICommandsCommand, "Lists all available CLI commands.");
			registerCommand("cli", "log", null, LogCommand, "Sends the specified message to the logger.");
			registerCommand("cli", "help", "h", HelpCommand, "Shows help summary about the console or a specified command.");
			registerCommand("cli", "size", "s", ToggleConsoleSizeCommand, "Toggles between different console sizes.");
			registerCommand("cli", "listmeta", "lmt", ListMetaDataCommand, "Displays the full meta data of the application.");
			registerCommand("cli", "listcaps", "lcs", ListCapabilitiesCommand, "Lists the current runtime's capabilities.");
			registerCommand("cli", "listconfig", "lcf", ListConfigCommand, "Lists the current application configuration.");
			registerCommand("cli", "listlocalsettings", "lls", ListLocalSettingsCommand, "Lists all locally stored settings.");
			registerCommand("cli", "listsettings", "lst", ListSettingsCommand, "Lists all application settings.");
			registerCommand("cli", "listfonts", "lfn", ListFontsCommand, "Lists all available fonts.");
			registerCommand("cli", "clear", "cl", ClearConsoleCommand, "Clears the console buffer.");
			registerCommand("cli", "hide", "hd", HideConsoleCommand, "Hides the console.");
			registerCommand("cli", "setalpha", "sta", SetConsoleAlphaCommand, "Sets the console transparency to a value between 0.0 and 1.0.");
			registerCommand("cli", "setcolor", "stc", SetConsoleColorCommand, "Sets the console background color.");
			registerCommand("cli", "appinfo", "ai", OutputAppInfoCommand, "Displays application information string.");
			registerCommand("cli", "runtime", "rt", OutputRuntimeInfoCommand, "Displays information about the runtime.");
			registerCommand("cli", "listscreens", "lsc", ListScreensCommand, "Lists all registered screens.");
			registerCommand("cli", "liststates", "lss", ListStatesCommand, "Lists all registered states.");
			registerCommand("cli", "listkeyassignments", "lka", ListKeyAssignmentsCommand, "Outputs a list of all current key assignments.");
			
			registerCommand("env", "fullscreen", "fs", ToggleFullscreenCommand, "Toggles fullscreen mode (if supported).");
			registerCommand("env", "setfps", "stf", SetFramerateCommand, "Sets the stage framerate to the specified value.");
			registerCommand("env", "gc", null, ForceGCCommand, "Forces a garbage collection mark/sweep.");
			registerCommand("env", "exit", null, ExitApplicationCommand, "Exits the application.");
			registerCommand("env", "fps", null, ToggleFPSMonitorCommand, "Toggles the FPS Monitor on/off.");
			registerCommand("env", "fpspos", "fpp", ToggleFPSMonitorPosCommand, "Switches between different FPS Monitor positions.");
			registerCommand("env", "init", null, AppInitCommand, "Initializes the application.");
			registerCommand("env", "openscreen", "ops", OpenScreenCommand, "Opens the screen that is registered with the specified screen ID.");
			
			registerCommand("file", "liststrings", "str", ListStringsCommand, "Outputs a list of all mapped strings.");
			registerCommand("file", "listresources", "res", ListResourcesCommand, "Outputs a list of all mapped resources.");
			registerCommand("file", "listdatafiles", "daf", ListDataFilesCommand, "Outputs a list of all mapped resources data files.");
			registerCommand("file", "loadresource", "ldr", LoadResourceCommand, "Loads a resource by it's resource ID.");
			registerCommand("file", "unloadresource", "ulr", UnloadResourceCommand, "Unloads a previously loaded resource.");
			registerCommand("file", "unloadallresources", "ula", UnloadAllResourcesCommand, "Forces unloading of all previously loaded resources.");
			registerCommand("file", "resourceinfo", "ri", ResourceInfoCommand, "Outputs info about the resource with the specified ID.");
			registerCommand("file", "dump", "d", DumpCommand, "Outputs a string dump of the resource with the specified ID.");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registerResourceFileTypes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registerComplexTypes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registerDataTypes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registerEntitySystems():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registerEntityComponents():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registerStates():void
		{
			registerState("splashState", SplashState);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registerScreens():void
		{
			registerScreen("splashScreen", SplashScreen);
		}
	}
}
