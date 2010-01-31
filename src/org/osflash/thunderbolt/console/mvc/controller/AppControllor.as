/*
* Logging Flex, AIR and Flash applications using ThunderBolt AS3 Console
* 
* @author	Jens Krause [www.websector.de]
* @see		http://www.websector.de/blog/category/thunderbolt/
* @see		http://code.google.com/p/flash-thunderbolt/
* 
* Source code based on the Mozilla Public License 1.1. Feel free to use it!
*
*/
package org.osflash.thunderbolt.console.mvc.controller
{

	import air.update.ApplicationUpdaterUI;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.osflash.thunderbolt.console.events.ConfigEvent;
	import org.osflash.thunderbolt.console.events.ConsoleEvent;
	import org.osflash.thunderbolt.console.events.ViewEvent;
	import org.osflash.thunderbolt.console.mvc.model.AppModel;
	import org.osflash.thunderbolt.console.mvc.model.ConsoleConstants;

	/**
	* AppControllor
    * @author Jens Krause [www.websector.de]
	*/
	public class AppControllor extends UIComponent
	{
		
		//
		// vars
		private var isCheckForUpdateVisible: Boolean = false;
		//
		// const	
		
		//
		// instances
		private var _appModel: AppModel;		
		private var file: File; 
		private var fileStream: FileStream; 
		private var logTimer: Timer;
		
		private var appUpdater: ApplicationUpdaterUI = new ApplicationUpdaterUI(); 
			
		/**
		* constructor
		*
		*/	
		public function AppControllor()
		{
			super();
			
			_appModel = AppModel.getInstance();
			 _appModel.viewState = AppModel.VIEW_ADD_FILE;		

			logTimer = new Timer(500);
			logTimer.addEventListener(TimerEvent.TIMER, openLogFile);
			
			initUpdater();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			
		}
		
		private function initFile():void
		{
			file = new File();
			file.nativePath = _appModel.logPath;		
		}	
		
	
		/**
		* Callback handler 
		* @param event 	FlexEvent	Dispatched after the app is created
		* 
		*/
		private function creationCompleteHandler(event: FlexEvent):void
		{
			this.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			
			systemManager.addEventListener(ConfigEvent.LOG_PATH_CHANGED, logPathChangedHandler);

			systemManager.addEventListener(ViewEvent.CHANGE_VIEW_STATE, changeViewStateHandler);
			
			systemManager.addEventListener(ConsoleEvent.START_LOG_WATCHING, startLogWatching);
			systemManager.addEventListener(ConsoleEvent.STOP_LOG_WATCHING, stopLogWatching);
			systemManager.addEventListener(ConsoleEvent.CLEAR_LOG, clearLogHandler);
						
			systemManager.addEventListener( ViewEvent.CHECK_FOR_UPDATE, checkForUpdateHandler );
			
			//
			// start view state
 			if (_appModel.logPath != null && _appModel.logPath.length)
				_appModel.viewState = AppModel.VIEW_CONSOLE;
			else
			 	_appModel.viewState = AppModel.VIEW_ADD_FILE; 
			 	
			 	
			 
	
		}	

		//--------------------------------------------------------------------------
		//
		// callbacks
		//
		//--------------------------------------------------------------------------
		
		private function logPathChangedHandler(event: ConfigEvent):void
		{			
			_appModel.logPath = event.logPath;
		}		
		
		private function changeViewStateHandler(event: ViewEvent):void
		{
			var newViewState: int = event.newViewState;
			
			if(newViewState == AppModel.VIEW_ADD_FILE)
			{
				stopLogWatching();
				clearLogHandler();
			
			}
				
			
			_appModel.viewState = newViewState;
		}

		//--------------------------------------------------------------------------
		//
		// update
		//
		//--------------------------------------------------------------------------

		private function initUpdater():void
		{
			
			appUpdater.configurationFile = new File( ConsoleConstants.UPDATE_CONFIG_PATH );
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, updaterInitializedHandler );
			appUpdater.addEventListener( ErrorEvent.ERROR, updaterErrorHandler );
			appUpdater.addEventListener( StatusUpdateEvent.UPDATE_STATUS, updaterStatusHandler );
			
			appUpdater.initialize();

		}
		
		private function updaterStatusHandler( event: StatusUpdateEvent ):void
		{
			//
			// Puuh... F**cking bug using Flex 3.5 + UpdaterUI + Adobe AIR 1.5.3
			// Big thanks to Richard Legget for his workaround
			// @see: https://bugs.adobe.com/jira/browse/SDK-24766
			try
			{
				var loader:Object = NativeApplication.nativeApplication.openedWindows[1].stage.getChildAt(0);
				loader.content.application.visible = true;
			}
			catch(e:Error) {} 
		}

		private function checkForUpdateHandler( event: ViewEvent ):void
		{
			//
			// after automatic update check restore isCheckForUpdateVisible
			if ( !isCheckForUpdateVisible )
			{
				isCheckForUpdateVisible = true;
				appUpdater.isCheckForUpdateVisible = true;
			}
			
			appUpdater.checkNow();
				
			orderToBackCommand();
		}
		
		private function updaterInitializedHandler( event: UpdateEvent ):void
		{
			//
			// start check for auto update
			appUpdater.checkNow();

			orderToBackCommand();
		}
		
		private function updaterErrorHandler( event: ErrorEvent ):void
		{
			Alert.show( event.toString() );
		}
		
		private function orderToBackCommand():void
		{
			NativeWindow(this.stage.nativeWindow).orderToBack();
		}
		
		//--------------------------------------------------------------------------
		//
		// timer
		//
		//--------------------------------------------------------------------------
				
		private function startLogWatching(event: ConsoleEvent = null):void
		{
//			Logger.info("startLogWatching ");
			
			if (!_appModel.isWatching)
			{
				logTimer.start();				
				openLogFile();				
				_appModel.isWatching = true;			
			}

		}

		private function stopLogWatching(event: ConsoleEvent = null):void
		{
//			Logger.info("stopLogWatching ");

			if (_appModel.isWatching)
			{
				if ( logTimer != null && logTimer.running ) 
					logTimer.stop();
				
				_appModel.isWatching = false;			
			}
			
			

		}
					
		private function openLogFile(event: Event = null):void
		{
			// For "inHouse" testing only ;)
			// just some log outputs
 		
			
			
/* 			Logger.includeTime = false;
			trace ("http://i.ligatus.de/ads/1687_90x75.jpg and http://i.ligatus.de/ads/1687_90x75.jpg AND ftp://i.ligatus.de/ads/1687_90x75.jpg"); 
			
			Logger.debug("-- DEBUG -- fileReadHandler"); 
			
   			Logger.console = true;
  			Logger.warn("-- WARN -- openLogFile");
			Logger.error("-- ERROR -- fileReadHandler");	
			var array: Array = [1, "hello", 3];
			var array2: Array = [1, "hello array2", array];
			var array3: Array = [array2, "hello array3", 33];
			Logger.debug("-- DEBUG -- fileReadHandler", array3);	
			
			Logger.debug("-- DEBUG -- fileReadHandler");
			Logger.info("-- INFO -- fileReadHandler", array2);	
			
			
			var array: Array = [1, "hello", 3];
			var array2: Array = [array, 1, "here", "are some ", "strings"];
			var array3: Array = [array2, "array2", 33];
			Logger.warn("-- WARN -- fileReadHandler", array3);	  
			var obj: Object = {testNumber: 11, testNumber22: 22.34, testString: "yuhuu" };
			Logger.info("obj", obj);  */  
			
			
								
			if (fileStream != null)
			{			    
			   fileStream.close();
			   fileStream = null;
			}

			
			file = new File();
			file.nativePath = _appModel.logPath;
			
			fileStream = new FileStream();

			fileStream.open(file, FileMode.READ);
			readLogFile();

									
		}
		
		private function readLogFile():void
		{
			
			var str:String = fileStream.readUTFBytes( fileStream.bytesAvailable );					
			var lines:Array = str.split(File.lineEnding);
			
			//
			// local log data
			var arr_logData: Array = new Array();
			var arr_logDebugData: Array = new Array();
			var arr_logInfoData: Array = new Array();
			var arr_logWarnData: Array = new Array();	
			var arr_logErrorData: Array = new Array();	

											
			// ignore last line ending
			var max: int = lines.length - 1;
			var i: int = _appModel.lastLine;
				
			for (i; i < max; i++)
			{
				var line: String = clearLog( lines[i] );
				var logObject: Object = {};
				
				//
				// log level
				// Note: Don't be confused about changing a log level to a debug level. 
				// Because Firebug has 4 log levels only (no debug level)
				if ( line.search( new RegExp( ConsoleConstants.LOG ) ) == 0 )
				{
					var logPrefix: String = '<span class="debug">debug</span>';
					// check the begin of a debug group
					if ( line.search( new RegExp( ConsoleConstants.LOG_GROUP_START + ConsoleConstants.SPACE ) ) == 0)
					{		
						// replace "log.group" to "debug"		
						line = line.replace( 	new RegExp( ConsoleConstants.LOG_GROUP_START ), 
												ConsoleConstants.DEBUG);
						// replace debug to html						
						line = line.replace( new RegExp( ConsoleConstants.DEBUG ), 
											logPrefix);
						
						logObject = {action: ConsoleConstants.ACTION_GROUP, msg: line};
									
					} // check the end of a debug group
					else if( line.search( new RegExp( ConsoleConstants.LOG_GROUP_END + ConsoleConstants.SPACE ) ) == 0) 
					{
						logObject = {action: ConsoleConstants.ACTION_GROUP_END };						
					} // store debug data
					else
					{
						line = line.replace( new RegExp( ConsoleConstants.LOG ), logPrefix);
						
						logObject = {action: ConsoleConstants.ACTION_NONE, msg: line};
					}	
					
					arr_logDebugData.push( logObject );
					arr_logData.push( logObject );		
					
				}				
				//
				// debug level				
				else if ( line.search( new RegExp( ConsoleConstants.DEBUG ) ) == 0)
				{
					var debugPrefix: String = '<span class="debug">debug</span>';
					// check the begin of an info group
					if ( line.search( new RegExp( "debug.group" ) ) == 0)
					{	
						// remove ".group"					
						line = line.replace( new RegExp( ".group" ), "");
						// replace "info" to html
						line = line.replace( new RegExp( "debug" ), debugPrefix);						
						logObject = {action: "group", msg: line};
			
					} // check the end of a debug group
					else if( line.search( new RegExp("debug.groupEnd ") ) == 0) 
					{
						logObject = {action: "groupEnd"};						
					} // store info data
					else
					{
						line = line.replace( new RegExp("debug"), debugPrefix);						
						logObject = {action: "none", msg: line};						
					}
					arr_logDebugData.push( logObject );
					arr_logData.push( logObject );				
				}
				//
				// info level				
				else if ( line.search( new RegExp( ConsoleConstants.INFO ) ) == 0)
				{
					var infoPrefix: String = '<span class="info">info</span>';

					// check the begin of an info group
					if ( line.search( new RegExp( ConsoleConstants.INFO_GROUP_START + ConsoleConstants.SPACE ) ) == 0)
					{	
						// remove ".group"					
						line = line.replace( new RegExp(".group"), "");
						// replace "info" to html
						line = line.replace( new RegExp("info"), infoPrefix);						
						logObject = {action: "group", msg: line};
			
					} // check the end of an info group
					else if( line.search( new RegExp("info.groupEnd ") ) == 0) 
					{
						logObject = {action: "groupEnd"};						
					} // store info data
					else
					{
						line = line.replace( new RegExp("info"), infoPrefix);						
						logObject = {action: "none", msg: line};						
					}
					arr_logInfoData.push( logObject );
					arr_logData.push( logObject );				
				}
				//
				// warn level				
				else if ( line.search( new RegExp("warn") ) == 0)
				{
					var warnPrefix: String = '<span class="warn">warn</span>';
					// check the begin of a warn group
					if ( line.search( new RegExp("warn.group ") ) == 0)
					{						
						line = line.replace( new RegExp(".group"), "");
						line = line.replace( new RegExp("warn"), warnPrefix);
						
						logObject = {action: "group", msg: line};
			
					} // check the end of a warn group
					else if( line.search( new RegExp("warn.groupEnd ") ) == 0) 
					{
						logObject = {action: "groupEnd"};
					} // store warn data
					else
					{
						line = line.replace( new RegExp("warn"), warnPrefix);
						
						logObject = {action: "none", msg: line};
					}
					
					arr_logWarnData.push( logObject );
					arr_logData.push( logObject );				
				}
				//
				// error level				
				else if ( line.search( new RegExp("error") ) == 0)
				{
					var errorPrefix: String = '<span class="error">error</span>';
					// check the begin of an error group
					if ( line.search( new RegExp("error.group ") ) == 0)
					{						
						line = line.replace( new RegExp(".group"), "");
						line = line.replace( new RegExp("error"), errorPrefix);

						logObject = {action: "group", msg: line};			
					} // check the end of an error group
					else if( line.search( new RegExp("error.groupEnd ") ) == 0) 
					{
						logObject = {action: "groupEnd"};	
					} // store error data
					else
					{
						line = line.replace( new RegExp("error"), errorPrefix);						
						logObject = {action: "none", msg: line};
					}
					arr_logErrorData.push( logObject );
					arr_logData.push( logObject );				
				}
				else
				{
					if ( !_appModel.hideTraceLogs )
					{
						line = '<span class="log">trace</span> ' + line;
						logObject = {action: "none", msg: line};
						arr_logData.push( logObject );					
					}
				}

				
			}
			
			//
			// update model if its necessary
			if (arr_logData.length) 		_appModel.logData = arr_logData;			
			if (arr_logDebugData.length) 	_appModel.logDebugData = arr_logDebugData;
			if (arr_logInfoData.length)		_appModel.logInfoData = arr_logInfoData;		
			if (arr_logWarnData.length) 	_appModel.logWarnData = arr_logWarnData;
			if (arr_logErrorData.length) 	_appModel.logErrorData = arr_logErrorData;
			
			// store last line for lazy data parsing 
			 _appModel.lastLine = max;
	       
		}
		

		private function clearLogHandler(event: ConsoleEvent = null):void
		{
			var resume: Boolean = _appModel.isWatching;
			
			stopLogWatching();
						
			var newPage: String = _appModel.htmlPage
			_appModel.htmlPage = "";
			_appModel.htmlPage = newPage;	
			
			if (resume)
				callLater( startLogWatching );
		
		}

		private function traceLoggingHandler(event: ConsoleEvent = null):void
		{
			
			_appModel.hideTraceLogs = event.hideTraceLogs;	
		
		}

		private function readIOErrorHandler(event: IOErrorEvent): void
		{
			
		}
		
		
		/**
		 * Helper method to clear up the logData to avoid showing or playing real content within HTML component 
		 * @see: http://code.google.com/p/flash-thunderbolt/issues/detail?id=6
		 * 
		 * @param value 	String of logged data
		 * @return 			String of a "cleared" log
		 * 
		 */		
		private function clearLog(value: String): String
		{
			var logData: String = value;
			
			// just wrapping a <span> tag to set a "invalid" url
			logData = logData.replace( new RegExp("http://", "g"), "<span>http://</span>");
			logData = logData.replace( new RegExp("ftp://", "g"), "<span>ftp://</span>");
			
			return logData;
		}	

	
	
		//--------------------------------------------------------------------------
		//
		// toString
		//
		//--------------------------------------------------------------------------
		
		override public function toString() : String 
	    {
		    return "[Instance of:  org.osflash.thunderbolt.console.mvc.controller.AppController]";
	    }		
	
	}
}