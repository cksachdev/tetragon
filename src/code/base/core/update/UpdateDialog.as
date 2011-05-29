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
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
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
		public static var UPDATE_ERROR:String = "updateError";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _uiStateContainer:Sprite;
		private var _titleLabel:Label;
		private var _messageLabel:Label;
		private var _releaseNotes:TextArea;
		private var _okButton:Button;
		private var _cancelButton:Button;
		
		private var _titleFormat:TextFormat;
		private var _textFormat:TextFormat;
		private var _notesFormat:TextFormat;
		
		private var _isFirstRun:Boolean;
		private var _currentState:String;
		
		private var _currentVersion:String = "";
		private var _updateVersion:String = "";
		private var _updateDescription:String = "";
		private var _applicationName:String = "";
		private var _progress:int = 0;
		
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
			activate();
			orderToFront();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function open():void
		{
		}
		
		
		public function updateDownloadProgress(percent:Number):void
		{
			_progress = percent;
			if (_messageLabel) _messageLabel.text = "Progress: " + _progress + "%";
		}
		
		
		public function dispose():void
		{
			stage.removeChild(_uiStateContainer);
			removeListeners();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function set currentState(v:String):void
		{
			if (v == _currentState) return;
			_currentState = v;
			switchState();
		}
		public function set isFirstRun(v:Boolean):void
		{
			_isFirstRun = v;
		}
		public function set currentVersion(v:String):void
		{
			_currentVersion = v;
		}
		public function set upateVersion(v:String):void
		{
			_updateVersion = v;
		}
		public function set applicationName(v:String):void
		{
			_applicationName = v;
		}
		public function set description(v:String):void
		{
			_updateDescription = v;
		}
		public function set errorText(v:String):void
		{
			_errorText = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onOKButtonClick(e:MouseEvent):void
		{
			if (_currentState == UPDATE_AVAILABLE) dispatchEvent(new Event(EVENT_DOWNLOAD_UPDATE));
			else if (_currentState == INSTALL_UPDATE) dispatchEvent(new Event(EVENT_INSTALL_UPDATE));
		}
		
		
		private function onCancelButtonClick(e:MouseEvent):void
		{
			if (_currentState == INSTALL_UPDATE)
			{
				dispatchEvent(new Event(EVENT_INSTALL_LATER));
				return;
			}
			dispatchEvent(new Event(EVENT_CANCEL_UPDATE));
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function setup():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			var w:int = 520;
			var h:int = 330;
			var p:NativeWindow = StageReference.stage.nativeWindow;
			bounds = new Rectangle(int(p.x + (p.width * 0.5) - (w * 0.5)), int(p.y + (p.height * 0.5) - (h * 0.5)), w, h);
			title = "Update";
			
			_titleFormat = new TextFormat("Arial", 26, 0xFFFFFF);
			_textFormat = new TextFormat("Arial", 14, 0xEEEEEE);
			_notesFormat = new TextFormat("Arial", 12, 0x222222);
			
			var bg:RectangleShape = new RectangleShape(w, h, 0x262626);
			stage.addChild(bg);
			var icon:Bitmap = new Bitmap(new UpdateIcon());
			icon.x = 10;
			icon.y = 10;
			stage.addChild(icon);
			
			_uiStateContainer = new Sprite();
			stage.addChild(_uiStateContainer);
		}
		
		
		private function switchState():void
		{
			while(_uiStateContainer.numChildren > 0)
			{
				_uiStateContainer.removeChildAt(0);
			}
			removeListeners();
			switch (_currentState)
			{
				case UPDATE_AVAILABLE:
					createUpdateAvailableState();
					break;
				case UPDATE_DOWNLOADING:
					createUpdateDownloadState();
					break;
			}
		}
		
		
		private function createUpdateAvailableState():void
		{
			_titleLabel = new Label(360, 35);
			_titleLabel.setStyle("textFormat", _titleFormat);
			_titleLabel.x = 110;
			_titleLabel.y = 10;
			_titleLabel.text = "Update Available";
			_uiStateContainer.addChild(_titleLabel);
			
			_messageLabel = new Label(360, 94);
			_messageLabel.setStyle("textFormat", _textFormat);
			_messageLabel.x = 110;
			_messageLabel.y = 50;
			_messageLabel.wordWrap = true;
			_messageLabel.text = "An updated version of " + _applicationName
				+ " is available and can be downloaded."
				+ "\n\nInstalled version:\t" + _currentVersion
				+ "\nUpdate version:\t\t" + _updateVersion;
			_uiStateContainer.addChild(_messageLabel);
			
			_releaseNotes = new TextArea(110, 150, 360, 82);
			_releaseNotes.setStyle("textFormat", _notesFormat);
			_releaseNotes.wordWrap = true;
			_releaseNotes.editable = false;
			_releaseNotes.text = _updateDescription;
			_uiStateContainer.addChild(_releaseNotes);
			
			_okButton = new Button(110, 250, 120, 28);
			_okButton.emphasized = true;
			_okButton.label = "Download Now";
			_okButton.addEventListener(MouseEvent.CLICK, onOKButtonClick);
			_uiStateContainer.addChild(_okButton);
			
			_cancelButton = new Button(240, 250, 120, 28);
			_cancelButton.label = "Download Later";
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiStateContainer.addChild(_cancelButton);
		}
		
		
		private function createUpdateDownloadState():void
		{
			_titleLabel = new Label(360, 35);
			_titleLabel.setStyle("textFormat", _titleFormat);
			_titleLabel.x = 110;
			_titleLabel.y = 10;
			_titleLabel.text = "Downloading Update";
			_uiStateContainer.addChild(_titleLabel);
			
			_messageLabel = new Label(360, 94);
			_messageLabel.setStyle("textFormat", _textFormat);
			_messageLabel.x = 110;
			_messageLabel.y = 50;
			_messageLabel.text = "Progress: " + _progress + "%";
			_uiStateContainer.addChild(_messageLabel);
			
			// TODO Add progress bar!
			
			_cancelButton = new Button(110, 250, 120, 28);
			_cancelButton.label = "Cancel";
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiStateContainer.addChild(_cancelButton);
		}
		
		
		private function removeListeners():void
		{
			if (_okButton) _okButton.removeEventListener(MouseEvent.CLICK, onOKButtonClick);
			if (_cancelButton) _cancelButton.removeEventListener(MouseEvent.CLICK, onCancelButtonClick);
		}
	}
}
