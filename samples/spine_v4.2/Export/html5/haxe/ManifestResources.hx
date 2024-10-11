package;

import haxe.io.Bytes;
import lime.utils.AssetBundle;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

#if disable_preloader_assets
@:dox(hide) class ManifestResources {
	public static var preloadLibraries:Array<Dynamic>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;

	public static function init (config:Dynamic):Void {
		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();
	}
}
#else
@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

			if(!StringTools.endsWith (rootPath, "/")) {

				rootPath += "/";

			}

		}

		if (rootPath == null) {

			#if (ios || tvos || emscripten)
			rootPath = "assets/";
			#elseif android
			rootPath = "";
			#elseif console
			rootPath = lime.system.System.applicationDirectory;
			#else
			rootPath = "./";
			#end

		}

		#if (openfl && !flash && !display)
		
		#end

		var data, manifest, library, bundle;

		#if (zygame && un_use_openfl_assets)

		data = '{}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("null", library);

		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("null");

		#elseif kha

		null
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("null", library);

		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("null");

		#else

		data = '{"name":null,"assets":"aoy4:pathy18:assets%2FORole.pngy4:sizei6217y4:typey5:IMAGEy2:idR1y7:preloadtgoR0y26:assets%2Fsnowglobe-pro.pngR2i2291646R3R4R5R7R6tgoR0y20:assets%2FORole.atlasR2i404R3y4:TEXTR5R8R6tgoR0y19:assets%2FORole.jsonR2i7853R3R9R5R10R6tgoR0y27:assets%2Fsnowglobe-pro.jsonR2i89796R3R9R5R11R6tgoR0y28:assets%2Fsnowglobe-pro.atlasR2i2963R3R9R5R12R6tgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		

		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

		#end

	}


}


#if kha

null

#else

#if !display
#if flash

@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_orole_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_snowglobe_pro_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_orole_atlas extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_orole_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_snowglobe_pro_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_snowglobe_pro_atlas extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:image("Assets/ORole.png") @:noCompletion #if display private #end class __ASSET__assets_orole_png extends lime.graphics.Image {}
@:keep @:image("Assets/snowglobe-pro.png") @:noCompletion #if display private #end class __ASSET__assets_snowglobe_pro_png extends lime.graphics.Image {}
@:keep @:file("Assets/ORole.atlas") @:noCompletion #if display private #end class __ASSET__assets_orole_atlas extends haxe.io.Bytes {}
@:keep @:file("Assets/ORole.json") @:noCompletion #if display private #end class __ASSET__assets_orole_json extends haxe.io.Bytes {}
@:keep @:file("Assets/snowglobe-pro.json") @:noCompletion #if display private #end class __ASSET__assets_snowglobe_pro_json extends haxe.io.Bytes {}
@:keep @:file("Assets/snowglobe-pro.atlas") @:noCompletion #if display private #end class __ASSET__assets_snowglobe_pro_atlas extends haxe.io.Bytes {}
@:keep @:file("") @:noCompletion #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else



#end

#if (openfl && !flash)

#if html5

#else

#end

#end
#end

#end

#end