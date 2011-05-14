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
package base.view.loadprogressbar
{
	import base.event.ResourceEvent;

	import com.hexagonstar.util.display.StageReference;

	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	/**
	 * A load progress display that displays extensive loading information.
	 */
	public class DebugLoadProgressDisplay extends LoadProgressDisplay
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _tf:TextField;
		protected var _text:String;
		protected var _percentage:Number;
		protected var _isComplete:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		override public function reset():void
		{
			_text = "";
			_percentage = 0;
			_isComplete = false;
		}
		
		
		override public function update(e:ResourceEvent):void
		{
			if (_isComplete) return;
			
			_percentage = e.bytesLoaded / e.bytesTotal * 100;
			_text += "Loading bulkfile: " + e.bulkFile.id
				+ "\nBytes loaded: " + e.bytesLoaded + " / " + e.bytesTotal
				+ "\n";
			
			if (_percentage == 100)
			{
				_isComplete = true;
				_text += "\nAll loading completed.";
				if (waitForUserInput)
				{
					_text += " Press mouse to continue.";
					StageReference.stage.addEventListener(MouseEvent.CLICK, onMouseClick);
				}
			}
			
			_tf.text = _text;
			_tf.scrollV = _tf.maxScrollV;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		override public function get closeScreenBeforeLoad():Boolean
		{
			return true;
		}
		
		
		override public function get waitForUserInput():Boolean
		{
			return true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function setup():void
		{
			var f:TextFormat = new TextFormat("Terminalscope", 16, 0xFFFFFF);
			
			_tf = new TextField();
			_tf.antiAliasType = AntiAliasType.NORMAL;
			_tf.gridFitType = GridFitType.PIXEL;
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.embedFonts = true;
			_tf.focusRect = false;
			_tf.selectable = false;
			_tf.width = 600;
			_tf.height = 200;
			//_tf.border = true;
			//_tf.borderColor = 0xFFFFFF;
			_tf.defaultTextFormat = f;
			addChild(_tf);
			
			x = 30;
			y = 30;
		}
		
		
		private function onMouseClick(e:MouseEvent):void
		{
			e.preventDefault();
			StageReference.stage.removeEventListener(MouseEvent.CLICK, onMouseClick);
			userInputSignal.dispatch();
		}
	}
}
