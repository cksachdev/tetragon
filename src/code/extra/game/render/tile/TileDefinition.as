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
	import flash.display.BitmapData;
	
	
	/**
	 * A TileDefinition defines a tile that is used as a "blueprint" to create concrete
	 * tile objects that are used on a tilemap.
	 */
	public class TileDefinition
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The unique number of the tile.
		 */
		public var nr:int;
		
		/**
		 * X coordinate of the tile on the tileset image.
		 */
		public var x:int;
		
		/**
		 * Y coordinate of the tile on the tileset image.
		 */
		public var y:int;
		
		/**
		 * Width of the tile.
		 */
		public var width:int;
		
		/**
		 * Height of the tile.
		 */
		public var height:int;
		
		/**
		 * If this tile is a virtual copy of another tile then this contains the ID of the
		 * tile which this tile is a copy of.
		 */
		public var copyOf:String;
		
		/**
		 * The tile's tile properties, contains TileProperty objects.
		 * @private
		 */
		public var properties:Object;
		
		/**
		 * @private
		 */
		public var frameCount:int = 0;
		
		/**
		 * Only used for non-grid-conform tiles.
		 * @private
		 */
		//public var frames:Vector.<TileFrame>;
		
		/**
		 * The tile's image bitmapdata.
		 * @private
		 */
		public var bitmapData:BitmapData;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[TileDefinition, nr=" + nr +", x=" + x + ", y=" + y + ", width=" + width
				+ ", height=" + height + ", frameCount=" + frameCount +"]";
		}
	}
}
