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
package base.view
{
	import base.Main;
	import base.core.debug.Console;
	import base.core.debug.FPSMonitor;
	import base.data.Registry;
	import base.event.ScreenEvent;
	import base.view.screen.ScreenManager;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;

	
	
	/**
	 * ApplicationView is the main wrapper for all other display objects in the application.
	 * It contains the console, the FPS monitor and the screen container which in turn acts
	 * as a wrapper for any screens and their display children.
	 */
	public class ApplicationView extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _console:Console;
		/** @private */
		private var _fpsMonitor:FPSMonitor;
		/** @private */
		private var _screenContainer:Sprite;
		/** @private */
		private var _utilityContainer:Sprite;
		/** @private */
		private var _screenManager:ScreenManager;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new ApplicationView instance.
		 */
		public function ApplicationView(main:Main)
		{
			_main = main;
			super();
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Starts the application view and the currently opened screen.
		 */
		public function start():void
		{
			_screenManager.start();
		}
		
		
		/**
		 * Creates Console and FPSMonior, Called automatically by base setup.
		 * @private
		 */
		public function createUtilityViews():void
		{
			createConsole();
			createFPSMonitor();
		}
		
		
		/**
		 * Updates the application view and the currently opened screen.
		 */
		public function update():void
		{
			_screenManager.updateScreen();
		}
		
		
		/**
		 * Disposes the application view.
		 */
		public function dispose():void
		{
			removeEventListeners();
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return "[ApplicationView]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A reference to the screen manager.
		 */
		public function get screenManager():ScreenManager
		{
			return _screenManager;
		}
		
		
		/**
		 * A reference to the console. Will return <code>null</code> if the console has
		 * been disabled.
		 */
		public function get console():Console
		{
			return _console;
		}
		
		
		/**
		 * A reference to the FPS monitor. Will return <code>null</code> if the FPS monitor
		 * has been disabled.
		 */
		public function get fpsMonitor():FPSMonitor
		{
			return _fpsMonitor;
		}
		
		
		/**
		 * Returns <code>true</code> if the application is in fullscreen mode, otherwise
		 * <code>false</code>.
		 */
		public function get isFullscreen():Boolean
		{
			return (_main.view.stage.displayState == StageDisplayState["FULL_SCREEN_INTERACTIVE"]
				|| _main.view.stage.displayState == StageDisplayState.FULL_SCREEN);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onScreenOpened(e:ScreenEvent):void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onScreenClosed(e:ScreenEvent):void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			createChildren();
			layoutChildren();
			addEventListeners();
		}
		
		
		/**
		 * @private
		 */
		private function createChildren():void
		{
			_screenContainer = new Sprite();
			addChild(_screenContainer);
			_screenManager = new ScreenManager(_main, _screenContainer);
		}
		
		
		/**
		 * @private
		 */
		private function createConsole():void
		{
			if (!_console && Registry.config.consoleEnabled)
			{
				if (!_utilityContainer)
				{
					_utilityContainer = new Sprite();
					addChild(_utilityContainer);
				}
				_console = new Console(_main, _utilityContainer);
				_console.init();
			}
		}
		
		
		/**
		 * @private
		 */
		private function createFPSMonitor():void
		{
			if (!_fpsMonitor && Registry.config.fpsMonitorEnabled)
			{
				if (!_utilityContainer)
				{
					_utilityContainer = new Sprite();
					addChild(_utilityContainer);
				}
				_fpsMonitor = new FPSMonitor(_main, _utilityContainer);
			}
		}
		
		
		/**
		 * @private
		 */
		private function layoutChildren():void
		{
		}
		
		
		/**
		 * @private
		 */
		private function addEventListeners():void
		{
			_screenManager.addEventListener(ScreenEvent.OPENED, onScreenOpened);
			_screenManager.addEventListener(ScreenEvent.CLOSED, onScreenClosed);
		}
		
		
		/**
		 * @private
		 */
		private function removeEventListeners():void
		{
			_screenManager.removeEventListener(ScreenEvent.OPENED, onScreenOpened);
			_screenManager.removeEventListener(ScreenEvent.CLOSED, onScreenClosed);
		}
	}
}
