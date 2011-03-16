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
	import flash.display.Shape;
	import flash.display.Sprite;
	
	
	/**
	 * TileGroup data model.
	 */
	public class TileGroup
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Unique number ID of the tilegroup.
		 */
		public var id:int;
		
		/**
		 * The x position of the tilegroup on the tilemap.
		 */
		public var x:int;
		
		/**
		 * The y position of the tilegroup on the tilemap.
		 */
		public var y:int;
		
		/**
		 * The width of the tilegroup.
		 */
		public var width:int;
		
		/**
		 * The height of the tilegroup.
		 */
		public var height:int;
		
		/**
		 * The x position of the group's right edge, measured from the tilemap's top-left corner.
		 */
		public var right:int;
		
		/**
		 * The y position of the group's bottom edge, measured from the tilemap's top-left corner.
		 */
		public var bottom:int;
		
		/**
		 * If this group is a virtual copy of another group then this contains the ID of the
		 * group which this group is a copy of.
		 */
		public var copyOf:int;
		
		/**
		 * Determines if the tilegroup has been placed in the scroll container.
		 * @private
		 */
		public var placed:Boolean = false;
		
		/**
		 * Determines if this tilegroup has been moved to the coordinate on a wrapped area.
		 * @private
		 */
		public var wrapped:Boolean;
		
		/**
		 * Used to temporarily store the horizontal wrapping offset for this tilegroup.
		 * @private
		 */
		public var offsetH:int;
		
		/**
		 * Used to temporarily store the vertical wrapping offset for this tilegroup.
		 * @private
		 */
		public var offsetV:int;
		
		/**
		 * The wrapper symbol that contains all sub-tiles and the bounding box.
		 * @private
		 */
		public var symbol:Sprite;
		
		/**
		 * Holds the bounding box of the tile group. Used for debugging.
		 * @private
		 */
		public var boundingBox:Shape;
		
		/**
		 * The tilegroup's tile properties.
		 * @private
		 */
		public var properties:Object;
		
		/**
		 * A vector of Tile objects which are part of this TileGroup.
		 * @private
		 */
		public var tiles:Vector.<Tile>;
		
		/**
		 * Vector that stores anim tiles which are in this group. Used by the TileScroller
		 * to keep track of which anim tiles are currenrtly displayed and need to be
		 * animated by the tileanim timer.
		 * @private
		 */
		public var animTiles:Vector.<AnimTile>;
		
		/**
		 * The number of tiles contained in the tilegroup.
		 * @private
		 */
		public var tileCount:int = 0;
		
		/**
		 * Nr. of anim tiles that are in the group.
		 * @private
		 */
		public var animTileCount:int = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the tilegroup.
		 */
		public function dispose():void
		{
			for each (var t:Tile in tiles)
			{
				t.bitmap = null;
				if (t is AnimTile && t.bitmapData)
				{
					t.bitmapData.dispose();
					t.bitmapData = null;
				}
			}
			boundingBox = null;
			symbol = null;
			
			if (wrapped)
			{
				x -= offsetH;
				y -= offsetV;
				right -= offsetH;
				bottom -= offsetV;
				wrapped = false;
			}
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[TileGroup, id=" + id + ", tiles=" + tiles.length + ", x=" + x + ", y=" + y
				+ ", width=" + width + ", height="+ height + "]";
		}
	}
}
