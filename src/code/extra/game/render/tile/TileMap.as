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
	import base.data.DataObject;
	
	
	/**
	 * Tilemap data model.
	 */
	public class TileMap extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _type:String;
		/** @private */
		private var _width:int;
		/** @private */
		private var _height:int;
		/** @private */
		private var _margin:int;
		/** @private */
		private var _edgeMode:int;
		/** @private */
		private var _mapProperties:Object;
		/** @private */
		private var _groups:Vector.<TileGroup>;
		/** @private */
		private var _groupCount:int;
		/** @private */
		private var _fixedGroupCount:int;
		/** @private */
		private var _areas:Object;
		/** @private */
		private var _areaCount:int;
		/** @private */
		private var _bgColor:uint;
		/** @private */
		private var _maxAreaX:int;
		/** @private */
		private var _maxAreaY:int;
		/** @private */
		public var layers:Vector.<TileLayer>;
		/** @private */
		public var tileSetID:String;
		/** @private */
		private var _wrap:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function TileMap(fixedGroupCount:int = 0)
		{
			_fixedGroupCount = fixedGroupCount;
			_wrap = false;
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a new map property to the tilemap.
		 * 
		 * @param property The map property to add.
		 */
		public function addMapProperty(property:TileMapProperty):void
		{
			_mapProperties[property.id] = property;
		}
		
		
		/**
		 * Adds a tilegroup to the tilemap.
		 * 
		 * @param group
		 */
		public function addTileGroup(group:TileGroup):void
		{
			group.id = _groupCount;
			if (_fixedGroupCount > 0) _groups[_groupCount] = group;
			else _groups.push(group);
			_groupCount++;
		}
		
		
		/**
		 * Disposes the tilemap. the map cannot be used anymore after this.
		 */
		override public function dispose():void
		{
			super.dispose();
			for each (var g:TileGroup in _groups)
			{
				g.dispose();
				g.tiles = null;
			}
			_groups = null;
			_areas = null;
		}
		
		
		/**
		 * Creates a String dump of the tilemap's data.
		 */
		public function dump():String
		{
			var s:String = toString() + "\n";
			for (var i:int = 0; i < _groups.length; i++)
			{
				s += i + ". " + _groups[i].toString() + "\n";
			}
			return s;
		}
		
		
		/**
		 * Creates a String dump of the tilemap's areas.
		 */
		public function dumpAreas():String
		{
			var a:Array = [];
			var area:TileArea;
			for each (area in _areas)
			{
				a.push(area);
			}
			a.sortOn("nr", Array.NUMERIC);
			
			var s:String = toString() + "\n";
			for (var i:int = 0; i < a.length; i++)
			{
				area = a[i];
				s += area.x + "_" + area.y + ":\t" +  area.toString() + "\n";
			}
			return s;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString(...args):String
		{
			return super.toString("groups=" + _groupCount, "areas=" + _areaCount);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The type of the map.
		 */
		public function get type():String
		{
			return _type;
		}
		public function set type(v:String):void
		{
			_type = v;
		}
		
		
		/**
		 * Total width of the tile map, in pixels.
		 */
		public function get width():int
		{
			return _width;
		}
		
		
		/**
		 * Total height of the tile map, in pixels.
		 */
		public function get height():int
		{
			return _height;
		}
		
		
		/**
		 * The size of space around the tilemap before scrolling stops if edgeMode is set to halt.
		 */
		public function get margin():int
		{
			return _margin;
		}
		public function set margin(v:int):void
		{
			_margin = v;
		}
		
		
		/**
		 * Determines how the map behaves if scrolling reaches any of it's edges.
		 */
		public function get edgeMode():int
		{
			return _edgeMode;
		}
		public function set edgeMode(v:int):void
		{
			_edgeMode = v;
			_wrap = (_edgeMode == TileScroller.EDGE_MODE_WRAP);
		}
		
		
		/**
		 * Determines if the tilemap uses wrapping edge mode.
		 */
		public function get wrap():Boolean
		{
			return _wrap;
		}
		
		
		/**
		 * A list of all tilegroups that are on the tilemap.
		 */
		public function get groups():Vector.<TileGroup>
		{
			return _groups;
		}
		
		
		/**
		 * The number of tilegroups that are on the tilemap.
		 */
		public function get groupCount():uint
		{
			return _groupCount;
		}
		
		
		/**
		 * A map that contains all the tile areas of the tile map.
		 */
		public function get areas():Object
		{
			return _areas;
		}
		
		
		/**
		 * The number of tileareas that are on the tilemap.
		 */
		public function get areaCount():int
		{
			return _areaCount;
		}
		
		
		/**
		 * The background color of the tilemap. Can be an alpha color value.
		 */
		public function get backgroundColor():uint
		{
			return _bgColor;
		}
		public function set backgroundColor(v:uint):void
		{
			_bgColor = v;
		}
		
		
		/**
		 * The x position of the right-most column of areas.
		 */
		public function get maxAreaX():int
		{
			return _maxAreaX;
		}
		
		
		/**
		 * The y position of the bottom-most row of areas.
		 */
		public function get maxAreaY():int
		{
			return _maxAreaY;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Calculates the total width and height of the tilemap. Called automatically
		 * by any tilemap factory or generator after the tilemap has been created.
		 * 
		 * @private
		 */
		internal function measure():void
		{
			var a:Array = [];
			for each (var g:TileGroup in _groups)
			{
				a.push({r: g.right, b: g.bottom});
			}
			a.sortOn("r", Array.NUMERIC | Array.DESCENDING);
			_width = a[0]["r"];
			a.sortOn("b", Array.NUMERIC | Array.DESCENDING);
			_height = a[0]["b"];
		}
		
		
		/**
		 * Called by TileScroller automatically after a tilemap has been provided to it.
		 * 
		 * @param areaWidth
		 * @param areaHeight
		 * 
		 * @private
		 */
		internal function prepare(areaWidth:int, areaHeight:int):void
		{
			registerTileGroupsToAreas(areaWidth, areaHeight);
			if (_wrap) createWrapAreas(areaWidth, areaHeight);
		}
		
		
		/**
		 * Sets up the object instance. This method may only contain instructions that
		 * should be executed exactly once during object lifetime, usually right after
		 * the object has been instatiated.
		 * 
		 * @private
		 */
		private function setup():void
		{
			if (_fixedGroupCount > 0)
				_groups = new Vector.<TileGroup>(_fixedGroupCount, true);
			else
				_groups = new Vector.<TileGroup>();
			
			_mapProperties = {};
			_margin = 0;
			_groupCount = 0;
			_bgColor = 0xFF004488;
		}
		
		
		/**
		 * Iterates through all tilegroups and calculates in which areas they appear in.
		 * If for example group number 3 appears in area 1,0 (an area equals the screen
		 * dimension) then a[1][0][3] = true, otherwise a[1][0][3] = undefined.
		 * 
		 * @param areaWidth
		 * @param areaHeight
		 * 
		 * @private
		 */
		private function registerTileGroupsToAreas(areaWidth:int, areaHeight:int):void
		{
			_areas = {};
			_areaCount = 0;
			_maxAreaX = 0;
			_maxAreaY = 0;
			var len:int = groupCount;
			var x:int;
			var y:int;
			
			for (var i:int = 0; i < len; i++)
			{
				var g:TileGroup = _groups[i];
				
				/* Appy factor for scaling. TODO This doesn't work quite right yet! */
				//g.x *= _scale;
				//g.y *= _scale;
				//g.right *= _scale;
				//g.bottom *= _scale;
				
				//if (_scale > 1)
				//{
					//g.width *= _scale;
					//g.height *= _scale;
					//g.right = g.x + (g.width * _scale);
					//g.bottom = g.y + (g.height * _scale);
					//g.right *= _scale;
					//g.bottom *= _scale;
				//}
				//else if (_scale < 1)
				//{
				//	g.right /= _scale;
				//	g.bottom /= _scale;
				//}
				
				var xMin:int = Math.max(int(g.x / areaWidth), 0);
				var xMax:int = Math.max(int((g.right - 1) / areaWidth), 0);
				var yMin:int = Math.max(int(g.y / areaHeight), 0);
				var yMax:int = Math.max(int((g.bottom - 1) / areaHeight), 0);
				
				/* Faster Math.abs calculations. Needs testing! */
				//var xMin:int = g.x / areaWidth;
				//var xMax:int = g.right / areaWidth;
				//var yMin:int = g.y / areaHeight;
				//var yMax:int = g.bottom / areaHeight;
				//xMin = xMin < 0 ? -xMin : xMin;
				//xMax = xMax < 0 ? -xMax : xMax;
				//yMin = yMin < 0 ? -yMin : yMin;
				//yMax = yMax < 0 ? -yMax : yMax;
				
				/* Store highest map x/y pos. */
				if (xMax > _maxAreaX) _maxAreaX = xMax;
				if (yMax > _maxAreaY) _maxAreaY = yMax;
				
				for (x = xMin; x <= xMax; x++)
				{
					for (y = yMin; y <= yMax; y++)
					{
						var key:String = getAreaKey(x, y);
						/* If TileArea at this x,y coord hasn't been created yet, create it. */
						if (_areas[key] == null)
						{
							_areas[key] = new TileArea(_areaCount, x, y);
							_areaCount++;
						}
						TileArea(_areas[key]).addTileGroup(i);
					}
				}
			}
		}
		
		
		/**
		 * Creates areas with negative coordinates that act as wrapping areas for tilemaps
		 * that should be able to 'wrap around' once an edge is reached. This method creates
		 * one additional row and column of areas on x -1 and y -1 onto which the tilegroups
		 * of the bottom-most and right-most areas are reflected.
		 * 
		 * @param areaWidth
		 * @param areaHeight
		 * 
		 * @private
		 */
		private function createWrapAreas(areaWidth:int, areaHeight:int):void
		{
			/* If the tilemap dimensions are not a multiple of the current viewport size
			 * we need to add some other areas or we'd get holes when wrapping, so find
			 * out if we have extra width and/or height. */
			var extraW:int = _width % areaWidth;
			var extraH:int = _height % areaHeight;
			
			var tmp:Object = {};
			var s:String;
			var g:TileGroup;
			var extraArea:TileArea;
			
			/* Loop through all areas and pick the bottom-most and/or right-most ones,
			 * create a new tilearea in negative space for them and store all tilegroup
			 * flags from the source area in the new area. */
			for each (var a:TileArea in _areas)
			{
				/* Create a new wrap area. */
				var ta:TileArea;
				
				/* Find the bottom-right-most area. This one needs extra care
				 * because it needs three new areas that will reflect it. */
				if (a.x == _maxAreaX && a.y == _maxAreaY)
				{
					ta = new TileArea(_areaCount, -1, -1);
					ta.offsetH = -_width;
					ta.offsetV = -_height;
					ta.wrapFlags = {};
					for (s in a.flags)
					{
						ta.wrapFlags[s] = true;
					}
					if (extraW > 0)
					{
						/* Extra width available: we also need to reflect the second-last column. */
						extraArea = _areas[getAreaKey(a.x - 1, a.y)];
						if (extraArea)
						{
							for (s in extraArea.flags) ta.wrapFlags[s] = true;
						}
					}
					if (extraH > 0)
					{
						/* Extra height available: we also need to reflect the second-last row. */
						extraArea = _areas[getAreaKey(a.x, a.y - 1)];
						if (extraArea)
						{
							for (s in extraArea.flags) ta.wrapFlags[s] = true;
						}
					}
					if (extraW > 0 && extraH > 0)
					{
						/* Extra rule for -1 -1 area: If both extra width and extra height is
						 * available we also need to reflect the area left-above of the bottom-
						 * right-most area. */
						extraArea = _areas[getAreaKey(a.x - 1, a.y - 1)];
						if (extraArea)
						{
							for (s in extraArea.flags) ta.wrapFlags[s] = true;
						}
					}
					tmp[getAreaKey(-1, -1)] = ta;
				}
				
				/* Find any area on the right-most column. */
				if (a.x == _maxAreaX)
				{
					ta = new TileArea(_areaCount, -1, a.y);
					ta.offsetH = -_width;
					ta.offsetV = 0;
					ta.wrapFlags = {};
					for (s in a.flags)
					{
						ta.wrapFlags[s] = true;
					}
					if (extraW > 0)
					{
						/* Extra width available: we also need to reflect the second-last column. */
						extraArea = _areas[getAreaKey(a.x - 1, a.y)];
						if (extraArea)
						{
							for (s in extraArea.flags) ta.wrapFlags[s] = true;
						}
					}
					tmp[getAreaKey(-1, a.y)] = ta;
				}
				
				/* Find any area on the bottom-most row. */
				if (a.y == _maxAreaY)
				{
					ta = new TileArea(_areaCount, a.x, -1);
					ta.offsetH = 0;
					ta.offsetV = -_height;
					ta.wrapFlags = {};
					for (s in a.flags)
					{
						ta.wrapFlags[s] = true;
					}
					if (extraH > 0)
					{
						/* Extra height available: we also need to reflect the second-last row. */
						extraArea = _areas[getAreaKey(a.x, a.y - 1)];
						if (extraArea)
						{
							for (s in extraArea.flags) ta.wrapFlags[s] = true;
						}
					}
					tmp[getAreaKey(a.x, -1)] = ta;
				}
				
				_areaCount++;
			}
			
			/* Store entries from temporary map back into areas map. */
			for (s in tmp)
			{
				_areas[s] = tmp[s];
			}
		}
		
		
		/**
		 * Generates a string key with that areas are mapped.
		 * 
		 * @param x X coord of the area for which to generate a key for.
		 * @param y Y coord of the area for which to generate a key for.
		 * @return A string key.
		 * 
		 * @private
		 */
		private function getAreaKey(x:int, y:int):String
		{
			return "area" + x + "" + y;
		}
	}
}
