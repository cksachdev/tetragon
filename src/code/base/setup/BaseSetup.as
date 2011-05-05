/* *      _________  __      __ *    _/        / / /____ / /________ ____ ____  ___ *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \ *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/ *                                   /___/ *  * tetragon : Engine for Flash-based web and desktop games. * Licensed under the MIT License. *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package base.setup{	import base.core.cli.CLICommandRegistry;	import base.core.debug.Log;	import base.data.Registry;	import base.io.key.Key;	import base.view.screen.DummyScreen;	import base.view.screen.SplashScreen;	import flash.display.Stage;	import flash.geom.Rectangle;			/**	 * Default setup steps for web- and desktop-based applications.	 */	public class BaseSetup extends Setup	{		//-----------------------------------------------------------------------------------------		// Public Methods		//-----------------------------------------------------------------------------------------				/**		 * @inheritDoc		 */		override public function initialSetup():void		{			/* Initialize some factories. */			dataClassesFactory.init();						super.initialSetup();		}						/**		 * @inheritDoc		 */		override public function postConfigSetup():void		{			/* We have the config loaded now so set the default locale as the			 * currently used locale. */			Registry.config.currentLocale = Registry.config.defaultLocale.toLowerCase();						main.setupDebugUtilities();						/* Now that app config is loaded, ready the Logger. */			Log.ready(main);						super.postConfigSetup();		}						/**		 * @inheritDoc		 */		override public function postResourceSetup():void		{			main.setupEntityManagers();			main.keyManager.clearAssignments();			var keyCodes:Array;						if (Registry.config.consoleEnabled)			{				keyCodes = Key.getKeyCodes(Registry.config.consoleKey);				main.keyManager.assignKeyCombination(keyCodes, main.console.toggle);			}						if (Registry.config.fpsMonitorEnabled)			{				keyCodes = Key.getKeyCodes(Registry.config.fpsMonitorKey);				main.keyManager.assignKeyCombination(keyCodes, main.fpsMonitor.toggle);				keyCodes = Key.getKeyCodes(Registry.config.fpsMonitorPositionKey);				main.keyManager.assignKeyCombination(keyCodes, main.fpsMonitor.togglePosition);			}		}						/**		 * @inheritDoc		 */		override public function finalSetup():void		{			var s:Stage = main.contextView.stage;			s.fullScreenSourceRect = new Rectangle(0, 0, s.stageWidth, s.stageHeight);						/* Check if app should run in fullscreen mode. */						// TODO To be changed! Fullscreen state should not be stored in app.ini			// but in user settings file!			//			//if (_main.config.useFullscreen)			//{			//	var fullscreenMode:String = StageDisplayState.FULL_SCREEN;			//	/*FDT_IGNORE*/			//	CONFIG::IS_AIR_BUILD			//	/*FDT_IGNORE*/			//	{			//		fullscreenMode = StageDisplayState.FULL_SCREEN_INTERACTIVE;			//	}			//	s.displayState = fullscreenMode;			//}						/* Register standard CLI commands if we have the Console available. */			if (main.console && main.console.cli)			{				new CLICommandRegistry(main);			}		}						//-----------------------------------------------------------------------------------------		// Getters & Setters		//-----------------------------------------------------------------------------------------				/**		 * @inheritDoc		 */		override public function get name():String		{			return "base";		}						//-----------------------------------------------------------------------------------------		// Private Methods		//-----------------------------------------------------------------------------------------				/**		 * @inheritDoc		 */		override protected function mapDataTypes():void		{		}						/**		 * @inheritDoc		 */		override protected function registerScreens():void		{			main.screenManager.registerScreen("splashScreen", SplashScreen);			main.screenManager.registerScreen("dummyScreen", DummyScreen);		}	}}