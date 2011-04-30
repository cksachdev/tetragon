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
package extra.game.view.screen
{
	import base.view.screen.BaseScreen;

	import extra.game.view.display.TileScrollDisplay;
	import extra.game.view.display.TileScrollInfoDisplay;

	import com.hexagonstar.util.display.StageReference;

	
	public class GameScreen extends BaseScreen
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _scrollDisplay:TileScrollDisplay;
		private var _infoDisplay:TileScrollInfoDisplay;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance.
		 */
		public function GameScreen()
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
			_scrollDisplay.start();
			_infoDisplay.tileScroller = _scrollDisplay.tileScroller;
			_infoDisplay.start();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
			_scrollDisplay.stop();
			_infoDisplay.stop();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
			_scrollDisplay.reset();
			_infoDisplay.reset();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			_scrollDisplay.update();
			_infoDisplay.update();
			super.update();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_scrollDisplay.dispose();
			_infoDisplay.dispose();
			super.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function set enabled(v:Boolean):void
		{
			super.enabled = v;
			_scrollDisplay.enabled = v;
			_infoDisplay.enabled = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set paused(v:Boolean):void
		{
			super.paused = v;
			_scrollDisplay.paused = v;
			_infoDisplay.paused = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			_infoDisplay = new TileScrollInfoDisplay();
			_scrollDisplay = new TileScrollDisplay();
			
			addLoadDisplay(_infoDisplay);
			addLoadDisplay(_scrollDisplay);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void 
		{
			addChild(_scrollDisplay);
			addChild(_infoDisplay);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addListeners():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeListeners():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function layoutChildren():void
		{
			_infoDisplay.x = 0;
			_infoDisplay.y = 0;
			_scrollDisplay.x = ((StageReference.stageWidth + _infoDisplay.width) * 0.5) - (_scrollDisplay.tileScroller.viewportWidth * 0.5);
			_scrollDisplay.y = (StageReference.stageHeight * 0.5) - (_scrollDisplay.tileScroller.viewportHeight * 0.5);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function unload():void
		{
			
		}
	}
}
