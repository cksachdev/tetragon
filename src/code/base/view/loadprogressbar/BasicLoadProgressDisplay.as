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
	import base.event.ResourceEvent;

	import com.hexagonstar.util.display.StageReference;

	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	
	/**
	 * Very basic implementation of a load progress bar that displays a simple
	 * progress bar during loading.
	 */
	public class BasicLoadProgressDisplay extends LoadProgressDisplay
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _loadProgressBar:LoadProgressBar;
		protected var _factor:Number;
		protected var _percentage:Number;
		protected var _isPercentageFull:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		override public function reset():void
		{
			_factor = _loadProgressBar.bar.width / 100;
			_percentage = 0;
			_loadProgressBar.bar.width = 1;
		}
		
		
		override public function update(e:ResourceEvent):void
		{
			_percentage = e.bytesLoaded / e.bytesTotal * 100;
			_loadProgressBar.bar.width = _percentage * _factor;
			
			if (_percentage == 100 && !_isPercentageFull && waitForUserInput)
			{
				_isPercentageFull = true;
				StageReference.stage.addEventListener(MouseEvent.CLICK, onMouseClick);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		override public function get closeScreenBeforeLoad():Boolean
		{
			return true;
		}
		
		
		override public function get waitForUserInput():Boolean
		{
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function setup():void
		{
			var filter:GlowFilter = new GlowFilter(0x000000, 1.0, 2.0, 2.0, 100, 4);
			_loadProgressBar = new LoadProgressBar();
			_loadProgressBar.filters = [filter];
			addChild(_loadProgressBar);
			
			x = StageReference.hCenter - (width * 0.5);
			y = StageReference.vCenter - (height * 0.5);
		}
		
		
		private function onMouseClick(e:MouseEvent):void
		{
			StageReference.stage.removeEventListener(MouseEvent.CLICK, onMouseClick);
			userInputSignal.dispatch();
		}
	}
}
