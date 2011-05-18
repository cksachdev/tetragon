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
package extra.game.data.parsers
{
	import base.data.parsers.DataParser;
	import base.data.parsers.IDataParser;
	import base.io.resource.ResourceIndex;
	import base.io.resource.loaders.XMLResourceLoader;

	import extra.game.render.tile.*;


	
	/**
	 * Used to parse Tilemaps. All entries of a specified resource are parsed at once.
	 */
	public class TileMapDataParser extends DataParser implements IDataParser
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function parse(wrapper:XMLResourceLoader, model:*):void
		{
			_xml = wrapper.xml;
			var index:ResourceIndex = model;
			
			for each (var x:XML in _xml.tilemap)
			{
				var id:String = extractString(x, "@id");
				
				/* Only pick the resource that we want! */
				if (!wrapper.hasResourceID(id)) continue;
				
				var m:TileMap = new TileMap();
				var i:XML;
				var j:XML;
				var count:int;
				var c:int;
				var g:TileGroup;
				var tmpTileGroups:Object = {};
				
				m.id = id;
				m.type = extractString(x, "@type");
				m.margin = extractNumber(x, "@margin");
				m.edgeMode = extractNumber(x, "@edgeMode");
				m.tileSetID = extractString(x, "@tileSetID");
				
				/* Parse the tilemap's properties. */
				for each (i in x.mapProperties.property)
				{
					var p:TileMapProperty = new TileMapProperty();
					p.id = extractString(i, "@id");
					p.value = extractString(i, "@value");
					m.addMapProperty(p);
				}
				
				/* Parse the tilemap's tilegroups. */
				for each (i in x.tileGroups.group)
				{
					g = new TileGroup();
					g.id = extractNumber(i, "@id");
					g.width = extractNumber(i, "@width");
					g.height = extractNumber(i, "@height");
					g.copyOf = extractNumber(i, "@copyOf");
					/* Parse the tilegroup's properties. */
					count = XMLList(i.properties.property).length();
					if (count > 0)
					{
						g.properties = {};
						for each (j in i.properties.property)
						{
							var tp:TileProperty = new TileProperty();
							tp.id = extractString(j, "@id");
							tp.value = extractString(j, "@value");
							g.properties[tp.id] = tp;
						}
					}
					/* Parse the tilegroup's sub tiles. */
					count = XMLList(i.tiles.tile).length();
					if (count > 0)
					{
						c = 0;
						g.tileCount = count;
						g.tiles = new Vector.<Tile>(count, true);
						for each (j in i.tiles.tile)
						{
							var tile:Tile = new Tile();
							tile.id = extractString(j, "@id");
							tile.x = extractNumber(j, "@x");
							tile.y = extractNumber(j, "@y");
							g.tiles[c++] = tile;
						}
					}
					tmpTileGroups[g.id] = g;
				}
				
				/* Parse the tilemap's layers. */
				count = extractNumber(x, "@layerCount");
				m.layers = new Vector.<TileLayer>(count, true);
				for each (i in x.layers.layer)
				{
					var l:TileLayer = new TileLayer();
					l.id = extractString(i, "@id");
					l.tileAnimFPS = extractNumber(i, "@tileAnimFPS");
					l.transparent = extractBoolean(i, "@transparent");
					l.fillColor = extractColorValue(i, "@fillColor");
					l.autoScroll = extractString(i, "@autoScroll");
					l.autoScrollSpeed = extractNumber(i, "@autoScrollSpeed");
					/* Parse the layer properties. */
					count = XMLList(i.properties.property).length();
					if (count > 0)
					{
						l.properties = {};
						for each (j in i.properties.property)
						{
							var lp:TileLayerProperty = new TileLayerProperty();
							lp.id = extractString(j, "@id");
							lp.value = extractString(j, "@value");
							l.properties[lp.id] = lp;
						}
					}
					/* Parse the layer's layout. */
					count = extractNumber(i, "@groupCount");
					l.groups = new Vector.<TileGroup>(count, true);
					for each (j in i.layout.group)
					{
						var gid:int = extractNumber(j, "@id");
						g = tmpTileGroups[gid];
						g.x = extractNumber(j, "@x");
						g.y = extractNumber(j, "@y");
						l.groups[gid - 1] = g;
					}
					var layerIndex:int = extractNumber(i, "@index");
					m.layers[layerIndex] = l;
				}
				
				index.addDataResource(m);
			}
			
			dispose();
		}
	}
}
