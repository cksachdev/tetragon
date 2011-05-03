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

	import flash.display.Sprite;
	
	
	/**
	 * ViewContainer acts as the display object container for all other views. It wraps
	 * the screen container as well as utility views like the console and FPS monitor.
	 */
	public class ViewContainer extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _console:Console;
		/** @private */
		private var _fpsMonitor:FPSMonitor;
		/** @private */
		private var _screenContainer:Sprite;
		/** @private */
		private var _utilityContainer:Sprite;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new ViewContainer instance.
		 */
		public function ViewContainer()
		{
			super();
			
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
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
		 * Updates the ViewContainer and the currently opened screen.
		 */
		public function update():void
		{
			Main.instance.screenManager.updateScreen();
		}
		
		
		/**
		 * Disposes the ViewContainer.
		 */
		public function dispose():void
		{
			removeListeners();
		}
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		override public function toString():String
		{
			return "[ViewContainer]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The container that contains any screens.
		 */
		public function get screenContainer():Sprite
		{
			return _screenContainer;
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
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
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
			addListeners();
		}
		
		
		/**
		 * @private
		 */
		private function createChildren():void
		{
			_screenContainer = new Sprite();
			addChild(_screenContainer);
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
				_console = new Console(_utilityContainer);
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
				_fpsMonitor = new FPSMonitor(_utilityContainer);
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
		private function addListeners():void
		{
		}
		
		
		/**
		 * @private
		 */
		private function removeListeners():void
		{
		}
	}
}
