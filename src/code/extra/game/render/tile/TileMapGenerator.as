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
 *   __| ___  __  __   __| ___  __  __  ___  
 *  (__|(__/_(___(__(_(__|(__/_|  )(___(__/__
 *  tile scrolling engine
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
package extra.game.render.tile
{
	import base.data.constants.Palettes;
	import base.util.ColorUtil;
	import base.util.Dice;
	import base.util.NumberGenerator;

	
	public class TileMapGenerator
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _tileset:TileSet;
		/** @private */
		private var _tilemap:TileMap;
		/** @private */
		private var _tileIDCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Generates a random tilemap.
		 * 
		 * @param sizeRange 0 = any, 1 = small, 2 = medium, 3 = large
		 * @return The generated tilemap.
		 */
		public function generate(tileset:TileSet, mapType:int, sizeRange:int = 0):TileMap
		{
			_tileset = tileset;
			_tileIDCount = 0;
			switch (mapType)
			{
				case 1:
					generateType1Map(sizeRange);
					break;
				case 2:
					generateType2Map(sizeRange);
					break;
				case 3:
					generateType3Map(sizeRange);
					break;
				case 4:
					generateType4Map(sizeRange);
					break;
			}
			_tilemap.measure();
			var tilemap:TileMap = _tilemap;
			_tilemap = null;
			_tileset = null;
			return tilemap;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[TileMapGenerator]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function generateType1Map(sr:int):void
		{
			/* Determine random map size. */
			var minSize:int = (sr == 0) ? 2 : (sr == 1) ? 2 : (sr == 2) ? 20 : 100;
			var maxSize:int = (sr == 0) ? 200 : (sr == 1) ? 10 : (sr == 2) ? 40 : 200;
			var w:int = NumberGenerator.random(minSize, maxSize);
			var h:int = NumberGenerator.random(minSize, maxSize);
			var i:int;
			
			_tilemap = new TileMap();
			
			/* Determine random map margin. */
			if (Dice.chance(33)) _tilemap.margin = 0;
			else _tilemap.margin = NumberGenerator.random(20, 200);
			
			/* Random bg color */
			_tilemap.backgroundColor = ColorUtil.randomColor(Palettes.C64);
			_tilemap.edgeMode = TileScroller.EDGE_MODE_HALT;
			
			var hBorder:TileGroupDefinition = _tileset.getGroupDefinitionByID("hBorder");
			var vBorder:TileGroupDefinition = _tileset.getGroupDefinitionByID("vBorder");
			var wall:TileGroupDefinition = _tileset.getGroupDefinitionByID("wall");
			var exit:TileGroupDefinition = _tileset.getGroupDefinitionByID("exit");
			var earth:TileGroupDefinition = _tileset.getGroupDefinitionByID("earth");
			var gem1:TileGroupDefinition = _tileset.getGroupDefinitionByID("gem1");
			var gem2:TileGroupDefinition = _tileset.getGroupDefinitionByID("gem2");
			var boulder:TileGroupDefinition = _tileset.getGroupDefinitionByID("boulder");
			
			var x:int;
			var y:int;
			var fw:int = (w * 4) - 1;
			var fh:int = (h * 4) + 1;
			
			/* Generate upper and lower border for the tilemap. */
			for (i = 0; i < w; i++)
			{
				x = 128 * i;
				_tilemap.addTileGroup(_tileset.createGroup(hBorder.nr, x, 0));
				_tilemap.addTileGroup(_tileset.createGroup(hBorder.nr, x, (128 * h) + 32));
			}
			/* Generate left and right border for the tilemap. */
			for (i = 0; i < h; i++)
			{
				y = (128 * i) + 32;
				_tilemap.addTileGroup(_tileset.createGroup(vBorder.nr, 0, y));
				_tilemap.addTileGroup(_tileset.createGroup(vBorder.nr, (128 * w) - 32, y));
			}
			
			/* Fill the map with random tilegroups. */
			for (y = 1; y < fh; y++)
			{
				for (x = 1; x < fw; x++)
				{
					var gx:int = 32 * x;
					var gy:int = 32 * y;
					var tg:TileGroup;
					var rnd:int = NumberGenerator.random(1, 6);
					switch (rnd)
					{
						case 1:
							tg = _tileset.createGroup(earth.nr, gx, gy);
							break;
						case 2:
							tg = _tileset.createGroup(Dice.chance(80) ? wall.nr : earth.nr, gx, gy);
							break;
						case 3:
							tg = _tileset.createGroup(Dice.chance(40) ? boulder.nr : earth.nr, gx, gy);
							break;
						case 4:
							tg = _tileset.createGroup(Dice.chance(4) ? gem1.nr : earth.nr, gx, gy);
							break;
						case 5:
							tg = _tileset.createGroup(Dice.chance(2) ? gem2.nr : earth.nr, gx, gy);
							break;
						case 6:
							tg = _tileset.createGroup(Dice.chance(1) ? exit.nr : earth.nr, gx, gy);
					}
					_tilemap.addTileGroup(tg);
				}
			}
			
			/* Create tilegroups for the map. */
//			var tileGroupCount:int = 20;
//			var tmpGroups:Object = createTileGroups(tileGroupCount);
//			
//			/* create layer for the map. */
//			var layerGroupCount:int = 100;
//			var layer:TileLayer = createTileLayer(layerGroupCount);
//			
//			/* Fill layer with tile groups. */
//			for (var i:int = 0; i < layerGroupCount; i++)
//			{
//				var gid:String = "" + NumberGenerator.random(0, tileGroupCount - 1);
//				var g:TileGroup = tmpGroups[gid];
//				g.x = NumberGenerator.random(0, w - g.width);
//				g.y = NumberGenerator.random(0, h - g.height);
//				layer.groups[i] = g;
//				//Debug.trace(g.toString());
//			}
//			
//			_tilemap.layers = new Vector.<TileLayer>(1, true);
//			_tilemap.layers[0] = layer;
		}
		
		
		/**
		 * @private
		 */
		private function generateType2Map(sr:int):void
		{
			/* Determine random map size. */
			var minSize:int = (sr == 0) ? 2 : (sr == 1) ? 2 : (sr == 2) ? 20 : 100;
			var maxSize:int = (sr == 0) ? 200 : (sr == 1) ? 10 : (sr == 2) ? 40 : 200;
			var w:int = NumberGenerator.random(minSize, maxSize);
			var h:int = NumberGenerator.random(minSize, maxSize);
			var i:int;
			
			_tilemap = new TileMap();
			
			/* Determine random map margin. */
			if (Dice.chance(33)) _tilemap.margin = 0;
			else _tilemap.margin = NumberGenerator.random(20, 200);
			
			/* Random bg color */
			_tilemap.backgroundColor = ColorUtil.randomColor(Palettes.C64);
			_tilemap.edgeMode = TileScroller.EDGE_MODE_HALT;
			
			var x:int;
			var y:int;
			var fw:int = (w * 1) - 1;
			var fh:int = (h * 1) + 1;
			
			/* Generate upper and lower border for the tilemap. */
			for (i = 0; i < w; i++)
			{
				x = 16 * i;
				_tilemap.addTileGroup(_tileset.createGroup(23, x, 0));
				_tilemap.addTileGroup(_tileset.createGroup(23, x, (16 * h) + 16));
			}
			/* Generate left and right border for the tilemap. */
			for (i = 0; i < h; i++)
			{
				y = (16 * i) + 16;
				_tilemap.addTileGroup(_tileset.createGroup(23, 0, y));
				_tilemap.addTileGroup(_tileset.createGroup(23, (16 * w) - 16, y));
			}
			
			/* Fill the map with random tilegroups. */
			for (y = 1; y < fh; y++)
			{
				for (x = 1; x < fw; x++)
				{
					var gx:int = 16 * x;
					var gy:int = 16 * y;
					var tg:TileGroup;
					var rnd:int = NumberGenerator.random(0, 57);
					tg = _tileset.createGroup(rnd, gx, gy);
					_tilemap.addTileGroup(tg);
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function generateType3Map(sizeRange:int):void
		{
		}
		
		
		/**
		 * @private
		 */
		private function generateType4Map(sizeRange:int):void
		{
		}
		
		
		/**
		 * @private
		 */
		private function createTileLayer(groupCount:int):TileLayer
		{
			var layer:TileLayer = new TileLayer();
			layer.id = "layer0";
			layer.tileAnimFPS = 12;
			layer.transparent = false;
			layer.fillColor = 0x000000;
			layer.autoScroll = null;
			layer.autoScrollSpeed = 0;
			layer.properties = null;
			layer.groups = new Vector.<TileGroup>(groupCount, true);
			return layer;
		}
		
		
		/**
		 * @private
		 */
		private function createTileGroup(tileNr:int, size:int, xpos:int, ypos:int):TileGroup
		{
			var a:Array = [];
			var g:TileGroup = new TileGroup();
			var tileSize:int = 32;
			var w:int = tileSize * size;
			var h:int = tileSize * size;
			for (var y:int = 0; y < size; y++)
			{
				for (var x:int = 0; x < size; x++)
				{
					var tp:TileModel = new TileModel();
					tp.nr = tileNr;
					tp.x = x * tileSize;
					tp.y = y * tileSize;
					a.push(_tileset.createTile(g, tp));
				}
			}
			
			g.tiles = new Vector.<Tile>(a.length, true);
			for (var i:int = 0; i < a.length; i++)
			{
				g.tiles[i] = a[i];
				g.tileCount++;
			}
			g.x = xpos;
			g.y = ypos;
			g.width = w;
			g.height = h;
			g.right = x + w;
			g.bottom = y + h;
			return g;
		}
	}
}
