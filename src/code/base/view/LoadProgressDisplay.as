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
	import com.hexagonstar.signals.Signal;

	import flash.display.Sprite;
	
	
	/**
	 * A simple progress bar that displays the load progress of resources being loaded
	 * for the displays of a screen. The LoadProgressDisplay itself is not of type Display
	 * and cannot load resources for itself. It's only purpose is to show load progress.
	 */
	public class LoadProgressDisplay extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _loadProgressBar:LoadProgressBar;
		protected var _factor:Number;
		protected var _percentage:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		public var userInputSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function LoadProgressDisplay()
		{
			super();
			if (waitAfterLoad) userInputSignal = new Signal();
			setup();
			reset();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Resets the load progress bar.
		 */
		public function reset():void
		{
			_factor = _loadProgressBar.bar.width / 100;
			_percentage = 0;
			_loadProgressBar.bar.width = 1;
		}
		
		
		/**
		 * Updates the load progress bar.
		 * 
		 * @param loaded Value of data that has already been loaded.
		 * @param total Value of total data to be loaded.
		 */
		public function update(loaded:uint , total:uint):void
		{
			_percentage = loaded / total * 100;
			_loadProgressBar.bar.width = _percentage * _factor;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get waitAfterLoad():Boolean
		{
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function setup():void
		{
			_loadProgressBar = new LoadProgressBar();
			addChild(_loadProgressBar);
			
			x = 30;
			y = 30;
		}
	}
}
