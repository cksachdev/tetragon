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
	import base.core.entity.EntityTemplate;
	import base.data.DataClassesFactory;
	import base.io.resource.ResourceIndex;
	import base.io.resource.wrappers.XMLResourceWrapper;

	
	/**
	 * A data parser that parses data for entity template objects.
	 */
	public class EntityDataParser extends DataParser implements IDataParser
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function parse(wrapper:XMLResourceWrapper, model:*):void
		{
			_xml = wrapper.xml;
			var index:ResourceIndex = model;
			var dcf:DataClassesFactory = DataClassesFactory.instance;
			
			for each (var x:XML in _xml.item)
			{
				/* Get the item's ID. */
				var id:String = extractString(x, "@id");
				
				/* Only pick the item that we want! */
				if (!wrapper.hasResourceID(id)) continue;
				
				/* Create a new entity template for the data item. */
				var t:EntityTemplate = new EntityTemplate(id);
				
				/* Loop through the item's component definitions. */
				for each (var c:XML in x.components.component)
				{
					var componentClassID:String = extractString(c, "@classID");
					// TODO componentClass still needed here?
					var componentClass:Class = dcf.getComponentClass(componentClassID);
					
					if (componentClass)
					{
						/* Create map that maps all properties and values of the component. */
						var map:Object = {};
						
						/* Map all properties found in the component definition. */
						for each (var p:XML in c.children())
						{
							var key:String = p.name();
							var value:String = p.toString();
							map[key] = value;
						}
						
						/* Add component property map to entity template. */
						t.addComponentMapping(componentClassID, map);
					}
					else
					{
						Log.error("No component class mapped for the classID \""
							+ componentClassID + "\" for item with ID \"" + id + "\".", this);
					}
				}
				
				index.addDataResource(t);
			}
			
			dispose();
		}
	}
}
