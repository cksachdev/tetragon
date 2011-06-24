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
	import base.data.Settings;

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
		
		private var _sep:String;
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
			_sep = File.separator;
			
			createUserDataFolder();
			createSubFolder(Settings.USER_LOGS_DIR, Registry.config.userLogsFolder);
			createSubFolder(Settings.USER_SETTINGS_DIR, Registry.config.userSettingsFolder);
			createSubFolder(Settings.USER_SAVEGAMES_DIR, Registry.config.userSaveGamesFolder);
			createSubFolder(Settings.USER_SCREENSHOTS_DIR, Registry.config.userScreenshotsFolder);
			createSubFolder(Settings.USER_PLUGINS_DIR, Registry.config.userPluginsFolder);
			copyDefaultFiles();
			
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
		
		private function createUserDataFolder():void
		{
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
						path += _sep + AppInfo.PUBLISHER;
					else if (AppInfo.CREATOR && AppInfo.CREATOR.length > 0)
						path += _sep + AppInfo.CREATOR;
				}
				else if (part == "%app_name%")
				{
					path += _sep + AppInfo.NAME;
				}
				else
				{
					path += _sep + part;
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
				Registry.settings.addSettings(Settings.USER_DATA_DIR, _userDataPath.nativePath);
			}
		}
		
		
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
		
		
		private function copyDefaultFiles():void
		{
			var userSettingsFolder:String = Registry.settings.getSettings(Settings.USER_SETTINGS_DIR);
			if (userSettingsFolder != null)
			{
				var appDir:String = File.applicationDirectory.nativePath;
				var appCfg:String = Registry.config.appConfigFileName;
				copyFile(Settings.USER_CONFIG_FILE, appDir + _sep + appCfg, userSettingsFolder + _sep + appCfg);
				var keyBindings:String = Registry.config.keyBindingsFileName;
				copyFile(Settings.USER_KEYBINDINGS_FILE, appDir + _sep + keyBindings, userSettingsFolder + _sep + keyBindings);
			}
		}
		
		
		private function copyFile(settingsKey:String, sourcePath:String, targetPath:String):void
		{
			var source:File = new File(sourcePath);
			var target:File = new File(targetPath);
			if (source.exists && !target.exists)
			{
				Log.debug("Copying \"" + sourcePath + "\" to \"" + targetPath + "\" ...", this);
				try
				{
					source.copyTo(target, false);
				}
				catch (err:Error)
				{
					fail(err.message);
				}
			}
			if (!_failed)
			{
				Registry.settings.addSettings(settingsKey, targetPath);
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
