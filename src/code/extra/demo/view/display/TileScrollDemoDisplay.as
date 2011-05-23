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
	import base.io.key.KeyMode;
	import base.command.env.ToggleFullscreenCommand;
	import base.io.key.KeyManager;
	import base.view.Display;

	import extra.game.render.tile.TileMap;
	import extra.game.render.tile.TileMapGenerator;
	import extra.game.render.tile.TileScroller;
	import extra.game.render.tile.TileSet;

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
		
		override public function start():void
		{
			addKeyAssignments();
		}
		
		
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
		}
		
		
		protected function addKeyAssignments():void
		{
			var km:KeyManager = main.keyManager;
			km.assign([Keyboard.UP, Keyboard.W], 0, _tileScroller.scroll, "u");
			km.assign([Keyboard.LEFT, Keyboard.A], 0, _tileScroller.scroll, "l");
			km.assign([Keyboard.DOWN, Keyboard.S], 0, _tileScroller.scroll, "d");
			km.assign([Keyboard.RIGHT, Keyboard.D], 0, _tileScroller.scroll, "r");
			km.assign([Keyboard.UP, Keyboard.W], KeyMode.UP, _tileScroller.stopScroll, "u");
			km.assign([Keyboard.LEFT, Keyboard.A], KeyMode.UP, _tileScroller.stopScroll, "l");
			km.assign([Keyboard.DOWN, Keyboard.S], KeyMode.UP, _tileScroller.stopScroll, "d");
			km.assign([Keyboard.RIGHT, Keyboard.D], KeyMode.UP, _tileScroller.stopScroll, "r");
			km.assign(Keyboard.F, 0, main.commandManager.execute, new ToggleFullscreenCommand());
			km.assign(Keyboard.E, 0, switchEdgeMode);
			km.assign(Keyboard.K, 0, resizeViewport, false);
			km.assign(Keyboard.L, 0, resizeViewport, true);
			km.assign(Keyboard.SLASH, 0, _tileScroller.reset);
			km.assign([Keyboard.NUMPAD_ADD, Keyboard.EQUAL], KeyMode.REPEAT, changeScrollSpeed, 1);
			km.assign([Keyboard.NUMPAD_SUBTRACT, Keyboard.MINUS], KeyMode.REPEAT, changeScrollSpeed, -1);
			km.assign(["SHIFT+NUMPADPLUS", "SHIFT+="], KeyMode.REPEAT, changeScrollSpeed, 1, "h");
			km.assign(["SHIFT+NUMPAD-", "SHIFT+-"], KeyMode.REPEAT, changeScrollSpeed, -1, "h");
			km.assign(["CTRL+NUMPADPLUS", "CTRL+="], KeyMode.REPEAT, changeScrollSpeed, 1, "v");
			km.assign(["CTRL+NUMPAD-", "CTRL+-"], KeyMode.REPEAT, changeScrollSpeed, -1, "v");
			km.assign(Keyboard.G, 0, function():void {_tileScroller.showAreas = !_tileScroller.showAreas;});
			km.assign(Keyboard.M, 0, function():void {_tileScroller.showMapBoundaries = !_tileScroller.showMapBoundaries;});
			km.assign(Keyboard.B, 0, function():void {_tileScroller.showBoundingBoxes = !_tileScroller.showBoundingBoxes;});
			km.assign(Keyboard.R, 0, function():void {_tileScroller.showBuffer = !_tileScroller.showBuffer;});
			km.assign(Keyboard.C, 0, function():void {_tileScroller.cacheObjects = !_tileScroller.cacheObjects;});
			km.assign(Keyboard.P, 0, function():void {_tileScroller.paused = !_tileScroller.paused;});
			km.assign(Keyboard.H, 0, function():void {_tileScroller.autoScrollH = !_tileScroller.autoScrollH;});
			km.assign(Keyboard.V, 0, function():void {_tileScroller.autoScrollV = !_tileScroller.autoScrollV;});
			km.assign(Keyboard.T, 0, function():void {_tileScroller.useTimer = !_tileScroller.useTimer;});
			km.assign(Keyboard.COMMA, 0, function():void {if (_tileScroller.frameRate > 10) _tileScroller.frameRate--;});
			km.assign(Keyboard.PERIOD, 0, function():void {if (_tileScroller.frameRate < 200) _tileScroller.frameRate++;});
			km.assign(Keyboard.SEMICOLON, 0, function():void {if (stage.frameRate > 10) stage.frameRate--;});
			km.assign("CTRL+;", 0, function():void {_tileScroller.tileAnimFrameRate--;});
			km.assign(Keyboard.QUOTE, 0, function():void {if (stage.frameRate < 200) stage.frameRate++;});
			km.assign("CTRL+'", 0, function():void {_tileScroller.tileAnimFrameRate++;});
			km.assign("SHIFT+[", KeyMode.REPEAT, function():void {_tileScroller.deceleration -= .01;});
			km.assign("SHIFT+]", KeyMode.REPEAT, function():void {_tileScroller.deceleration += .01;});
			km.assign("SHIFT+9", 0, function():void {_tileScroller.scale -= 0.5;});
			km.assign("SHIFT+0", 0, function():void {_tileScroller.scale += 0.5;});
			km.assign(Keyboard.NUMBER_1, 0, createTilemap, 1, 0);
			km.assign("CTRL+1", 0, createTilemap, 1, 1);
			km.assign("SHIFT+1", 0, createTilemap, 1, 2);
			km.assign("SHIFT+CTRL+1", 0, createTilemap, 1, 3);
			km.assign(Keyboard.NUMBER_2, 0, createTilemap, 2, 0);
			km.assign("CTRL+2", 0, createTilemap, 2, 1);
			km.assign("SHIFT+2", 0, createTilemap, 2, 2);
			km.assign("SHIFT+CTRL+2", 0, createTilemap, 2, 3);
			km.assign(Keyboard.NUMBER_3, 0, createTilemap, 3, 0);
			km.assign("CTRL+3", 0, createTilemap, 3, 1);
			km.assign("SHIFT+3", 0, createTilemap, 3, 2);
			km.assign("SHIFT+CTRL+3", 0, createTilemap, 3, 3);
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
				_tileScroller.edgeMode = TileScroller.EDGE_MODE_HALT;
			else if (_tileScroller.edgeMode == TileScroller.EDGE_MODE_HALT)
				_tileScroller.edgeMode = TileScroller.EDGE_MODE_WRAP;
			else if (_tileScroller.edgeMode == TileScroller.EDGE_MODE_WRAP)
				_tileScroller.edgeMode = TileScroller.EDGE_MODE_BOUNCE;
			else if (_tileScroller.edgeMode == TileScroller.EDGE_MODE_BOUNCE)
				_tileScroller.edgeMode = TileScroller.EDGE_MODE_OFF;
		}
		
		
		/**
		 * @private
		 */
		private function changeScrollSpeed(value:int, direction:String = ""):void
		{
			if (direction == "h") _tileScroller.speedH += value;
			else if (direction == "v") _tileScroller.speedV += value;
			else _tileScroller.speed += value;
		}
	}
}
