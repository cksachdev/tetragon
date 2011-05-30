package base.core.update
{
	import air.update.ApplicationUpdater;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusFileUpdateErrorEvent;
	import air.update.events.StatusFileUpdateEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;

	import base.AppInfo;
	import base.core.debug.Log;
	import base.data.Registry;

	import com.hexagonstar.signals.Signal;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	
	public class UpdateManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _updater:ApplicationUpdater;
		private var _dialog:UpdateDialog;
		
		private var _currentVersion:String;
		private var _updateVersion:String;
		private var _applicationName:String;
		private var _description:String;
		
		private var _isFirstRun:Boolean;
		private var _isInstallPostponed:Boolean = false;
		private var _checkAfterInitialize:Boolean = true;
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _finishedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Constructer for UpdateManager Class
		 */
		public function UpdateManager()
		{
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function checkNow():void
		{
			_isInstallPostponed = false;
			_updater.checkNow();
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			_finishedSignal.removeAll();
			disposeUpdater();
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "UpdateManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get finishedSignal():Signal
		{
			return _finishedSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onUpdaterInitialized(e:UpdateEvent):void
		{
			_isFirstRun = _updater.isFirstRun;
			_applicationName = AppInfo.NAME; //getApplicationName();
			_currentVersion = _updater.currentVersion;
			Log.debug("Initialized (current version: " + _currentVersion + ").", this);
			if (_checkAfterInitialize) _updater.checkNow();
			else finish();
		}
		
		
		private function onStatusUpdate(e:StatusUpdateEvent):void
		{
			e.preventDefault();
			if (e.available)
			{
				/* Extract update description notes. */
				if (e.details && e.details.length == 1) _description = e.details[0][1];
				else _description = "";
				
				_updateVersion = e.version;
				Log.debug("Update available: v" + _updateVersion, this);
				createDialog(UpdateDialog.STATUS_AVAILABLE);
			}
			else
			{
				finish();
			}
		}
		
		
		private function onStatusUpdateError(e:StatusUpdateErrorEvent):void
		{
			/* Could not reach the update file on the server. Don't bother! */
			e.preventDefault();
			Log.debug("Could not get update status (" + e.text + ").", this);
			finish();
		}
		
		
		private function onStatusFileUpdate(e:StatusFileUpdateEvent):void
		{
			e.preventDefault();
			if (e.available)
			{
				_dialog.currentState = UpdateDialog.STATUS_DOWNLOADING;
				_updater.downloadUpdate();
			}
			else
			{
				_dialog.currentState = UpdateDialog.STATUS_ERROR;
			}
		}
		
		
		private function onStatusFileUpdateError(e:StatusFileUpdateErrorEvent):void
		{
			e.preventDefault();
			_dialog.currentState = UpdateDialog.STATUS_ERROR;
		}
		
		
		private function onUpdateError(e:ErrorEvent):void
		{
			Log.error("Update Error: " + e.text, this);
			if (_dialog)
			{
				_dialog.errorText = e.text;
				_dialog.currentState = UpdateDialog.STATUS_ERROR;
			}
		}
		
		
		private function onCheckUpdate(e:Event):void
		{
			_updater.checkNow();
		}
		
		
		private function onDownloadUpdate(e:Event):void
		{
			_dialog.currentState = UpdateDialog.STATUS_DOWNLOADING;
			_updater.downloadUpdate();
		}
		
		
		private function onDownloadProgress(e:ProgressEvent):void
		{
			_dialog.currentState = UpdateDialog.STATUS_DOWNLOADING;
			var percent:Number = (e.bytesLoaded / e.bytesTotal) * 100;
			_dialog.updateDownloadProgress(percent);
		}
		
		
		private function onDownloadComplete(e:UpdateEvent):void
		{
			e.preventDefault();
			_dialog.currentState = UpdateDialog.STATUS_INSTALL;
		}
		
		
		private function onDownloadError(e:DownloadErrorEvent):void
		{
			e.preventDefault();
			_dialog.currentState = UpdateDialog.STATUS_ERROR;
		}
		
		
		private function onInstallUpdate(e:Event):void
		{
			_updater.installUpdate();
		}
		
		
		private function onInstallLater(e:Event):void
		{
			_isInstallPostponed = true;
			_updater.installUpdate();
			disposeDialog();
			finish();
		}
		
		
		private function onBeforeInstall(e:UpdateEvent):void
		{
			if (_isInstallPostponed)
			{
				e.preventDefault();
				_isInstallPostponed = false;
			}
		}
		
		
		private function onCancelUpdate(e:Event):void
		{
			_updater.cancelUpdate();
			disposeDialog();
			finish();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------		
		
		private function setup():void
		{
			if (!_finishedSignal) _finishedSignal = new Signal();
			if (!_updater)
			{
				_updater = new ApplicationUpdater();
				_updater.addEventListener(UpdateEvent.INITIALIZED, onUpdaterInitialized);
				_updater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, onStatusUpdate);
				_updater.addEventListener(UpdateEvent.BEFORE_INSTALL, onBeforeInstall);
				_updater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onStatusUpdateError);
				_updater.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
				_updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, onDownloadComplete);
				_updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onDownloadError);
				_updater.addEventListener(ErrorEvent.ERROR, onUpdateError);
				_updater.updateURL = Registry.config.updateURL;
				_updater.delay = Registry.config.updateCheckInterval;
				_updater.initialize();
			}
		}
		
		
		private function createDialog(state:String):void
		{
			if (!_dialog)
			{
				_dialog = new UpdateDialog();
				_dialog.isFirstRun = _isFirstRun;
				_dialog.applicationName = _applicationName;
				_dialog.currentVersion = _currentVersion;
				_dialog.upateVersion = _updateVersion;
				_dialog.description = _description;
				_dialog.currentState = state;
				_dialog.addEventListener(UpdateDialog.EVENT_CHECK_UPDATE, onCheckUpdate);
				_dialog.addEventListener(UpdateDialog.EVENT_INSTALL_UPDATE, onInstallUpdate);
				_dialog.addEventListener(UpdateDialog.EVENT_CANCEL_UPDATE, onCancelUpdate);
				_dialog.addEventListener(UpdateDialog.EVENT_DOWNLOAD_UPDATE, onDownloadUpdate);
				_dialog.addEventListener(UpdateDialog.EVENT_INSTALL_LATER, onInstallLater);
				_dialog.open();
			}
		}
		
		
		private function disposeUpdater():void
		{
			if (_updater)
			{
				_updater.removeEventListener(UpdateEvent.INITIALIZED, onUpdaterInitialized);
				_updater.removeEventListener(StatusUpdateEvent.UPDATE_STATUS, onStatusUpdate);
				_updater.removeEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onStatusUpdateError);
				_updater.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
				_updater.removeEventListener(UpdateEvent.DOWNLOAD_COMPLETE, onDownloadComplete);
				_updater.removeEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onDownloadError);
				_updater.removeEventListener(UpdateEvent.BEFORE_INSTALL, onBeforeInstall);
				_updater.removeEventListener(ErrorEvent.ERROR, onUpdateError);
				_updater = null;
			}
			disposeDialog();
		}
		
		
		private function disposeDialog():void
		{
			if (_dialog)
			{
				_dialog.dispose();
				_dialog.removeEventListener(UpdateDialog.EVENT_CHECK_UPDATE, onCheckUpdate);
				_dialog.removeEventListener(UpdateDialog.EVENT_INSTALL_UPDATE, onInstallUpdate);
				_dialog.removeEventListener(UpdateDialog.EVENT_CANCEL_UPDATE, onCancelUpdate);
				_dialog.removeEventListener(UpdateDialog.EVENT_DOWNLOAD_UPDATE, onDownloadUpdate);
				_dialog.removeEventListener(UpdateDialog.EVENT_INSTALL_LATER, onInstallLater);
				_dialog.close();
				_dialog = null;
			}
			_isInstallPostponed = false;
		}
		
		
		/**
		 * @private
		 */
		private function finish():void
		{
			_finishedSignal.dispatch();
		}
	}
}
