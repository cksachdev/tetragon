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
	import base.util.ui.createButton;
	import base.util.ui.createLabel;
	import base.util.ui.createTextArea;

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
		
		public static var STATUS_DOWNLOADING:String		= "statusDownloading";
		public static var STATUS_INSTALL:String			= "statusInstall";
		public static var STATUS_AVAILABLE:String		= "statusAvailable";
		public static var STATUS_ERROR:String			= "statusError";
		
		public static var EVENT_CHECK_UPDATE:String		= "eventCheckUpdate";
		public static var EVENT_INSTALL_UPDATE:String	= "eventInstallUpdate";
		public static var EVENT_DOWNLOAD_UPDATE:String	= "eventDownloadUpdate";
		public static var EVENT_CANCEL_UPDATE:String	= "eventCancelUpdate";
		public static var EVENT_INSTALL_LATER:String	= "eventInstallLater";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _uiContainer:Sprite;
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
		private var _errorText:String;
		private var _progress:int = 0;
		
		
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
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function open():void
		{
			activate();
			orderToFront();
			visible = true;
		}
		
		
		public function updateDownloadProgress(progress:int):void
		{
			_progress = progress;
			if (_messageLabel) _messageLabel.text = "Progress: " + _progress + "%";
		}
		
		
		public function dispose():void
		{
			stage.removeChild(_uiContainer);
			removeUIListeners();
			removeEventListener(Event.CLOSE, onClose);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function set currentState(v:String):void
		{
			if (v == _currentState) return;
			_currentState = v;
			switchUIState();
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
			if (_currentState == STATUS_AVAILABLE)
				dispatchEvent(new Event(EVENT_DOWNLOAD_UPDATE));
			else if (_currentState == STATUS_INSTALL)
				dispatchEvent(new Event(EVENT_INSTALL_UPDATE));
		}
		
		
		private function onCancelButtonClick(e:MouseEvent):void
		{
			if (_currentState == STATUS_INSTALL)
				dispatchEvent(new Event(EVENT_INSTALL_LATER));
			else
				dispatchEvent(new Event(EVENT_CANCEL_UPDATE));
		}
		
		
		private function onClose(e:Event):void
		{
			dispatchEvent(new Event(EVENT_CANCEL_UPDATE));
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function setup():void
		{
			visible = false;
			title = "Update";
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			var w:int = 520;
			var h:int = 330;
			var p:NativeWindow = StageReference.stage.nativeWindow;
			bounds = new Rectangle(int(p.x + (p.width * 0.5) - (w * 0.5)), int(p.y + (p.height * 0.5) - (h * 0.5)), w, h);
			
			_titleFormat = new TextFormat("Bitstream Vera Sans", 26, 0xFFFFFF);
			_textFormat = new TextFormat("Bitstream Vera Sans", 12, 0xEEEEEE);
			_notesFormat = new TextFormat("Bitstream Vera Sans", 10, 0x222222);
			
			var bg:RectangleShape = new RectangleShape(w, h, 0x262626);
			stage.addChild(bg);
			var icon:Bitmap = new Bitmap(new UpdateIcon());
			icon.x = 10;
			icon.y = 10;
			stage.addChild(icon);
			
			_uiContainer = new Sprite();
			stage.addChild(_uiContainer);
			
			addEventListener(Event.CLOSE, onClose);
		}
		
		
		private function switchUIState():void
		{
			while(_uiContainer.numChildren > 0)
			{
				_uiContainer.removeChildAt(0);
			}
			removeUIListeners();
			switch (_currentState)
			{
				case STATUS_AVAILABLE:
					createUpdateAvailableState();
					break;
				case STATUS_DOWNLOADING:
					createUpdateDownloadState();
					break;
				case STATUS_INSTALL:
					createUpdateInstallState();
					break;
				case STATUS_ERROR:
					createUpdateErrorState();
					break;
			}
		}
		
		
		private function createUpdateAvailableState():void
		{
			_titleLabel = createLabel(110, 10, 360, 35, _titleFormat, false, "Update Available");
			_uiContainer.addChild(_titleLabel);
			
			var message:String = "An updated version of " + _applicationName
				+ " is available and can be downloaded."
				+ "\n\nInstalled version:\t" + _currentVersion
				+ "\nUpdate version:\t" + _updateVersion;
			_messageLabel = createLabel(110, 50, 360, 94, _textFormat, true, message);
			_uiContainer.addChild(_messageLabel);
			
			_releaseNotes = createTextArea(110, 150, 360, 82, _notesFormat, true, false, _updateDescription);
			_uiContainer.addChild(_releaseNotes);
			
			_okButton = createButton(110, 250, 140, 28, true, "Download now");
			_okButton.addEventListener(MouseEvent.CLICK, onOKButtonClick);
			_uiContainer.addChild(_okButton);
			
			_cancelButton = createButton(260, 250, 140, 28, false, "Download later");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		private function createUpdateDownloadState():void
		{
			_titleLabel = createLabel(110, 10, 360, 35, _titleFormat, false, "Downloading Update");
			_uiContainer.addChild(_titleLabel);
			
			_messageLabel = createLabel(110, 50, 360, 94, _textFormat, true, "Progress: " + _progress + "%");
			_uiContainer.addChild(_messageLabel);
			
			// TODO Add progress bar!
			
			_cancelButton = createButton(110, 250, 140, 28, false, "Cancel");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		private function createUpdateInstallState():void
		{
			_titleLabel = createLabel(110, 10, 360, 35, _titleFormat, false, "Install Update");
			_uiContainer.addChild(_titleLabel);
			
			var message:String = "The update for " + _applicationName + " is downloaded and ready to be installed."
				+ "\n\nInstalled version:\t" + _currentVersion
				+ "\nUpdate version:\t" + _updateVersion;
			_messageLabel = createLabel(110, 50, 360, 94, _textFormat, true, message);
			_uiContainer.addChild(_messageLabel);
			
			_releaseNotes = createTextArea(110, 150, 360, 82, _notesFormat, true, false, _updateDescription);
			_uiContainer.addChild(_releaseNotes);
			
			_okButton = createButton(110, 250, 140, 28, true, "Install now");
			_okButton.addEventListener(MouseEvent.CLICK, onOKButtonClick);
			_uiContainer.addChild(_okButton);
			
			_cancelButton = createButton(260, 250, 140, 28, false, "Postpone until restart");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		private function createUpdateErrorState():void
		{
			_titleLabel = createLabel(110, 10, 360, 35, _titleFormat, false, "Update Error");
			_uiContainer.addChild(_titleLabel);
			
			var message:String = "An error occured while updating:";
			_messageLabel = createLabel(110, 70, 360, 34, _textFormat, false, message);
			_uiContainer.addChild(_messageLabel);
			
			_releaseNotes = createTextArea(110, 100, 360, 82, _notesFormat, true, false, _errorText);
			_uiContainer.addChild(_releaseNotes);
			
			_cancelButton = createButton(110, 250, 140, 28, false, "Close");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		private function removeUIListeners():void
		{
			if (_okButton) _okButton.removeEventListener(MouseEvent.CLICK, onOKButtonClick);
			if (_cancelButton) _cancelButton.removeEventListener(MouseEvent.CLICK, onCancelButtonClick);
		}
	}
}
