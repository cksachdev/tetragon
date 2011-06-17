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
	import base.util.ui.createProgressBar;
	import base.util.ui.createTextArea;

	import com.hexagonstar.display.shape.RectangleShape;
	import com.hexagonstar.ui.controls.Button;
	import com.hexagonstar.ui.controls.Label;
	import com.hexagonstar.ui.controls.ProgressBar;
	import com.hexagonstar.ui.controls.TextArea;
	import com.hexagonstar.update.ui.UpdateUI;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	
	/**
	 * UpdateDialog class
	 */
	public class UpdateDialog extends UpdateUI
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _titleLabel:Label;
		private var _messageLabel:Label;
		private var _releaseNotes:TextArea;
		private var _progressBar:ProgressBar;
		private var _okButton:Button;
		private var _cancelButton:Button;
		
		private var _titleFormat:TextFormat;
		private var _textFormat:TextFormat;
		private var _notesFormat:TextFormat;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		override public function updateProgress(progress:int):void
		{
			_progress = progress;
			if (_messageLabel) _messageLabel.text = "Progress: " + _progress + "%";
			if (_progressBar) _progressBar.setProgress(_progress, 100);
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
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function setup():void
		{
			_titleFormat = new TextFormat("Bitstream Vera Sans", 26, 0xFFFFFF);
			_textFormat = new TextFormat("Bitstream Vera Sans", 12, 0xEEEEEE);
			_notesFormat = new TextFormat("Bitstream Vera Sans", 10, 0x222222);
			
			var bg:RectangleShape = new RectangleShape(520, 330, 0x262626);
			var icon:UpdateDialogIcon = new UpdateDialogIcon();
			icon.x = 10;
			icon.y = 10;
			
			addChild(bg);
			addChild(icon);
		}
		
		
		override protected function createUpdateAvailableState():void
		{
			_titleLabel = createLabel(110, 10, 370, 35, _titleFormat, false, "Update Available");
			_uiContainer.addChild(_titleLabel);
			
			var message:String = "An updated version of " + _applicationName
				+ " is available and can be downloaded."
				+ "\n\nInstalled version:\t" + _currentVersion
				+ "\nUpdate version:\t" + _updateVersion;
			_messageLabel = createLabel(110, 50, 370, 94, _textFormat, true, message);
			_uiContainer.addChild(_messageLabel);
			
			_releaseNotes = createTextArea(110, 140, 380, 92, _notesFormat, true, false, _updateDescription);
			_uiContainer.addChild(_releaseNotes);
			
			_okButton = createButton(110, 250, 140, 28, true, "Download now");
			_okButton.addEventListener(MouseEvent.CLICK, onOKButtonClick);
			_uiContainer.addChild(_okButton);
			
			_cancelButton = createButton(260, 250, 140, 28, false, "Download later");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		override protected function createUpdateDownloadState():void
		{
			_titleLabel = createLabel(110, 10, 370, 35, _titleFormat, false, "Downloading Update");
			_uiContainer.addChild(_titleLabel);
			
			_messageLabel = createLabel(110, 70, 370, 18, _textFormat, true, "Progress: " + _progress + "%");
			_uiContainer.addChild(_messageLabel);
			
			_progressBar = createProgressBar(110, 92, 370, 16);
			_uiContainer.addChild(_progressBar);
			
			_releaseNotes = createTextArea(110, 140, 380, 92, _notesFormat, true, false, _updateDescription);
			_uiContainer.addChild(_releaseNotes);
			
			_cancelButton = createButton(110, 250, 140, 28, false, "Cancel");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		override protected function createUpdateInstallState():void
		{
			_titleLabel = createLabel(110, 10, 370, 35, _titleFormat, false, "Install Update");
			_uiContainer.addChild(_titleLabel);
			
			var message:String = "The update for " + _applicationName + " is downloaded and ready to be installed."
				+ "\n\nInstalled version:\t" + _currentVersion
				+ "\nUpdate version:\t" + _updateVersion;
			_messageLabel = createLabel(110, 50, 370, 94, _textFormat, true, message);
			_uiContainer.addChild(_messageLabel);
			
			_releaseNotes = createTextArea(110, 140, 380, 92, _notesFormat, true, false, _updateDescription);
			_uiContainer.addChild(_releaseNotes);
			
			_okButton = createButton(110, 250, 140, 28, true, "Install now");
			_okButton.addEventListener(MouseEvent.CLICK, onOKButtonClick);
			_uiContainer.addChild(_okButton);
			
			_cancelButton = createButton(260, 250, 140, 28, false, "Postpone until restart");
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			_uiContainer.addChild(_cancelButton);
		}
		
		
		override protected function createUpdateErrorState():void
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
		
		
		override protected function removeUIListeners():void
		{
			if (_okButton) _okButton.removeEventListener(MouseEvent.CLICK, onOKButtonClick);
			if (_cancelButton) _cancelButton.removeEventListener(MouseEvent.CLICK, onCancelButtonClick);
		}
	}
}
