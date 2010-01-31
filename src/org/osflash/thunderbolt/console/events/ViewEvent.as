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
package org.osflash.thunderbolt.console.events
{
	import flash.events.Event;	

	/**
	 * ViewEvent 
	 * @author Jens Krause [www.websector.de]
	 */
	public class ViewEvent extends Event 
	{	
		//
		// vars	
		public var newViewState: int;
		//
		// const	
		public static const CHANGE_VIEW_STATE: String = "changeViewState";
		public static const CHECK_FOR_UPDATE: String = "checkForUpdate";
				
		/**
		* constructor
		* @param type		Type definition of event
		* @param bubbles	Flag to bubble this event
		*/		
		public function ViewEvent(type : String)
		{
			super(type, true);
		}


		//--------------------------------------------------------------------------
		//
		//  to string
		//
		//--------------------------------------------------------------------------
		
		override public function toString() : String 
		{
		 	return "[Instance of:  org.osflash.thunderbolt.console.events.ViewEvent ]";

		}		
	}
}
