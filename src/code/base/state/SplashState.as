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
package base.state
{
	import base.data.Registry;
	import base.view.Screen;
	import base.view.loadprogressbar.BasicLoadProgressDisplay;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.ui.Mouse;
	import flash.utils.Timer;

	
	
	/**
	 * A state that represents the application part during that the splash screen is
	 * being displayed.
	 */
	public class SplashState extends State
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _timer:Timer;
		private var _tetragonLogoSoundChannel:SoundChannel;
		private var _allowSplashAbort:Boolean;
		private var _splashScreenWaitTime:int;
		private var _initialStateID:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		override public function start():void
		{
			openScreen("splashScreen");
		}
		
		
		override public function stop():void
		{
			_timer.stop();
			if (_tetragonLogoSoundChannel) _tetragonLogoSoundChannel.stop();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		override public function get loadProgressDisplay():BasicLoadProgressDisplay
		{
			return null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		override protected function onScreenOpened(screen:Screen):void
		{
			_timer.start();
			var sound:Sound = getResource("audioLogoTetragon");
			if (sound) _tetragonLogoSoundChannel = sound.play();
		}
		
		
		private function onUserInput(e:Event):void
		{
			_timer.stop();
			removeListeners();
			Mouse.show();
			screenManager.fastTransitionOnNext();
			enterState(_initialStateID);
		}
		
		
		private function onTimerComplete(e:TimerEvent):void
		{
			/* Once the screen fades out, the user should not be able to interrupt, otherwise
			 * we might hang up somewhere so remove input listeners right here. */
			removeListeners();
			Mouse.show();
			enterState(_initialStateID);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function registerResources():void
		{
			registerResource("audioLogoTetragon");
		}
		
		
		override protected function setup():void
		{
			/* Hide mouse during splash state if fullscreen. */
			if (main.isFullscreen) Mouse.hide();
			
			_initialStateID = Registry.settings.getSettings("initialStateID");
			_allowSplashAbort = Registry.settings.getSettings("allowSplashAbort");
			_splashScreenWaitTime = Registry.settings.getSettings("splashScreenWaitTime");
			if (_splashScreenWaitTime < 1) _splashScreenWaitTime = 6;
			
			_timer = new Timer(_splashScreenWaitTime * 1000, 1);
		}
		
		
		override protected function addListeners():void
		{
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			if (_allowSplashAbort)
			{
				main.stage.addEventListener(MouseEvent.CLICK, onUserInput);
				main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onUserInput);
			}
		}
		
		
		override protected function removeListeners():void
		{
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			if (_allowSplashAbort)
			{
				main.stage.removeEventListener(MouseEvent.CLICK, onUserInput);
				main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onUserInput);
			}
		}
		
		
		override protected function dispose():void
		{
			_timer = null;
			_tetragonLogoSoundChannel = null;
		}
	}
}
