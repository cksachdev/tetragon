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
	import base.AppResourceBundle;
	import base.AppSetups;
	import base.command.CLICommand;
	import base.core.debug.Console;
	import base.core.debug.Log;
	import base.data.Registry;
	import base.io.file.loaders.ConfigLoader;
	import base.io.resource.Resource;
	import base.io.resource.ResourceIndex;
	import base.io.resource.ResourceManager;
	import base.io.resource.ResourceStatus;
	import base.setup.BaseSetup;
	import base.setup.Setup;

	import flash.events.Event;
	
	
	/**
	 * Executes the application initialization procedure. This command creates
	 * the setup for any application (web- and desktop-based) and additionally
	 * the air setup for desktop-based applications and utilizes these to run
	 * through the initialization which consists of the following steps:
	 * 
	 * 1. Initial
	 * 2. Load application config file "app.ini" (if not set to ignored by params!)
	 * 3. Post-Config
	 * 4. Resource Manager initialization
	 * 5. Post-Resource
	 * 6. Final
	 */
	public class InitApplicationCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _configLoader:ConfigLoader;
		private var _setups:Vector.<Setup>;
		private var _settingsFileIDs:Array;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Execute the command.
		 */ 
		override public function execute():void
		{
			Log.init();
			Log.info("Initializing...", this);
			
			createSetups();
			initialSetup();
			loadApplicationConfig();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			_configLoader.dispose();
			_configLoader = null;
			_setups = null;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return "AppInit";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "initApplication";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onConfigLoadComplete():void 
		{
			_configLoader.completeSignal.remove(onConfigLoadComplete);
			_configLoader.errorSignal.remove(onConfigLoadError);
			postConfigSetup();
		}
		
		
		/**
		 * @private
		 */
		private function onConfigLoadError(message:String):void 
		{
			Log.debug("Ini file not loaded! (error was: " + message + ")", this);
			_configLoader.completeSignal.remove(onConfigLoadComplete);
			_configLoader.errorSignal.remove(onConfigLoadError);
			postConfigSetup();
		}
		
		
		/**
		 * @private
		 */
		private function onResourceManagerReady(e:Event):void 
		{
			main.resourceManager.removeEventListener(e.type, onResourceManagerReady);
			loadSettings();
		}
		
		
		/**
		 * @private
		 */
		private function onSettingsLoadComplete():void
		{
			if (_settingsFileIDs && _settingsFileIDs.length > 0)
			{
				var rm:ResourceManager = main.resourceManager;
				var ri:ResourceIndex = rm.resourceIndex;
				for (var i:uint = 0; i < _settingsFileIDs.length; i++)
				{
					var r:Resource = ri.getResource(_settingsFileIDs[i]);
					if (r.status == ResourceStatus.FAILED)
					{
						Log.error("Failed loading settings: \"" + r.id + "\".", this);
					}
					else
					{
						Log.info("Loaded settings: \"" + r.id + "\".", this);
						/* Settings have been parsed into settings map so their resource
						 * can be unloaded again. */
						rm.unload(_settingsFileIDs);
					}
				}
			}
			
			postSettingsSetup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function createSetups():void
		{
			var i:uint;
			_setups = new Vector.<Setup>();
			/* Add base setup ... */
			_setups.push(new BaseSetup());
			/* Add any additional setups that are listed in AppSetups ... */
			var a:Array = new AppSetups().setups;
			for (i = 0; i < a.length; i++)
			{
				var clazz:Class = a[i];
				if (clazz)
				{
					var setup:* = new clazz();
					if (setup is Setup)
					{
						_setups.push(setup);
					}
					else
					{
						Log.fatal("setup \"" + setup + "\" is not of type Setup!", this);
					}
				}
			}
			
			var s:String = "Used setups: ";
			for (i = 0; i < _setups.length; i++)
			{
				s += _setups[i].name + ", ";
			}
			Log.debug(s.substr(0, s.length - 2), this);
		}
		
		
		/**
		 * Executes setup code that should be taken care of before the application
		 * config is loaded.
		 * 
		 * @private
		 */
		private function initialSetup():void
		{
			Log.debug("Initial setup ...", this);
			executeSetup("initial");
		}
		
		
		/**
		 * Initiates the loading of the application config file (app.ini).
		 * @private
		 */
		private function loadApplicationConfig():void
		{
			/* If config should not be loaded, carry on to the next step directly. */
			if (Registry.params && Registry.params.ignoreIniFile)
			{
				postConfigSetup();
			}
			else
			{
				/* Create ini filename that uses the same first part as the SWF. This
				 * assures that we can have several SWFs with their own ini file if needed. */
				_configLoader = new ConfigLoader();
				_configLoader.completeSignal.addOnce(onConfigLoadComplete);
				_configLoader.errorSignal.addOnce(onConfigLoadError);
				_configLoader.addFile(AppInfo.FILENAME + ".ini", "configFile");
				_configLoader.load();
			}
		}
		
		
		/**
		 * Executes setup code that should be taken care of after the application
		 * config is loaded but before the application UI (and console) is created.
		 * 
		 * @private
		 */
		private function postConfigSetup():void
		{
			Log.debug("Post-Config setup ...", this);
			executeSetup("postConfig");
			initResourceManager();
		}
		
		
		/**
		 * Initializes the Resource Manager.
		 * @private
		 */
		private function initResourceManager():void
		{
			main.resourceManager.addEventListener(Event.COMPLETE, onResourceManagerReady);
			main.resourceManager.init(main, AppResourceBundle);
		}
		
		
		/**
		 * Loads the settings from the resources.
		 * @private
		 */
		private function loadSettings():void
		{
			_settingsFileIDs = main.resourceManager.resourceIndex.getSettingsFileIDs();
			if (_settingsFileIDs && _settingsFileIDs.length > 0)
			{
				main.resourceManager.load(_settingsFileIDs, onSettingsLoadComplete);
			}
			else
			{
				onSettingsLoadComplete();
			}
		}
		
		
		/**
		 * @private
		 */
		private function postSettingsSetup():void
		{
			Log.debug("Post-Settings setup ...", this);
			executeSetup("postSettings");
			finalSetup();
		}
		
		
		/**
		 * @private
		 */
		private function finalSetup():void
		{
			Log.debug("Final setup ...", this);
			executeSetup("final");
			
			Log.info("Initialization complete.", this);
			Log.linefeed();
			Log.info(Console.LINED + AppInfo.NAME + " v" + AppInfo.VERSION
				+ " build #" + AppInfo.BUILD
				+ (AppInfo.MILESTONE.length > 0 ? " \"" + AppInfo.MILESTONE + "\"" : "")
				+ " " + AppInfo.RELEASE_STAGE
				+ " (" + AppInfo.BUILD_TYPE
				+ (AppInfo.IS_DEBUG ? " debug" : "") + ")" + Console.LINED);
			if (main.console) main.console.welcome();
			Log.linefeed();
			
			complete();
		}
		
		
		/**
		 * @private
		 */
		private function executeSetup(step:String):void
		{
			for (var i:int = 0; i < _setups.length; i++)
			{
				Log.debug("Executing " + step + " setup on " + _setups[i].name + " ...", this);
				switch (step)
				{
					case "initial":
						_setups[i].initialSetup();
						break;
					case "postConfig":
						_setups[i].postConfigSetup();
						break;
					case "postSettings":
						_setups[i].postSettingsSetup();
						break;
					case "final":
						_setups[i].finalSetup();
						_setups[i].registrySetup();
				}
			}
		}
	}
}
