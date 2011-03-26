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
package base.view.display
{
	import base.data.Registry;

	import flash.geom.ColorTransform;
	import flash.media.Sound;

	
	public class SplashDisplay extends Display
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new TestDisplay instance.
		 */
		public function SplashDisplay()
		{
			super();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			super.start();
			var sound:Sound = getResource("audioLogoTetragon");
			if (sound) sound.play();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function addResources():void
		{
			addResource("audioLogoTetragon");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			var logo:TetragonLogo = new TetragonLogo();
			var ct:ColorTransform = new ColorTransform();
			ct.color = Registry.config.splashLogoColor;
			logo.transform.colorTransform = ct;
			addChild(logo);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function enableChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function disableChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function pauseChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function unpauseChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addEventListeners():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeEventListeners():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayText():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function layoutChildren():void
		{
		}
	}
}
