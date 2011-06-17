package base.core.update
{
	import base.AppInfo;
	import base.core.debug.Log;
	import base.data.Registry;

	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.update.ApplicationUpdater;
	import com.hexagonstar.update.events.StatusUpdateErrorEvent;
	import com.hexagonstar.update.events.StatusUpdateEvent;
	import com.hexagonstar.update.events.UpdateEvent;

	import flash.events.Event;
	
	
	public class UpdateManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _updater:ApplicationUpdater;
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
			_updater.applicationName = AppInfo.NAME;
			Log.debug("Initialized (current version: " + _updater.currentVersion + ").", this);
			if (_checkAfterInitialize) _updater.checkNow();
			else finish();
		}
		
		
		private function onStatusUpdate(e:StatusUpdateEvent):void
		{
			e.preventDefault();
			if (e.available)
			{
				/* Extract update description notes. */
				if (e.details && e.details.length == 1) _updater.description = e.details[0][1];
				else _updater.description = "";
				
				_updater.updateVersion = e.version;
				Log.debug("Update available: v" + e.version, this);
				_updater.showUpdateUI();
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
		
		
		private function onUpdaterFinished(e:Event):void
		{
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
				_updater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onStatusUpdateError);
				_updater.addEventListener(Event.COMPLETE, onUpdaterFinished);
				_updater.updateUIClass = UpdateDialog;
				_updater.updateURL = Registry.config.updateURL;
				_updater.delay = Registry.config.updateCheckInterval;
				_updater.initialize();
			}
		}
		
		
		private function disposeUpdater():void
		{
			if (_updater)
			{
				_updater.removeEventListener(UpdateEvent.INITIALIZED, onUpdaterInitialized);
				_updater.removeEventListener(StatusUpdateEvent.UPDATE_STATUS, onStatusUpdate);
				_updater.removeEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onStatusUpdateError);
				_updater.removeEventListener(Event.COMPLETE, onUpdaterFinished);
				_updater.dispose();
				_updater = null;
			}
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
