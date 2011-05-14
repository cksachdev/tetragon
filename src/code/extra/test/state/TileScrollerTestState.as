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
package extra.test.state
{
	import base.state.State;
	import base.view.Screen;
	import base.view.loadprogressbar.DebugLoadProgressDisplay;
	import base.view.loadprogressbar.LoadProgressDisplay;

	import flash.events.Event;
	
	
	public class TileScrollerTestState extends State
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		override public function start():void
		{
			openScreen("tileScrollerTestScreen");
		}
		
		
		override public function stop():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		override protected function onScreenOpened(screen:Screen):void
		{
		}
		
		
		private function onUserInput(e:Event):void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		override public function get loadProgressDisplay():LoadProgressDisplay
		{
			return new DebugLoadProgressDisplay();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function registerResources():void
		{
			registerResource("tileSet1Image");
			registerResource("tileSet2Image");
			registerResource("tileSet3Image");
			registerResource("fontDina08x16Image");
			
			registerResource("testTileSet");
			registerResource("bdTileSet");
			registerResource("hnTileSet");
			registerResource("tileSetDina08x16");
			
			registerResource("testTileMap");
		}
		
		
		override protected function setup():void
		{
		}
		
		
		override protected function addListeners():void
		{
		}
		
		
		override protected function removeListeners():void
		{
		}
		
		
		override protected function dispose():void
		{
		}
	}
}
