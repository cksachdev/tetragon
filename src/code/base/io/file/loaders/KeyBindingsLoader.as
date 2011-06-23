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
package base.io.file.loaders
{
	import base.Main;
	import base.data.Registry;
	import base.data.Settings;
	import base.io.key.KeyManager;

	import com.hexagonstar.file.types.IFile;
	import com.hexagonstar.file.types.TextFile;
	
	
	public final class KeyBindingsLoader extends FileLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _keyManager:KeyManager;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function KeyBindingsLoader()
		{
			_keyManager = Main.instance.keyManager;
			
			var filePath:String;
			var userKBPath:String = Registry.settings.getSettings(Settings.USER_KEYBINDINGS_FILE);
			if (userKBPath != null) filePath = userKBPath;
			else filePath = Registry.config.keyBindingsFileName;
			addFile(filePath, "keyBindingsFile");
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function addFile(filePath:String, fileID:String = null):void
		{
			if (_loader.loading) return;
			_loader.addFile(new TextFile(filePath, fileID));
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function load():void
		{
			_loader.load();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		override public function onAllFilesComplete(file:IFile):void
		{
			super.onAllFilesComplete(file);
			
			_loader.reset();
			if (file.valid)
			{
				parse(TextFile(file));
			}
			else
			{
				notifyError("File invalid or not found \"" + file.toString() + "\" ("
					+ file.status + ")");
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function parse(file:TextFile):void
		{
			var text:String = file.contentAsString;
			var lines:Array = text.match(/^.+$/gm);
			var key:String;
			var val:String;
			
			for each (var l:String in lines)
			{
				const firstChar:String = trim(l).substr(0, 1);
				
				/* Ignore lines that are comments or headers */
				if (firstChar != "#" && firstChar != "[")
				{
					const pos:int = l.indexOf("=");
					key = trim(l.substring(0, pos));
					val = trim(l.substring(pos + 1, l.length));
					parseBinding(key, val);
				}
			}
			
			if (_completeSignal) _completeSignal.dispatch();
		}
		
		
		private function parseBinding(keyIdentifier:String, combinationString:String):void
		{
			var keyExists:Boolean = true;
			var p:*;
			// TODO Map key combinations in KeyManager under their keyIdentifier.
		}
	}
}
