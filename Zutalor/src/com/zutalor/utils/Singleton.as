package com.zutalor.utils
{
	import flash.utils.Dictionary;		

	/**
	 * The Singleton class is a helper class to enforce singletons in Guttershark
	 * and enables subclassing of singletons.
	 * 
	 * @example How singletons are implemented in guttershark:
	 * <listing>	
	 * public class Model
	 * {
	 *     private static var inst:Model;
	 *     public function Model()
	 *     {
	 *         Singleton.assertSingle(Model);
	 *     }
	 *     public static function gi():Model
	 *     {
	 *         if(!inst) inst=Singleton.gi(Model);
	 *         return inst;
	 *     }
	 * }
	 * </listing>
	 * 
	 * <p>The following example illustrates how you can extend Singletons, but it is
	 * not recommended; you should extend singletons through composition instead,
	 * which will always guarantee you don't run into any problems.</p>
	 * 
	 * @example Extending singletons:
	 * <listing>	
	 * //The base singleton class.
	 * package
	 * {
	 *     public class MySingleton
	 *     {
	 *         private static var inst:MySingleton;
	 *         public function MySingleton()
	 *         {
	 *             Singleton.assertSingle(MySingleton);
	 *         }
	 *         public static function gi():MySingleton
	 *         {
	 *             if(!inst) inst=Singleton.gi(MySingleton);
	 *             return inst;
	 *         }
	 *     }
	 * }
	 * 
	 * //the singleton extended from the base MySingleton class.
	 * package
	 * {
	 *     import MySingleton;
	 *     public class MyExtendedSingleton extends MySingleton
	 *     {
	 *         private static var inst:MyExtendedSingleton;
	 *         public function MyExtendedSingleton()
	 *         {
	 *             Singleton.assertSingle(MyExtendedSingleton);
	 *         }
	 *         public static function gi():MyExtendedSingleton()
	 *         {
	 *             if(!inst) inst=Singleton.gi(MyExtendedSingleton,MySingleton);
	 *             return inst;
	 *         }
	 *     }
	 * }
	 * 
	 * package
	 * {
	 *     public class Main extends Sprite
	 *     {
	 *         public function Main()
	 *         {
	 *             var mes:MyExtendedSingleton=MyExtendedSingleton.gi();
	 *             //either of the following will fail.
	 *             var ms:MySingleton=new MySingleton();
	 *             var mss:MySingleton=MySingleton.gi();
	 *         }
	 *     }
	 * }
	 * </listing>
	 * 
	 * <script src="http://mint.codeendeavor.com/?js" type="text/javascript"></script>
	 */
	final public class Singleton
	{
		
		/**
		 * Keeps track of the instances available.
		 */
		private static var insts:Dictionary;
		
		/**
		 * Get an instance of a class, and cancel any parent classes.
		 * 
		 * @param clazz The class of the instance you're after.
		 * @param cancelParentClasses An array of Classes to cancel, so they cannot be instantiated again.
		 * This is specifically for when you extend a singleton, you need to make sure you pass all of it's
		 * super classes.
		 */
		public static function gi(clazz:Class,...cancelParentClasses:Array):*
		{
			var inst:*;
			if(!insts) insts=new Dictionary();
			if(insts[clazz] && insts[clazz] != -1) inst=insts[clazz];
			if(!inst)
			{
				inst=new clazz();
				insts[clazz]=inst;
			}
			if(cancelParentClasses) for each(var cl:Class in cancelParentClasses){insts[cl]=-1;}
			return inst;
		}
		
		/**
		 * Assert that there is only one instance of a class.
		 * 
		 * @param clazz The Class to assert as being the only instance.
		 */
		public static function assertSingle(clazz:Class):void
		{
			if(!insts) insts=new Dictionary();
			if(insts[clazz]) throw new Error("Error creating class, {"+clazz+"}. It's a singleton and cannot be instantiated more than once.");
		}
	}
}