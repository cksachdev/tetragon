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
	import base.assist.AIRDesktopAssistor;
	import base.command.env.*;
	import base.command.file.*;
	
	
	/**
	 * desktop setup registry class.
	 */
	public class DesktopSetupRegistry extends SetupRegistry implements ISetupRegistry
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function registerAssistors():void
		{
			registerAssistor(AIRDesktopAssistor);
		}
		
		
		/**
		 * Extra CLI commands which should only be available for desktop builds.
		 */
		override public function registerCLICommands():void
		{
			registerCommand("env", "resetwinbounds", "rwb", ResetWinBoundsCommand, "Resets the window size and position.");
			registerCommand("env", "checkupdate", "cup", CheckUpdateCommand, "Checks if an update of the application is available.");
			registerCommand("file", "listpackages", "pak", ListPackagesCommand, "Outputs a list of all resource package files (paks).");
			registerCommand("file", "listpackagecontents", "pkc", ListPackageContentsCommand, "Outputs a list of the contents of a resource package file.");
		}
	}
}
