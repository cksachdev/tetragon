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
	import base.core.debug.Log;
	import base.data.parsers.DataParser;
	import base.data.parsers.IDataParser;
	import base.io.resource.ResourceIndex;
	import base.io.resource.loaders.XMLResourceLoader;

	import extra.game.render.tile.*;

	
	
	/**
	 * Used to parse Tilesets. All entries of a specified resource are parsed at once.
	 */
	public class TileSetDataParser extends DataParser implements IDataParser
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
			
			for each (var x:XML in _xml.tileset)
			{
				var id:String = extractString(x, "@id");
				
				/* Only pick the resources that we want! */
				if (!wrapper.hasResourceID(id)) continue;
				
				var tileDefCount:int = XMLList(x.tileDefinitions.tile).length();
				var groupDefCount:int = XMLList(x.groupDefinitions.group).length();
				if (groupDefCount < 1) groupDefCount = tileDefCount;
				
				var ts:TileSet = new TileSet(tileDefCount, groupDefCount);
				var p:TileProperty;
				var i:XML;
				var j:XML;
				var count:int;
				var c:int;
				
				ts.id = id;
				ts.transparent = extractBoolean(x, "@transparent");
				ts.backgroundColor = extractColorValue(x, "@backgroundColor");
				ts.tileImageID = extractString(x, "@tileImageID");
				ts.tileImageGridWidth = extractNumber(x, "@tileImageGridWidth");
				ts.tileImageGridHeight = extractNumber(x, "@tileImageGridHeight");
				
				/* Parse the tileset's property definitions. */
				for each (i in x.propertyDefinitions.property)
				{
					var d:TilePropertyDefinition = new TilePropertyDefinition();
					d.id = extractString(i, "@id");
					d.name = extractString(i, "@name");
					d.defaultValue = extractString(i, "@defaultValue");
					ts.addPropertyDefinition(d);
				}
				
				/* Parse the tileset's global properties. */
				for each (i in x.globalProperties.property)
				{
					p = new TileProperty();
					p.id = extractString(i, "@id");
					p.value = extractString(i, "@value");
					ts.addGlobalProperty(p);
				}
				
				/* Parse the tileset's tile definitions. */
				for each (i in x.tileDefinitions.tile)
				{
					var td:TileDefinition = new TileDefinition();
					td.nr = extractNumber(i, "@nr");
					td.x = extractNumber(i, "@x");
					td.y = extractNumber(i, "@y");
					td.width = extractNumber(i, "@width");
					td.height = extractNumber(i, "@height");
					td.copyOf = extractString(i, "@copyOf");
					/* Parse the tile's properties. */
					count = XMLList(i.properties.property).length();
					if (count > 0)
					{
						td.properties = {};
						for each (j in i.properties.property)
						{
							p = new TileProperty();
							p.id = extractString(j, "@id");
							p.value = extractString(j, "@value");
							td.properties[p.id] = p;
						}
					}
					/* If tileset has a regular grid we can auto-calculate position and
					 * size of anim tiles later. */
					if (ts.tileImageGridWidth > 0 && ts.tileImageGridHeight > 0)
					{
						td.frameCount = i.frames ? i.frames.@count : 0;
					}
					/* If the tileset is not following a grid (irregular tile sizes) we
					 * need the anim frames positions and dimensions from the tileset. */
					else
					{
						td.frameCount = XMLList(i.frames.frame).length();
						if (td.frameCount > 0)
						{
							c = 0;
							// TODO Add anim support for non-conform tile sizes!
							//tileDef.frames = new Vector.<TileFrame>(tileDef.frameCount, true);
							for each (var f:XML in i.frames.frame)
							{
								var frame:TileFrame = new TileFrame();
								frame.x = extractNumber(f, "@x");
								frame.y = extractNumber(f, "@y");
								frame.width = extractNumber(f, "@width");
								frame.height = extractNumber(f, "@height");
								//tileDef.frames[c++] = frame;
							}
						}
					}
					ts.addTileDefinition(td);
				}
				
				/* Parse the tileset's group definitions. */
				var gd:TileGroupDefinition;
				var tm:TileModel;
				count = XMLList(x.groupDefinitions.group).length();
				if (count > 0)
				{
					for each (i in x.groupDefinitions.group)
					{
						gd = new TileGroupDefinition();
						gd.nr = extractNumber(i, "@nr");
						gd.width = extractNumber(i, "@width");
						gd.height = extractNumber(i, "@height");
						gd.copyOf = extractNumber(i, "@copyOf");
						/* Parse the tilegroup definition's properties. */
						count = XMLList(i.properties.property).length();
						if (count > 0)
						{
							gd.properties = {};
							for each (j in i.properties.property)
							{
								p = new TileProperty();
								p.id = extractString(j, "@id");
								p.value = extractString(j, "@value");
								gd.properties[p.id] = p;
							}
						}
						/* Parse the tilegroups definition's tiles. */
						count = XMLList(i.tiles.tile).length();
						if (count > 0)
						{
							c = 0;
							gd.tiles = new Vector.<TileModel>(count, true);
							for each (j in i.tiles.tile)
							{
								tm = new TileModel();
								tm.nr = extractNumber(j, "@nr");
								tm.x = extractNumber(j, "@x");
								tm.y = extractNumber(j, "@y");
								gd.tiles[c++] = tm;
							}
						}
						ts.addGroupDefinition(gd);
					}
				}
				else
				{
					Log.warn("Tileset \"" + id
						+ "\" has no defined groups. Every tile will become a group.", this);
					for each (i in x.tileDefinitions.tile)
					{
						gd = new TileGroupDefinition();
						gd.nr = extractNumber(i, "@nr");
						gd.width = extractNumber(i, "@width");
						if (gd.width < 1) gd.width = ts.tileImageGridWidth;
						gd.height = extractNumber(i, "@height");
						if (gd.height < 1) gd.height = ts.tileImageGridHeight;
						gd.copyOf = extractNumber(i, "@copyOf");
						/* Parse the tilegroup definition's properties. */
						count = XMLList(i.properties.property).length();
						if (count > 0)
						{
							gd.properties = {};
							for each (j in i.properties.property)
							{
								p = new TileProperty();
								p.id = extractString(j, "@id");
								p.value = extractString(j, "@value");
								gd.properties[p.id] = p;
							}
						}
						/* Parse the tilegroups definition's tiles. */
						gd.tiles = new Vector.<TileModel>(1, true);
						tm = new TileModel();
						tm.nr = gd.nr;
						tm.x = 0;
						tm.y = 0;
						gd.tiles[0] = tm;
						ts.addGroupDefinition(gd);
					}
				}
				
				index.addDataResource(ts);
			}
			
			dispose();
		}
	}
}
