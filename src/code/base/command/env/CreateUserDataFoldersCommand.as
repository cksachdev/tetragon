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
package base.command.env
{
	import base.AppInfo;
	import base.command.CLICommand;
	import base.core.debug.Log;
	import base.data.Registry;

	import flash.filesystem.File;

	
	/**
	 * This command makes sure that the user data folder and it's subfolders exist.
	 * If any of these folders don't exist, they are created.
	 */
	public class CreateUserDataFoldersCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _userDataPath:File;
		private var _failed:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void 
		{
			var sep:String = File.separator;
			var path:String = Registry.config.userDataFolder.toLowerCase();
			var parts:Array = path.split("\\").join("/").split("/");
			path = "";
			_failed = false;
			
			for (var i:uint = 0; i < parts.length; i++)
			{
				var part:String = parts[i];
				if (part.length < 1)
				{
					continue;
				}
				else if (part == "%user_documents%")
				{
					path += File.documentsDirectory.nativePath;
				}
				else if (part == "%publisher%")
				{
					if (AppInfo.PUBLISHER && AppInfo.PUBLISHER.length > 0)
						path += sep + AppInfo.PUBLISHER;
					else if (AppInfo.CREATOR && AppInfo.CREATOR.length > 0)
						path += sep + AppInfo.CREATOR;
				}
				else if (part == "%app_name%")
				{
					path += sep + AppInfo.NAME;
				}
				else
				{
					path += sep + part;
				}
			}
			
			_userDataPath = new File(path);
			
			/* Create user data folder if it doesn't exist already. */
			if (!_userDataPath.exists)
			{
				Log.debug("Creating user data folder at \"" + _userDataPath.nativePath + "\" ...", this);
				try
				{
					_userDataPath.createDirectory();
				}
				catch (err:Error)
				{
					fail(err.message);
				}
			}
			
			if (!_failed)
			{
				Registry.settings.addSettings("userDataFolder", _userDataPath.nativePath);
			}
			
			createSubFolder("userSaveGamesFolder", Registry.config.userSaveGamesFolder);
			createSubFolder("userScreenshotsFolder", Registry.config.userScreenshotsFolder);
			createSubFolder("userSettingsFolder", Registry.config.userSettingsFolder);
			createSubFolder("userLogsFolder", Registry.config.userLogsFolder);
			createSubFolder("userPluginsFolder", Registry.config.userPluginsFolder);
			
			complete();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String 
		{
			return "createUserDataFolders";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function createSubFolder(settingsKey:String, subFolderName:String):void
		{
			if (_failed) return;
			if (subFolderName && subFolderName.length > 0)
			{
				var f:File = _userDataPath.resolvePath(subFolderName.toLowerCase());
				if (!f.exists)
				{
					Log.debug("Creating " + subFolderName + " folder at \"" + f.nativePath + "\" ...", this);
					try
					{
						f.createDirectory();
					}
					catch (err:Error)
					{
						fail(err.message);
					}
				}
				if (!_failed)
				{
					Registry.settings.addSettings(settingsKey, f.nativePath);
				}
			}
		}
		
		
		private function fail(message:String):void
		{
			_failed = true;
			Log.warn("Could not create user data folder or any of it's subfolders. ("
				+ message + ")", this);
		}
	}
}
