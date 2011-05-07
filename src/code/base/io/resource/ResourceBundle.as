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
package base.io.resource
{
	import base.core.debug.Log;

	import com.hexagonstar.exception.FatalException;

	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;



	
	/**
	 * The resource bundle handles automatic loading and registering of embedded
	 * resources. To use, create a descendant class and embed resources as public
	 * variables, then instantiate your new class. ResourceBundle will handle loading
	 * all of those resources into the ResourceManager.
	 */
	public class ResourceBundle
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * ExtensionTypes associates filename extensions with the resource type that they
		 * are to be loaded as. Each entry should be in the form of
		 * 'xml:"com.hexagonstar.io.resource.XMLResource"' Where xml is the
		 * filename extension that should be associated with this type, and where
		 * "com.hexagonstar.io.resource.XMLResource" is the fully qualified
		 * resource class name string, and xml is the (lower-case) extension. This array can
		 * be extended at runtime, such as: ResourceBundle.extensionTypes.mycustomext =
		 * "com.mydomain.customresource"
		 */
		public static var extensionTypes:Object =
		{
			gif:	"ImageResource",
			jpg:	"ImageResource",
			jpeg:	"ImageResource",
			png:	"TrImageResource",
			svg:	"TrImageResource",
			svgz:	"TrImageResource",
			swf:	"SWFResource",
			txt:	"TextResource",
			ini:	"TextResource",
			css:	"TextResource",
			htm:	"TextResource",
			html:	"TextResource",
			xml:	"XMLResource",
			mp3:	"SoundResource",
			obj:	"BinaryResource",
			pbj:	"BinaryResource"
		};
		
		/**
		 * Package under which resource type classes are found. NOTE: this string
		 * needs to be adapted in case the classes are being moved to any other package!
		 * @private
		 */
		protected static const PACKAGE:String = "base.io.resource.resources";
		
		/** @private */
		protected var _resourceCount:int = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * init
		 */
		public function init(resourceIndex:ResourceIndex):void
		{
			var xml:XML = describeType(this);
			var res:Class;
			var resName:String;
			var resID:String;
			var resType:String;
			var resFamily:String;
			var resPID:String;
			var resPath:String;
			var pkgType:String;
			var isEmbedded:Boolean;
			
			/* Loop through each public variable in this class */
			for each (var v:XML in xml.variable)
			{
				resName = v.@name;
				res = this[resName];
				
				resID = null;
				resType = null;
				resFamily = null;
				resPID = null;
				resPath = null;
				pkgType = null;
				
				/* Assume that there is no properly embedded,
				 * so that we can show an error if needed. */
				isEmbedded = false;
				
				/* Loop through each metadata tag in the child variable */
				for each (var meta:XML in v.children())
				{
					var a:XML;
					/* If we've got an embedded resource tag */
					if (meta.@name == "Resource")
					{
						for each (a in meta.children())
						{
							switch (String(a.@key))
							{
								case "id":
									resID = a.@value;
									break;
								case "family":
									resFamily = a.@value;
									break;
								case "type":
									resType = a.@value;
									break;
								case "parserID":
									/* Not all resources need a parserID. */
									if (String(a.@value).length > 0) resPID = a.@value;
							}
						}
					}
					/* If we've got an embedded metadata tag */
					else if (meta.@name == "Embed")
					{
						isEmbedded = true;
						/* Extract the source path from the embed tag. */
						for each (a in meta.children())
						{
							if (a.@key == "source") resPath = a.@value;
						}
					}
				}
				
				/* Sanity check */
				if (!isEmbedded || res == null || resID == null || resPath == null)
				{
					Log.error("A resource in the resource bundle with the name \"" + resName
						+ "\" has failed to embed properly. Please ensure that you have"
						+ " the compiler option '--keep-as3-metadata+=TypeHint,EditorData,Resource,"
						+ " Embed' set properly. Additionally, please check that the [Resource]"
						+ " and [Embed] metadata syntax is correct.", this);
					continue;
				}
				
				/* Try to determine the resource's type class, first by it's embedded type
				 * parameter and if that fails try the file extension. */
				var clazz:Class;
				if (resType && resType.length > 0)
				{
					clazz = resourceTypeMap[resType];
					if (!clazz)
					{
						Log.warn("No resource type class found for embedded resource with ID \""
							+ resID + "\" (type: " + resType
							+ "). Falling back to file extension detection.", this);
					}
				}
				
				if (clazz == null)
				{
					/* Get the extension of the source filename */
					var ext:String = resPath.substring(resPath.lastIndexOf(".") + 1);
					
					/* Check if the extension type is recognized or not. */
					if (!ResourceBundle.extensionTypes.hasOwnProperty(ext))
					{
						Log.warn("No resource type is specified for extension \"." + ext
							+ "\". Defaulting to BinaryResource for \"" + resID + "\".", this);
						pkgType = ResourceBundle.PACKAGE + ".BinaryResource";
					}
					else
					{
						pkgType = ResourceBundle.PACKAGE + "." + ResourceBundle.extensionTypes[ext];
						try
						{
							clazz = Class(getDefinitionByName(pkgType));
						}
						catch (err:Error)
						{
							clazz = null;
							Log.error("Could not determine the resource type class definition for "
								+ pkgType + ". Please ensure that the class definition is correct"
								+ " and that the class is explicity referenced somewhere in the"
								+ " project. (Error message was: " + err.message + ")", this);
							continue;
						}
					}
				}
				
				/* Everything so far is hunky-dory -- go ahead and register the embedded
				 * resource in the resource index! Embedded resources use the resource
				 * variable name as the path. */
				resourceIndex.addResource(resID, resName, null, null, clazz, resFamily, resPID, true);
				_resourceCount++;
			}
			
			Log.debug("Nr. of embedded resources: " + _resourceCount, this);
		}
		
		
		/**
		 * getResourceData
		 */
		public function getResourceData(resourceDataName:String):*
		{
			var res:*;
			
			try
			{
				var clazz:Class = this[resourceDataName];
				res = new clazz();
			}
			catch (err:Error)
			{
				throw new FatalException(toString() + " Could not instantiate a resource of '"
					+ resourceDataName + "' (Error was: " + err.message + ")");
				return null;
			}
			
			return res;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[ResourceBundle]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The amount of embedded resources.
		 */
		public function get resourceCount():int
		{
			return _resourceCount;
		}
	}
}
