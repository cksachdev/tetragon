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
package base.command.file
{
	import base.command.CLICommand;
	import base.core.debug.Log;
	import base.io.resource.Resource;
	import base.io.resource.ResourceManager;

	import com.hexagonstar.types.Byte;

	import flash.display.BitmapData;
	import flash.media.Sound;
	import flash.utils.ByteArray;



	
	public class ResourceInfoCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _resourceID:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void 
		{
			super.execute();
			
			var r:Resource = ResourceManager.resourceIndex.getResource(_resourceID);
			if (r)
			{
				var content:* = r.content;
				var size:String;
				if (content)
				{
					if (content is ByteArray)
						size = new Byte(ByteArray(content).length).toString();
					else if (content is BitmapData)
						size = new Byte(BitmapData(content).width * BitmapData(content).height).toString();
					else if (content is String)
						size = new Byte(String(content).length).toString();
					else if (content is Array)
						size = "" + (content as Array).length;
					else if (content is XML)
						size = new Byte(XML(content).toXMLString().length).toString();
					else if (content is XMLList)
						size = "" + XMLList(content).length();
					else if (content is Sound)
						size = new Byte(Sound(content).bytesTotal).toString();
					else
					{
						try
						{
							var b:ByteArray = new ByteArray();
							b.writeObject(content);
							size = b.length.toString();
						}
						catch (err:Error)
						{
						}
					}
				}
				
				var s:String = "\n\tid:             " + r.id
					+ "\n\tpath:           " + r.path
					+ "\n\tpackageID:      " + r.packageID
					+ "\n\tdataFileID:     " + r.dataFileID
					+ "\n\tdataType:       " + r.dataType
					+ "\n\tembedded:       " + r.embedded
					+ "\n\treferenceCount: " + r.referenceCount
					+ "\n\tstatus:         " + r.status
					+ "\n\tcontent:        " + content
					+ (size ? "\n\tsize:           " + size : "")
					+ "\n\twrapperClass:   " + r.wrapperClass
					+ "";
				Log.info(s);
			}
			else
			{
				Log.error("no resource with ID \"" + _resourceID + "\" found!");
			}
			
			complete();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String 
		{
			return "resourceinfo";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get signature():Array
		{
			return ["resourceID:String"];
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get helpText():String
		{
			return "Outputs info about the resource with the specified resource ID.";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get example():String
		{
			return "resourceinfo \"resourceID\"";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// CLI Command Signature Arguments
		//-----------------------------------------------------------------------------------------
		
		public function set resourceID(v:String):void
		{
			_resourceID = v;
		}
	}
}
