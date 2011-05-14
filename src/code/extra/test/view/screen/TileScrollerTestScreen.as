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
package extra.test.view.screen
{
	import base.view.Screen;

	import extra.test.view.display.TileScrollTestDisplay;
	import extra.test.view.display.TileScrollTestInfoDisplay;
	
	
	public class TileScrollerTestScreen extends Screen
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _infoDisplay:TileScrollTestInfoDisplay;
		private var _scrollDisplay:TileScrollTestDisplay;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		override public function start():void
		{
			super.start();
			_infoDisplay.tileScroller = _scrollDisplay.tileScroller;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function createChildren():void
		{
			_infoDisplay = new TileScrollTestInfoDisplay();
			_scrollDisplay = new TileScrollTestDisplay();
		}
		
		
		override protected function registerDisplays():void
		{
			registerDisplay(_infoDisplay);
			registerDisplay(_scrollDisplay);
		}
		
		
		override protected function addChildren():void 
		{
			addChild(_scrollDisplay);
			addChild(_infoDisplay);
		}
		
		
		override protected function layoutChildren():void
		{
			_infoDisplay.x = 0;
			_infoDisplay.y = 0;
			_scrollDisplay.x = _infoDisplay.width + ((main.stage.stageWidth - _infoDisplay.width) * 0.5) - (_scrollDisplay.tileScroller.viewportWidth * 0.5);
			_scrollDisplay.y = (main.stage.stageHeight * 0.5) - (_scrollDisplay.tileScroller.viewportHeight * 0.5);
		}
	}
}
