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
package base.core.update
{
	import com.hexagonstar.display.shape.RectangleShape;
	import com.hexagonstar.ui.controls.Button;
	import com.hexagonstar.ui.controls.Label;
	import com.hexagonstar.ui.controls.TextArea;
	import com.hexagonstar.util.display.StageReference;

	import flash.display.Bitmap;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	
	/**
	 * UpdateDialog class
	 */
	public class UpdateDialog extends NativeWindow
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------		
		
		public static var EVENT_CHECK_UPDATE:String = "checkUpdate";
		public static var EVENT_INSTALL_UPDATE:String = "installUpdate";
		public static var EVENT_DOWNLOAD_UPDATE:String = "downloadUpdate";
		public static var EVENT_CANCEL_UPDATE:String = "cancelUpdate";
		public static var EVENT_INSTALL_LATER:String = "installLater";
		
		public static var UPDATE_DOWNLOADING:String = "updateDownloading";
		public static var INSTALL_UPDATE:String = "installUpdate";
		public static var UPDATE_AVAILABLE:String = "updateAvailable";
		public static var NO_UPDATE:String = "noUpdate";
		public static var CHECK_UPDATE:String = "checkUpdate";
		public static var UPDATE_ERROR:String = "updateError";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _titleLabel:Label;
		private var _messageLabel:Label;
		private var _releaseNotes:TextArea;
		private var _button1:Button;
		private var _button2:Button;
		
		private var _isFirstRun:Boolean;
		private var _installedVersion:String = "";
		private var _updateVersion:String = "";
		private var _updateDescription:String = "";
		private var _applicationName:String = "";
		private var _updateState:String;
		private var _errorText:String = "There was an error checking for updates.";
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function UpdateDialog()
		{
			var wo:NativeWindowInitOptions = new NativeWindowInitOptions();
			wo.systemChrome = NativeWindowSystemChrome.STANDARD;
			wo.type = NativeWindowType.NORMAL;
			wo.maximizable = false;
			wo.minimizable = false;
			wo.resizable = false;
			
			super(wo);
			
			setup();
			updateDisplayText();
			activate();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function open():void
		{
		}
		
		
		public function updateDownloadProgress(percent:Number):void
		{
		}
		
		
		public function dispose():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function set isFirstRun(v:Boolean):void
		{
			_isFirstRun = v;
		}
		public function set installedVersion(v:String):void
		{
			_installedVersion = v;
			updateDisplayText();
		}
		public function set upateVersion(v:String):void
		{
			_updateVersion = v;
			updateDisplayText();
		}
		public function set updateState(v:String):void
		{
			_updateState = v;
		}
		public function set applicationName(v:String):void
		{
			_applicationName = v;
			updateDisplayText();
		}
		public function set description(v:String):void
		{
			_updateDescription = v;
			updateDisplayText();
		}
		public function set errorText(v:String):void
		{
			_errorText = v;
			updateDisplayText();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var p:NativeWindow = StageReference.stage.nativeWindow;
			var w:int = 520;
			var h:int = 330;
			bounds = new Rectangle(int(p.x + (p.width * 0.5) - (w * 0.5)), int(p.y + (p.height * 0.5) - (h * 0.5)), w, h);
			title = "Update";
			
			var titleFormat:TextFormat = new TextFormat("Arial", 26, 0xFFFFFF);
			var textFormat:TextFormat = new TextFormat("Arial", 14, 0xFFFFFF);
			var notesFormat:TextFormat = new TextFormat("Arial", 12, 0x222222);
			
			var bg:RectangleShape = new RectangleShape(w, h, 0x262626);
			var icon:Bitmap = new Bitmap(new UpdateIcon());
			icon.x = 10;
			icon.y = 10;
			
			_titleLabel = new Label(360, 35);
			_titleLabel.setStyle("textFormat", titleFormat);
			_titleLabel.x = 110;
			_titleLabel.y = 10;
			
			_messageLabel = new Label(360, 94);
			_messageLabel.setStyle("textFormat", textFormat);
			_messageLabel.x = 110;
			_messageLabel.y = 50;
			_messageLabel.wordWrap = true;
			
			_releaseNotes = new TextArea(110, 150, 360, 82);
			_releaseNotes.setStyle("textFormat", notesFormat);
			_releaseNotes.wordWrap = true;
			_releaseNotes.editable = false;
			
			_button1 = new Button(110, 250, 120, 28);
			_button1.emphasized = true;
			
			_button2 = new Button(240, 250, 120, 28);
			
			stage.addChild(bg);
			stage.addChild(icon);
			stage.addChild(_titleLabel);
			stage.addChild(_messageLabel);
			stage.addChild(_releaseNotes);
			stage.addChild(_button1);
			stage.addChild(_button2);
		}
		
		
		private function updateDisplayText():void
		{
			_titleLabel.text = "Update Available";
			_messageLabel.text = "An updated version of " + _applicationName
				+ " is available and can be downloaded."
				+ "\n\nInstalled version:\t" + _installedVersion
				+ "\nUpdate version:\t\t" + _updateVersion;
			_releaseNotes.text = _updateDescription;
			
			_button1.label = "Download Now";
			_button2.label = "Download Later";
		}
	}
}
