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
package org.osflash.thunderbolt.console.mvc.model
{
	
	public class ConsoleConstants
	{	
		
		public static const UPDATE_CONFIG_PATH: String = "app:/assets/xml/update-config.xml";
		
		public static const ACTION_GROUP: String = "group";
		public static const ACTION_GROUP_END: String = "groupEnd";
		public static const ACTION_NONE: String = "none";
		
		//
		// short cuts which will traced by ThunderBolt's Logger logging within flashlog.txt
		public static const INFO: String = "info";		
		public static const INFO_GROUP_START: String = "info.group";
		public static const INFO_GROUP_END: String = "info.groupEnd";

		public static const WARN: String = "warn";		
		public static const WARN_GROUP_START: String = "warn.group";
		public static const WARN_GROUP_END: String = "warn.groupEnd";

		public static const ERROR: String = "error";		
		public static const ERROR_GROUP_START: String = "error.group";
		public static const ERROR_GROUP_END: String = "error.groupEnd";

		public static const DEBUG: String = "debug";		
		public static const DEBUG_GROUP_START: String = "debug.group";
		public static const DEBUG_GROUP_END: String = "debug.groupEnd";
		
		public static const LOG: String = "log";		
		public static const LOG_GROUP_START: String = "log.group";
		public static const LOG_GROUP_END: String = "log.groupEnd";

		public static const GROUP_START: String = ".group";
		public static const SPACE: String = " ";
		
		
		
						
	}
}