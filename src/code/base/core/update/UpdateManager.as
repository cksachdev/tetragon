package base.core.update
{
	import air.update.ApplicationUpdater;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusFileUpdateErrorEvent;
	import air.update.events.StatusFileUpdateEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;

	import base.core.debug.Log;
	import base.data.Registry;

	import flash.desktop.NativeApplication;
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
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "UpdateManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onBeforeInstall(e:UpdateEvent):void
		{
			if (_isInstallPostponed)
			{
				e.preventDefault();
				_isInstallPostponed = false;
			}
		}
		
		
		private function onUpdaterInitialized(e:UpdateEvent):void
		{
			_isFirstRun = _updater.isFirstRun;
			_applicationName = getApplicationName();
			_currentVersion = _updater.currentVersion;
			Log.debug("Initialized (current version: " + _currentVersion + ").", this);
			if (_checkAfterInitialize) _updater.checkNow();
		}
		
		
		private function onStatusUpdate(e:StatusUpdateEvent):void
		{
			e.preventDefault();
			if (e.available)
			{
				_description = getUpdateDescription(e.details);
				_updateVersion = e.version;
				Log.debug("Update available: v" + _updateVersion, this);
				createDialog(UpdateDialog.UPDATE_AVAILABLE);
			}
		}
		
		
		private function onStatusUpdateError(e:StatusUpdateErrorEvent):void
		{
			e.preventDefault();
			if (!_dialog) createDialog(UpdateDialog.UPDATE_ERROR);
			else _dialog.currentState = UpdateDialog.UPDATE_ERROR;
		}
		
		
		private function onStatusFileUpdate(e:StatusFileUpdateEvent):void
		{
			e.preventDefault();
			if (e.available)
			{
				_dialog.currentState = UpdateDialog.UPDATE_DOWNLOADING;
				_updater.downloadUpdate();
			}
			else
			{
				_dialog.currentState = UpdateDialog.UPDATE_ERROR;
			}
		}
		
		
		private function onStatusFileUpdateError(e:StatusFileUpdateErrorEvent):void
		{
			e.preventDefault();
			_dialog.currentState = UpdateDialog.UPDATE_ERROR;
		}
		
		
		private function onUpdateError(e:ErrorEvent):void
		{
			Log.error("Update Error: " + e.text, this);
			if (_dialog)
			{
				_dialog.errorText = e.text;
				_dialog.currentState = UpdateDialog.UPDATE_ERROR;
			}
		}


		private function onCheckUpdate(e:Event):void
		{
			_updater.checkNow();
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
		}
		
		
		private function onDownloadUpdate(e:Event):void
		{
			_updater.downloadUpdate();
		}
		
		
		private function onDownloadStarted(e:UpdateEvent):void
		{
			_dialog.currentState = UpdateDialog.UPDATE_DOWNLOADING;
		}
		
		
		private function onDownloadProgress(e:ProgressEvent):void
		{
			_dialog.currentState = UpdateDialog.UPDATE_DOWNLOADING;
			var percent:Number = (e.bytesLoaded / e.bytesTotal) * 100;
			_dialog.updateDownloadProgress(percent);
		}
		
		
		private function onDownloadComplete(e:UpdateEvent):void
		{
			e.preventDefault();
			_dialog.currentState = UpdateDialog.INSTALL_UPDATE;
		}
		
		
		private function onDownloadError(e:DownloadErrorEvent):void
		{
			e.preventDefault();
			_dialog.currentState = UpdateDialog.UPDATE_ERROR;
		}
		
		
		private function onCancelUpdate(e:Event):void
		{
			_updater.cancelUpdate();
			disposeDialog();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------		
		
		private function setup():void
		{
			if (!_updater)
			{
				_updater = new ApplicationUpdater();
				_updater.addEventListener(UpdateEvent.INITIALIZED, onUpdaterInitialized);
				_updater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, onStatusUpdate);
				_updater.addEventListener(UpdateEvent.BEFORE_INSTALL, onBeforeInstall);
				_updater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onStatusUpdateError);
				_updater.addEventListener(UpdateEvent.DOWNLOAD_START, onDownloadStarted);
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
		
		
		private function dispose():void
		{
			if (_updater)
			{
				_updater.removeEventListener(UpdateEvent.INITIALIZED, onUpdaterInitialized);
				_updater.removeEventListener(StatusUpdateEvent.UPDATE_STATUS, onStatusUpdate);
				_updater.removeEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onStatusUpdateError);
				_updater.removeEventListener(UpdateEvent.DOWNLOAD_START, onDownloadStarted);
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
		 * Getter method to get the version of the application
		 *
		 * @return String Version of application
		 */
		private function getApplicationVersion():String
		{
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			return appXML.ns::version;
		}
		
		
		/**
		 * Getter method to get the name of the application file
		 *
		 * @return String name of application
		 */
		private function getApplicationFileName():String
		{
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			return appXML.ns::filename;
		}
		
		
		/**
		 * Getter method to get the name of the application, this does not support multi-language.
		 * Based on a method from Adobes ApplicationUpdaterDialogs.mxml, which is part of Adobes
		 * AIR Updater Framework.
		 *
		 * @return String name of application
		 */
		private function getApplicationName():String
		{
			var applicationName:String;
			var xmlNS:Namespace = new Namespace("http://www.w3.org/XML/1998/namespace");
			var xml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = xml.namespace();
			
			// filename is mandatory
			var elem:XMLList = xml.ns::filename;
			
			// use name is if it exists in the application descriptor
			if (XMLList(xml.ns::name).length() != 0)
			{
				elem = XMLList(xml.ns::name);
			}
			
			// See if element contains simple content
			if (elem.hasSimpleContent())
			{
				applicationName = elem.toString();
			}
			
			return applicationName;
		}
		
		
		/**
		 * Helper method to get release notes, this does not support multi-language.
		 * Based on a method from Adobes ApplicationUpdaterDialogs.mxml, which is part of Adobes AIR Updater Framework
		 *
		 * @param detail Array of details
		 * @return String Release notes depending on locale chain
		 */
		protected function getUpdateDescription(details:Array):String
		{
			var text:String = "";
			if (details.length == 1)
			{
				text = details[0][1];
			}
			return text;
		}
	}
}
