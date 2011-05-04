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
package base.view.screen
{
	import base.data.Registry;
	import base.view.display.SplashDisplay;

	import com.hexagonstar.display.shape.RectangleGradientShape;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	
	/**
	 * A screen that shows the SplashDisplay.
	 */
	public class SplashScreen extends BaseScreen
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _background:RectangleGradientShape;
		private var _display:SplashDisplay;
		private var _timer:Timer;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			super.start();
			_timer.start();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get showLoadProgress():Boolean
		{
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onStageResize(e:Event):void
		{
			layoutChildren();
		}
		
		
		/**
		 * @private
		 */
		private function onUserInput(e:Event):void
		{
			_timer.stop();
			Mouse.show();
			screenManager.openScreen(Registry.config.initialScreenID, true, true);
		}
		
		
		/**
		 * @private
		 */
		private function onTimerComplete(e:TimerEvent):void
		{
			/* Once the screen fades out, the user should not be able to interrupt, otherwise
			 * we might hang up somewhere so remove input listeners right here. */
			removeListeners();
			Mouse.show();
			screenManager.openScreen(Registry.config.initialScreenID);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			_timer = new Timer(6000, 1);
			
			_background = new RectangleGradientShape();
			_display = new SplashDisplay();
			
			/* Hide mouse during splash screen if fullscreen. */
			if (main.isFullscreen) Mouse.hide();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerResources():void
		{
			registerResource("audioLogoTetragon");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerDisplays():void
		{
			registerDisplay(_display);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void 
		{
			addChild(_background);
			addChild(_display);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addListeners():void
		{
			main.stage.addEventListener(Event.RESIZE, onStageResize);
			main.stage.addEventListener(MouseEvent.CLICK, onUserInput);
			main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onUserInput);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeListeners():void
		{
			main.stage.removeEventListener(Event.RESIZE, onStageResize);
			main.stage.removeEventListener(MouseEvent.CLICK, onUserInput);
			main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onUserInput);
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function layoutChildren():void
		{
			_background.draw(main.stage.stageWidth, main.stage.stageHeight, -90,
				Registry.config.splashBackgroundColors);
			_display.x = getHorizontalCenter(_display);
			_display.y = getVerticalCenter(_display);
		}
	}
}
