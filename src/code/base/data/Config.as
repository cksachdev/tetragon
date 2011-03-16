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
package base.data
{
	/**
	 * The application's global config model. Access this object via Registry!
	 */
	public class Config
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public var loggingEnabled:Boolean;
		public var loggingFilterLevel:int;
		
		public var consoleEnabled:Boolean;
		public var consoleAutoOpen:Boolean;
		public var consoleTween:Boolean;
		public var consoleMonochrome:Boolean;
		public var consoleKey:String;
		public var consoleSize:int;
		public var consoleTransparency:Number;
		public var consoleFontSize:int;
		public var consoleMaxBufferSize:int;
		public var consoleColors:Array;
		
		public var fpsMonitorEnabled:Boolean;
		public var fpsMonitorAutoOpen:Boolean;
		public var fpsMonitorPollInterval:Number;
		public var fpsMonitorKey:String;
		public var fpsMonitorPositionKey:String;
		public var fpsMonitorPosition:String;
		public var fpsMonitorColors:Array;
		
		public var defaultLocale:String;
		public var currentLocale:String;
		
		public var resourceFolder:String;
		public var resourceIndexFile:String;
		
		public var ioLoadConnections:int;
		public var ioLoadRetries:int;
		public var ioUseAbsoluteFilePath:Boolean;
		public var ioPreventFileCaching:Boolean;
		
		public var userDataFolder:String;
		public var userSaveGamesFolder:String;
		public var userScreenshotsFolder:String;
		public var userSettingsFolder:String;
		public var userPluginsFolder:String;
		
		public var updateEnabled:Boolean;
		public var updateURL:String;
		public var updateAutoCheck:Boolean;
		public var updateCheckInterval:Number;
		public var updateCheckVisible:Boolean;
		public var updateDownloadProgressVisible:Boolean;
		public var updateDownloadUpdateVisible:Boolean;
		public var updateFileUpdateVisible:Boolean;
		
		public var backgroundFrameRate:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Config()
		{
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes app config with hard-coded default values.
		 * These will be overwritten if the app.ini could be loaded.
		 */
		public function init():void
		{
			loggingEnabled = true;
			loggingFilterLevel = 0;
			
			consoleEnabled = true;
			consoleAutoOpen = false;
			consoleTween = true;
			consoleMonochrome = false;
			consoleKey = "F8";
			consoleSize = 2;
			consoleTransparency = 1.0;
			consoleFontSize = 11;
			consoleMaxBufferSize = 40000;
			consoleColors = ["111111", "D4FFFF", "AAAAAA", "FFFFFF", "FFD400", "FF7F00", "FF0000", "FFFFAA"];
			
			fpsMonitorEnabled = true;
			fpsMonitorAutoOpen = false;
			fpsMonitorPollInterval = 0.5;
			fpsMonitorKey = "F9";
			fpsMonitorPositionKey = "F11";
			fpsMonitorPosition = "TR";
			fpsMonitorColors = ["111111", "FFFFFF", "55D4FF", "FFCC00", "FF6600"];
			
			defaultLocale = "en";
			
			resourceFolder = "resources";
			resourceIndexFile ="resources.xml";
			
			ioLoadConnections = 1;
			ioLoadRetries = 0;
			ioUseAbsoluteFilePath = false;
			ioPreventFileCaching = false;
			
			userDataFolder = "%user_documents%/%meta_publisher%";
			userSaveGamesFolder = "savegames";
			userScreenshotsFolder = "screenshots";
			userSettingsFolder = "settings";
			userPluginsFolder = "plugins";
			
			updateEnabled = true;
			updateURL = null;
			updateAutoCheck = true;
			updateCheckInterval = 1;
			updateCheckVisible = false;
			updateDownloadProgressVisible = true;
			updateDownloadUpdateVisible = true;
			updateFileUpdateVisible = true;
			
			backgroundFrameRate = -1;
		}
	}
}
