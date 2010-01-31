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
package skins
{
	[Bindable]
	final public class AssetLib
	{

		[Embed(source="../../assets/png/logo.png")]
		public static var logo:Class;

		[Embed(source="../../assets/png/dragHere.png")]
		public static var dragHere:Class;

		[Embed(source="../../assets/png/icon_openOptions.png")]
		public static var icon_openOptions:Class;

		[Embed(source="../../assets/png/icon_closeOptions.png")]
		public static var icon_closeOptions:Class;
                           
	}
}