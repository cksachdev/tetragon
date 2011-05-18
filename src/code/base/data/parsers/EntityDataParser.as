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
package base.data.parsers
{
	import base.core.debug.Log;
	import base.core.entity.EntityDefinition;
	import base.data.types.KeyValuePair;
	import base.io.resource.ResourceIndex;
	import base.io.resource.loaders.XMLResourceLoader;

	
	/**
	 * A data parser that parses entity data and creates entity definitions from it.
	 */
	public class EntityDataParser extends DataObjectParser implements IDataParser
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function parse(loader:XMLResourceLoader, model:*):void
		{
			_xml = loader.xml;
			const index:ResourceIndex = model;
			
			/* Loop through all items in data file. */
			for each (var x:XML in _xml.item)
			{
				/* Get the current item's ID. */
				const id:String = extractString(x, "@id");
				
				/* Only parse the item(s) that we want! */
				if (!loader.hasResourceID(id)) continue;
				
				Log.debug("Parsing entity data for " + id + " ...", this);
				
				/* Create a new entity definition for the data item. */
				var e:EntityDefinition = new EntityDefinition(id);
				
				/* Loop through the item's component definitions. */
				for each (var c:XML in x.components.component)
				{
					const componentClassID:String = extractString(c, "@classID");
					const componentClass:Class = dataSupportManager.getEntityComponentClass(componentClassID);
					
					if (componentClass)
					{
						/* Create map that maps all properties and values of the component. */
						var map:Object = {};
						
						/* Map all properties found in the component definition. */
						for each (var p:XML in c.children())
						{
							var pair:KeyValuePair = parseProperty(p);
							pair = checkReferencedID(pair.key, pair.value);
							if (pair.value == null || pair.value == "")
							{
								map[pair.key] = null;
							}
							else
							{
								map[pair.key] = pair.value;
							}
						}
						
						/* Add component property map to entity definition. */
						e.addComponentMapping(componentClassID, map);
					}
					else
					{
						Log.error("No component class mapped for the classID \""
							+ componentClassID + "\" for item with ID \"" + id + "\".", this);
					}
				}
				
				/* Store entity definition in resource index. */
				index.addDataResource(e);
			}
			
			dispose();
		}
	}
}
