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
	import base.view.display.SplashDisplay;

	import com.hexagonstar.display.StageReference;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	
	public class SplashScreen extends BaseScreen
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _display:SplashDisplay;
		private var _timer:Timer;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance.
		 */
		public function SplashScreen()
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
			_display.start();
			_timer.start();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
			_display.stop();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
			_display.reset();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			_display.update();
			super.update();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_display.dispose();
			super.dispose();
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
		
		
		/**
		 * @inheritDoc
		 */
		override public function set enabled(v:Boolean):void
		{
			super.enabled = v;
			_display.enabled = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set paused(v:Boolean):void
		{
			super.paused = v;
			_display.paused = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onUserInput(e:Event):void
		{
			_timer.stop();
			main.screenManager.openScreen("gameScreen", true, true);
		}
		
		
		/**
		 * @private
		 */
		private function onTimerComplete(e:TimerEvent):void
		{
			/* Once the screen fades out, the user should not be able to interrupt, otherwise
			 * we might hang up somewhere so remove event listeners now. */
			removeEventListeners();
			main.screenManager.openScreen("gameScreen");
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
			_display = new SplashDisplay();
			addLoadDisplay(_display);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void 
		{
			addChild(_display);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addEventListeners():void
		{
			StageReference.stage.addEventListener(MouseEvent.CLICK, onUserInput);
			StageReference.stage.addEventListener(KeyboardEvent.KEY_DOWN, onUserInput);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeEventListeners():void
		{
			StageReference.stage.removeEventListener(MouseEvent.CLICK, onUserInput);
			StageReference.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onUserInput);
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function layoutChildren():void
		{
			_display.x = getHorizontalCenter(_display);
			_display.y = getVerticalCenter(_display);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function unload():void
		{
			
		}
	}
}
