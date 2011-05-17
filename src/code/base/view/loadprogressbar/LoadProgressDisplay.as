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
package base.view.loadprogressbar
{
	import com.hexagonstar.file.BulkProgress;
	import com.hexagonstar.signals.Signal;

	import flash.display.Sprite;
	
	
	/**
	 * Abstract base class for load progress display classes.
	 * 
	 * You can use any of the sub-classes or extends this class to write your own
	 * load progress display class for use in your states.
	 */
	public class LoadProgressDisplay extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		
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
			if (waitForUserInput) userInputSignal = new Signal();
			setup();
			reset();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Resets the load progress display.
		 */
		public function reset():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Updates the load progress bar.
		 */
		public function update(progress:BulkProgress):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			if (userInputSignal)
			{
				userInputSignal.removeAll();
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines if the load progress display should request to close any screen that
		 * might be open. By default this property returns <code>false</code> which means
		 * that the load progress display appears overlaid over any open screen. You can
		 * override this getter in your sub-class and let it return <code>true</code> to
		 * have any open screen closed before the load progress display is shown.
		 * 
		 * @default <code>false</code>
		 */
		public function get closeScreenBeforeLoad():Boolean
		{
			return false;
		}
		
		
		/**
		 * Determines whether the load progress display should wait for user input before
		 * continuing after the loading completed. You can set this property to return
		 * <code>true</code> in your sub-class if you want the progress display to wait
		 * for user input after loading has finished.
		 * 
		 * @default <code>false</code>
		 */
		public function get waitForUserInput():Boolean
		{
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * 
		 */
		protected function setup():void
		{
			/* Abstract method! */
		}
	}
}
