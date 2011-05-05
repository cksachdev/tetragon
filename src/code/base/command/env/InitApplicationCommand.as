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
	import base.command.CLICommand;
	import base.core.debug.Log;
	import base.data.Registry;
	import base.io.file.loaders.ConfigLoader;
	import base.setup.*;

	import extra.game.setup.*;
	import extra.rpg.setup.*;
	import extra.tbs.setup.*;
	import extra.test.setup.*;

	import flash.events.ErrorEvent;
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
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Execute the command.
		 */ 
		override public function execute():void
		{
			Log.init();
			Log.info("Initializing...");
			
			_setups = new Vector.<Setup>();
			/* Add base setup ... */
			_setups.push(new BaseSetup());
			
			addSetups();
			
			var s:String = "Used setups: ";
			for (var i:int = 0; i < _setups.length; i++)
				s += _setups[i].name + ", ";
			Log.debug(s.substr(0, s.length - 2));
			
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
		private function onConfigLoadComplete(e:Event):void 
		{
			if (e.type == ErrorEvent.ERROR)
			{
				Log.debug("Ini file not loaded!", this);
			}
			
			_configLoader.removeEventListener(Event.COMPLETE, onConfigLoadComplete);
			_configLoader.removeEventListener(ErrorEvent.ERROR, onConfigLoadComplete);
			postConfigSetup();
		}
		
		
		/**
		 * @private
		 */
		private function onResourceManagerReady(e:Event):void 
		{
			main.resourceManager.removeEventListener(e.type, onResourceManagerReady);
			postResourceSetup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * You can add any additional setups for extra code branches here that should
		 * be included in the application via compile-time constants. To do this you
		 * define a new compile-time constant named 'EXTRA_YOUREXTRANAME' which needs
		 * to be added to the build script.
		 * 
		 * IMPORTANT: When adding new setups make sure that it's import is not defined
		 * explicitly but rather with a star (e.g. import extra.game.setup.*;) or the
		 * compiler will still force-compile the setup class even if it isn't needed.
		 * 
		 * @private
		 */
		private function addSetups():void
		{
			/* Add Desktop-specific setup if this is an AIR Desktop build. */
			CONFIG::IS_DESKTOP_BUILD
			{
				_setups.push(new AIRDesktopSetup());
			}
			/* Add Android-specific setup if this is an AIR Android build. */
			CONFIG::IS_ANDROID_BUILD
			{
				_setups.push(new AIRAndroidSetup());
			}
			/* Add iOS-specific setup if this is an AIR iOS build. */
			CONFIG::IS_IOS_BUILD
			{
				_setups.push(new AIRIOSSetup());
			}
			
			/* You can add setups for extra code branches here if needed. */
 			CONFIG::EXTRA_TEST
			{
				_setups.push(new TestSetup());
			}
 			CONFIG::EXTRA_GAME
			{
				_setups.push(new GameSetup());
			}
 			CONFIG::EXTRA_RPG
			{
				_setups.push(new RPGSetup());
			}
 			CONFIG::EXTRA_TBS
			{
				_setups.push(new TBSSetup());
			}
		}
		
		
		/**
		 * Executes setup code that should be taken care of before the application
		 * config is loaded.
		 * 
		 * @private
		 */
		private function initialSetup():void
		{
			Log.debug("Initial setup ...");
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
				_configLoader.addEventListener(Event.COMPLETE, onConfigLoadComplete);
				_configLoader.addEventListener(ErrorEvent.ERROR, onConfigLoadComplete);
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
			Log.debug("Post-Config setup ...");
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
		 * @private
		 */
		private function postResourceSetup():void
		{
			Log.debug("Post-Resource setup ...");
			executeSetup("postResource");
			finalSetup();
		}
		
		
		/**
		 * @private
		 */
		private function finalSetup():void
		{
			Log.debug("Final setup ...");
			executeSetup("final");
			Log.info("Initialization complete.");
			Log.info("^^" + AppInfo.NAME + " v" + AppInfo.VERSION
				+ " build #" + AppInfo.BUILD
				+ (AppInfo.MILESTONE.length > 0 ? " \"" + AppInfo.MILESTONE + "\"" : "")
				+ " " + AppInfo.RELEASE_STAGE
				+ " (" + AppInfo.BUILD_TYPE
				+ (AppInfo.IS_DEBUG ? " debug" : "") + ")^^");
			if (main.console) main.console.welcome();
			
			complete();
		}
		
		
		/**
		 * @private
		 */
		private function executeSetup(step:String):void
		{
			for (var i:int = 0; i < _setups.length; i++)
			{
				Log.debug("Executing " + step + " setup on " + _setups[i].name + " ...");
				switch (step)
				{
					case "initial":
						_setups[i].initialSetup();
						break;
					case "postConfig":
						_setups[i].postConfigSetup();
						break;
					case "postResource":
						_setups[i].postResourceSetup();
						break;
					case "final":
						_setups[i].finalSetup();
						_setups[i].registrySetup();
				}
			}
		}
	}
}
