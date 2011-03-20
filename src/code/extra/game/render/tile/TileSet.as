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
	import base.io.resource.ResourceManager;
	import base.util.Log;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	
	/**
	 * Tileset data model.
	 */
	public class TileSet extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether the tileset has a transparent background or not.
		 */
		public var transparent:Boolean;
		
		/**
		 * The background color of the tileset.
		 */
		public var backgroundColor:uint;
		
		/**
		 * The ID of the image that contains the tiles.
		 */
		public var tileImageID:String;
		
		/**
		 * If the tiles on the tile image are laid out in a grid this value determines
		 * the width of one grid rectangle. For tilesets which have tiles of varying
		 * size this value is 0.
		 */
		public var tileImageGridWidth:int;
		
		/**
		 * If the tiles on the tile image are laid out in a grid this value determines
		 * the height of one grid rectangle. For tilesets which have tiles of varying
		 * size this value is 0.
		 */
		public var tileImageGridHeight:int;
		
		/**
		 * A map that contains tile property definitions.
		 * @private
		 */
		public var _propertyDefinitions:Object;
		
		private var _defEditorID:String;
		
		/**
		 * A map that contains tile properties that apply to all tiles in this tileset.
		 * @private
		 */
		public var _globalProperties:Object;
		
		/**
		 * A map of TileDefinition objects that make up the tiles of the tileset.
		 * @private
		 */
		public var _tileDefinitions:Vector.<TileDefinition>;
		
		/**
		 * A map of TileGroupDefinition objects that make up the tile groups pool of the tileset.
		 * @private
		 */
		public var _groupDefinitions:Vector.<TileGroupDefinition>;
		
		
		private var _tileIDCount:int;
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function TileSet(tileDefCount:int, groupDefCount:int)
		{
			_propertyDefinitions = {};
			_globalProperties = {};
			_tileIDCount = 0;
			_tileDefinitions = new Vector.<TileDefinition>(tileDefCount, true);
			_groupDefinitions = new Vector.<TileGroupDefinition>(groupDefCount, true);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a new tile property definition to the tileset.
		 * 
		 * @param property The property definition to add.
		 */
		public function addPropertyDefinition(definition:TilePropertyDefinition):void
		{
			_propertyDefinitions[definition.id] = definition;
			/* Store property pool ID of the editorID property for later use. */
			if (definition.name == "editorID") _defEditorID = definition.id;
		}
		
		
		/**
		 * Adds a new tile property to the tileset that will apply to all tiles of the set.
		 * 
		 * @param property The tile property to add.
		 */
		public function addGlobalProperty(property:TileProperty):void
		{
			_globalProperties[property.id] = property;
		}
		
		
		/**
		 * Adds a new tile to the tileset.
		 * 
		 * @param tile The tile to add.
		 */
		public function addTileDefinition(tileDef:TileDefinition):void
		{
			_tileDefinitions[tileDef.nr] = tileDef;
		}
		
		
		/**
		 * Adds a new tilegroup to the tileset.
		 * 
		 * @param group The tilegroup to add.
		 */
		public function addGroupDefinition(groupDef:TileGroupDefinition):void
		{
			_groupDefinitions[groupDef.nr] = groupDef;
		}
		
		
		/**
		 * Init
		 */
		public function init():void
		{
			var image:BitmapData = ResourceManager.resourceIndex.getResourceContent(tileImageID);
			if (!image)
			{
				Log.error("[TileSet] No image with ID \"" + tileImageID
					+ "\" loaded for tileset \"" + id + "\".");
				return;
			}
			
			if (tileImageGridWidth > 0 && tileImageGridHeight > 0)
			{
				TileSet.createTileImagesFromGrid(this, image);
			}
			else
			{
				TileSet.createTileImages(this, image);
			}
		}
		
		
		/**
		 * Returns the Tile that is stored in the tilemap under the specified ID.
		 */
		public function getTileDefinition(tileDefNr:int):TileDefinition
		{
			return _tileDefinitions[tileDefNr];
		}
		
		
		/**
		 * Returns the TileGroup that is stored in the tilemap under the specified ID.
		 */
		public function getGroupDefinition(groupDefNr:int):TileGroupDefinition
		{
			return _groupDefinitions[groupDefNr];
		}
		
		
		/**
		 * Returns the tilegroup definition which has the specified editorID property
		 * assigned through it's tile properties.
		 */
		public function getGroupDefinitionByID(editorID:String):TileGroupDefinition
		{
			if (!_defEditorID || _defEditorID.length < 1)
			{
				/* No def editor ID defined in the tileset! */
				return null;
			}
			for each (var d:TileGroupDefinition in _groupDefinitions)
			{
				if (!d.properties) continue;
				var p:TileProperty = d.properties[_defEditorID];
				if (p && p.value == editorID) return d;
			}
			return null;
		}
		
		
		/**
		 * @private
		 */
		public function createTile(g:TileGroup, tp:TileModel):Tile
		{
			var td:TileDefinition = _tileDefinitions[tp.nr];
			var t:Tile = (td.frameCount > 0) ? new AnimTile() : new Tile();
			t.id = "tile" + _tileIDCount++;
			t.x = tp.x;
			t.y = tp.y;
			t.width = td.width;
			t.height = td.height;
			t.properties = td.properties;
			
			if (t is AnimTile)
			{
				var a:AnimTile = AnimTile(t);
				a.frameCount = td.frameCount;
				a.frames = td.bitmapData;
				if (!g.animTiles) g.animTiles = new Vector.<AnimTile>();
				g.animTiles.push(a);
				g.animTileCount++;
			}
			else
			{
				t.bitmapData = td.bitmapData;
			}
			return t;
		}
		
		
		/**
		 * Creates a new TileGroup object from the tilegroup definition of the specified number.
		 * The created tilegroup will reflect the same width, height, properties and tiles as
		 * the tilegroup definition it is created from.
		 * 
		 * @param groupDefNr The number ID of the tilegroup definition from which a concrete
		 *        tilegroup should be created.
		 * @param groupID The ID for the newly created tilegroup.
		 * @param x X pos for new tilegroup.
		 * @param y Y pos for new tilegroup.
		 */
		public function createGroup(groupDefNr:int, x:int, y:int):TileGroup
		{
			var d:TileGroupDefinition = _groupDefinitions[groupDefNr];
			var g:TileGroup = new TileGroup();
			g.x = x;
			g.y = y;
			g.width = d.width;
			g.height = d.height;
			g.right = x + d.width;
			g.bottom = y + d.height;
			g.properties = d.properties;
			
			/* Creates tiles for new tilegroup. */
			g.tiles = new Vector.<Tile>(d.tiles.length, true);
			for (var i:int = 0; i < d.tiles.length; i++)
			{
				var tp:TileModel = d.tiles[i];
				g.tiles[i] = createTile(g, tp);
				g.tileCount++;
			}
			return g;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function toString(...args):String
		{
			return super.toString("id=" + id, "tileDefCount=" + tileDefCount, "groupDefCount="
				+ groupDefCount);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The number of tiles in the tileset.
		 */
		public function get tileDefCount():int
		{
			return _tileDefinitions.length;
		}
		
		
		/**
		 * The number of groups in the tileset.
		 */
		public function get groupDefCount():int
		{
			return _groupDefinitions.length;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function createTileImagesFromGrid(tileset:TileSet, image:BitmapData):void
		{
			var x:int = 0;
			var y:int = 0;
			var w:int = tileset.tileImageGridWidth;
			var h:int = tileset.tileImageGridHeight;
			var r:Rectangle = new Rectangle(0, 0, w, h);
			var p:Point = new Point(0, 0);
			
			for (var i:int = 0; i < tileset._tileDefinitions.length; i++)
			{
				var td:TileDefinition = tileset._tileDefinitions[i];
				
				r.x = td.x = x;
				r.y = td.y = y;
				td.width = w;
				td.height = h;
				
				/* Non-animated tile */
				if (td.frameCount < 1)
				{
					p.x = 0;
					td.bitmapData = new BitmapData(w, h, tileset.transparent, tileset.backgroundColor);
					td.bitmapData.copyPixels(image, r, p);
					x += w;
					if (x >= image.width)
					{
						x = 0;
						y += h;
					}
				}
				/* Animated tile */
				else
				{
					td.bitmapData = new BitmapData(td.frameCount * w, h, tileset.transparent, tileset.backgroundColor);
					for (var j:int = 0; j < td.frameCount; j++)
					{
						r.x = x;
						r.y = y;
						p.x = j * w;
						td.bitmapData.copyPixels(image, r, p);
						x += w;
						if (x >= image.width)
						{
							x = 0;
							y += h;
						}
					}
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private static function createTileImages(tileset:TileSet, image:BitmapData):void
		{
			var r:Rectangle = new Rectangle();
			var p:Point = new Point(0, 0);
			for (var i:int = 0; i < tileset._tileDefinitions.length; i++)
			{
				var t:TileDefinition = tileset._tileDefinitions[i];
				
				if (t.copyOf)
				{
					// TODO
					continue;
				}
				if (t.frameCount > 0)
				{
					// TODO
					continue;
				}
				
				t.bitmapData = new BitmapData(t.width, t.height, tileset.transparent, tileset.backgroundColor);
				r.x = t.x;
				r.y = t.y;
				r.width = t.width;
				r.height = t.height;
				t.bitmapData.copyPixels(image, r, p);
			}
		}
	}
}
