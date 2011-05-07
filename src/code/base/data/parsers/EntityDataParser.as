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
	import base.Main;
	import base.core.debug.Log;
	import base.core.entity.EntityDefinition;
	import base.data.DataSupportManager;
	import base.io.resource.ResourceIndex;
	import base.io.resource.wrappers.XMLResourceWrapper;

	
	/**
	 * A data parser that parses entity data and creates entity definitions from it.
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
			var dsm:DataSupportManager = Main.instance.dataSupportManager;
			
			for each (var x:XML in _xml.item)
			{
				/* Get the item's ID. */
				var id:String = extractString(x, "@id");
				
				/* Only pick the item that we want! */
				if (!wrapper.hasResourceID(id)) continue;
				
				/* Create a new entity template for the data item. */
				var e:EntityDefinition = new EntityDefinition(id);
				
				/* Loop through the item's component definitions. */
				for each (var c:XML in x.components.component)
				{
					var componentClassID:String = extractString(c, "@classID");
					var componentClass:Class = dsm.getComponentClass(componentClassID);
					
					if (componentClass)
					{
						/* Create map that maps all properties and values of the component. */
						var map:Object = {};
						
						/* Map all properties found in the component definition. */
						for each (var p:XML in c.children())
						{
							var key:String = p.name();
							var value:String = p.toString();
							
							/* Check if property has a complex type assigned. */
							var ctype:String = p.@ctype;
							if (ctype && ctype.length > 0)
							{
								var clazz:Class = dsm.getComplexTypeClass(ctype.toLowerCase());
								if (!clazz)
								{
									Log.error("Could not create complex type class."
										+ " Class for ctype \"" + ctype + "\" was not mapped.", this);
									continue;
								}
								var type:Object = new clazz();
								map[key] = parseComplexTypeParams(type, value);
							}
							else
							{
								if (value == "") map[key] = null;
								else map[key] = value;
							}
						}
						
						/* Add component property map to entity template. */
						e.addComponentMapping(componentClassID, map);
					}
					else
					{
						Log.error("No component class mapped for the classID \""
							+ componentClassID + "\" for item with ID \"" + id + "\".", this);
					}
				}
				
				index.addDataResource(e);
			}
			
			dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Parses a parameter string for a complex data type.
		 * 
		 * @private
		 */
		private static function parseComplexTypeParams(type:Object, params:String):Object
		{
			var len:int = params.length;
			var quotesCount:int = 0;
			var isInsideQuotes:Boolean = false;
			var current:String;
			var segment:String = "";
			var segments:Array = [];
			
			for (var i:int = 0; i < len; i++)
			{
				current = params.charAt(i);
				
				/* Check if we're inside quotes. */
				if (current == "\"")
				{
					quotesCount++;
					if (quotesCount == 1)
					{
						isInsideQuotes = true;
					}
					else if (quotesCount == 2)
					{
						quotesCount = 0;
						isInsideQuotes = false;
					}
				}
				
				/* Remove all whitespace unless we're inside quotes. */
				if (isInsideQuotes || current != " ")
				{
					segment += current;
				}
				
				/* Split the string where comma occurs, but not inside quotes. */
				if (!isInsideQuotes && current == ",")
				{
					/* Remove last char from segment which must be a comma. */
					segment = segment.substr(0, segment.length - 1);
					segments.push(segment);
					segment = "";
				}
				
				/* Last segment needs to be added extra. */
				if (i == len - 1)
				{
					segments.push(segment);
				}
			}
			
			/* Loop through segments and split them into property and value. */
			for each (segment in segments)
			{
				var a:Array = segment.split(":");
				var p:String = a[0];
				var v:String = a[1];
				
				/* If value is wrapped into quotes we need to remove these. */
				if (v.charAt(0) == "\"" && v.charAt(v.length - 1) == "\"")
				{
					v = v.substr(1, v.length - 2);
				}
				
				if (type.hasOwnProperty(p))
				{
					if (v == "") type[p] = null;
					else type[p] = v;
				}
				else
				{
					Log.warn("EntityDataParser: Tried to set a non-existing property <"
						+ p + "> in complex type " + type + ".");
				}
			}
			
			return type;
		}
	}
}
