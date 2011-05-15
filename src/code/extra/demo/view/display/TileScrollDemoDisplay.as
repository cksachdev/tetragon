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
package extra.demo.view.display
{
	import base.Main;
	import base.command.env.ToggleFullscreenCommand;
	import base.view.Display;

	import extra.game.render.tile.TileMap;
	import extra.game.render.tile.TileMapGenerator;
	import extra.game.render.tile.TileScroller;
	import extra.game.render.tile.TileSet;

	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	
	public class TileScrollDemoDisplay extends Display
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const VIEWPORT_SIZES:Array =
		[
			{w: 320,  h: 200},
			{w: 384,  h: 256},
			{w: 640,  h: 400},
			{w: 800,  h: 500},
			{w: 838,  h: 640},
			{w: 1024, h: 640},
			{w: 1280, h: 800},
			{w: 1440, h: 900},
			{w: 1600, h: 1024},
			{w: 1920, h: 1200},
		];
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _tileScroller:TileScroller;
		private var _tileset:TileSet;
		private var _tilemap:TileMap;
		private var _currentVPSize:int = 4;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		override public function stop():void
		{
			_tileScroller.stop();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public function get tileScroller():TileScroller
		{
			return _tileScroller;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.LEFT:
				case 65:
					_tileScroller.scroll("l");
					break;
				case Keyboard.RIGHT:
				case 68:
					_tileScroller.scroll("r");
					break;
				case Keyboard.UP:
				case 87:
					_tileScroller.scroll("u");
					break;
				case Keyboard.DOWN:
				case 83:
					_tileScroller.scroll("d");
					break;
				case 71:
					_tileScroller.showAreas = !_tileScroller.showAreas;
					break;
				case 77:
					_tileScroller.showMapBoundaries = !_tileScroller.showMapBoundaries;
					break;
				case 66:
					_tileScroller.showBoundingBoxes = !_tileScroller.showBoundingBoxes;
					break;
				case 82:
					_tileScroller.showBuffer = !_tileScroller.showBuffer;
					break;
				case 67:
					_tileScroller.cacheObjects = !_tileScroller.cacheObjects;
					break;
				case 80:
					_tileScroller.paused = !_tileScroller.paused;
					break;
				case 72:
					_tileScroller.autoScrollH = !_tileScroller.autoScrollH;
					break;
				case 86:
					_tileScroller.autoScrollV = !_tileScroller.autoScrollV;
					break;
				case 70:
					Main.instance.commandManager.execute(new ToggleFullscreenCommand());
					break;
				case 69:
					switchEdgeMode();
					break;
				case 84:
					_tileScroller.useTimer = !_tileScroller.useTimer;
					break;
				case 189:
				case 109:
					if (e.ctrlKey) _tileScroller.speedV--;
					else if (e.shiftKey) _tileScroller.speedH--;
					else _tileScroller.speed--;
					break;
				case 187:
				case 107:
					if (e.ctrlKey) _tileScroller.speedV++;
					else if (e.shiftKey) _tileScroller.speedH++;
					else _tileScroller.speed++;
					break;
				case 188:
					if (_tileScroller.frameRate > 10) _tileScroller.frameRate--;
					break;
				case 190:
					if (_tileScroller.frameRate < 200) _tileScroller.frameRate++;
					break;
				case 186:
					if (!e.ctrlKey && stage.frameRate > 10) stage.frameRate--;
					else if (e.ctrlKey) _tileScroller.tileAnimFrameRate--;
					break;
				case 222:
					if (!e.ctrlKey && stage.frameRate < 200) stage.frameRate++;
					else if (e.ctrlKey) _tileScroller.tileAnimFrameRate++;
					break;
				case 219:
					if (e.shiftKey) _tileScroller.deceleration -= .01;
					break;
				case 221:
					if (e.shiftKey) _tileScroller.deceleration += .01;
					break;
				case 57:
					if (e.shiftKey) _tileScroller.scale -= 0.5;
					break;
				case 48:
					if (e.shiftKey) _tileScroller.scale += 0.5;
					break;
				case 75:
					resizeViewport(false);
					break;
				case 76:
					resizeViewport(true);
					break;
				case 49:
					if (e.ctrlKey && e.shiftKey) createTilemap(1, 2);
					else if (e.ctrlKey) createTilemap(1, 1);
					else if (e.shiftKey) createTilemap(1, 3);
					else createTilemap(1, 0);
					break;
				case 50:
					if (e.ctrlKey && e.shiftKey) createTilemap(2, 2);
					else if (e.ctrlKey) createTilemap(2, 1);
					else if (e.shiftKey) createTilemap(2, 3);
					else createTilemap(2, 0);
					break;
				case 51:
					if (e.ctrlKey && e.shiftKey) createTilemap(3, 2);
					else if (e.ctrlKey) createTilemap(3, 1);
					else if (e.shiftKey) createTilemap(3, 3);
					else createTilemap(3, 0);
					break;
				case 52:
					//if (e.ctrlKey && e.shiftKey) createTilemap(4, 2);
					//else if (e.ctrlKey) createTilemap(4, 1);
					//else if (e.shiftKey) createTilemap(4, 3);
					//else createTilemap(4, 0);
					break;
				case 191:
					_tileScroller.reset();
					break;
			}
		}
		
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.LEFT:
				case 65:
					_tileScroller.stopScroll("l");
					break;
				case Keyboard.RIGHT:
				case 68:
					_tileScroller.stopScroll("r");
					break;
				case Keyboard.UP:
				case 87:
					_tileScroller.stopScroll("u");
					break;
				case Keyboard.DOWN:
				case 83:
					_tileScroller.stopScroll("d");
					break;
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function createChildren():void
		{
			var w:int = VIEWPORT_SIZES[_currentVPSize]["w"];
			var h:int = VIEWPORT_SIZES[_currentVPSize]["h"];
			_tileScroller = new TileScroller(w, h);
			createTilemap(1, 2);
			_tileScroller.start();
		}
		
		
		private function createTilemap(mapType:int, sizeRange:int = 0):void
		{
			
			if (mapType == 1) _tileset = getResource("bdTileSet");
			else if (mapType == 2) _tileset = getResource("hnTileSet");
			else if (mapType == 3) _tileset = getResource("tileSetDina08x16");
			_tileset.init();
			
			_tilemap = new TileMapGenerator().generate(_tileset, mapType, sizeRange);
			_tileScroller.tilemap = _tilemap;
		}
		
		
		override protected function addChildren():void
		{
			addChild(_tileScroller);
		}
		
		
		override protected function pauseChildren():void
		{
			_tileScroller.paused = true;
		}
		
		
		override protected function unpauseChildren():void
		{
			_tileScroller.paused = false;
		}
		
		
		override protected function addListeners():void
		{
			main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			main.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		
		private function resizeViewport(inc:Boolean):void
		{
			var w:int;
			var h:int;
			
			if (inc)
			{
				if (_currentVPSize == VIEWPORT_SIZES.length - 1) return;
				w = VIEWPORT_SIZES[_currentVPSize + 1]["w"];
				h = VIEWPORT_SIZES[_currentVPSize + 1]["h"];
				if (w > stage.stageWidth - 180)
				{
					return;
				}
				else
				{
					_currentVPSize++;
				}
			}
			else
			{
				if (_currentVPSize == 0) return;
				_currentVPSize--;
			}
			
			w = VIEWPORT_SIZES[_currentVPSize]["w"];
			h = VIEWPORT_SIZES[_currentVPSize]["h"];
			
			_tileScroller.setViewportSize(w, h);
			screen.update();
		}
		
		
		private function switchEdgeMode():void
		{
			if (_tileScroller.edgeMode == TileScroller.EDGE_MODE_OFF)
			{
				_tileScroller.edgeMode = TileScroller.EDGE_MODE_HALT;
			}
			else if (_tileScroller.edgeMode == TileScroller.EDGE_MODE_HALT)
			{
				_tileScroller.edgeMode = TileScroller.EDGE_MODE_WRAP;
			}
			else if (_tileScroller.edgeMode == TileScroller.EDGE_MODE_WRAP)
			{
				_tileScroller.edgeMode = TileScroller.EDGE_MODE_BOUNCE;
			}
			else if (_tileScroller.edgeMode == TileScroller.EDGE_MODE_BOUNCE)
			{
				_tileScroller.edgeMode = TileScroller.EDGE_MODE_OFF;
			}
		}
	}
}
