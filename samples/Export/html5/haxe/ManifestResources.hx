package;


import lime.app.Config;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {
	
	
	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	
	
	public static function init (config:Config):Void {
		
		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();
		
		var rootPath = null;
		
		if (config != null && Reflect.hasField (config, "rootPath")) {
			
			rootPath = Reflect.field (config, "rootPath");
			
		}
		
		if (rootPath == null) {
			
			#if (ios || tvos || emscripten)
			rootPath = "assets/";
			#elseif (sys && windows && !cs)
			rootPath = FileSystem.absolutePath (haxe.io.Path.directory (#if (haxe_ver >= 3.3) Sys.programPath () #else Sys.executablePath () #end)) + "/";
			#else
			rootPath = "";
			#end
			
		}
		
		Assets.defaultRootPath = rootPath;
		
		#if (openfl && !flash && !display)
		
		#end
		
		var data, manifest, library;
		
		data = '{"name":null,"assets":"aoy4:pathy25:assets%2Fspineboy-pro.pngy4:sizei1967241y4:typey5:IMAGEy2:idR1y7:preloadtgoR0y26:assets%2Fspineboy-pro.jsonR2i181796R3y4:TEXTR5R7R6tgoR0y27:assets%2Fspineboy-pro.atlasR2i4436R3R8R5R9R6tgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		
		
		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		
		
	}
	
	
}


#if !display
#if flash

@:keep @:bind #if display private #end class __ASSET__assets_spineboy_pro_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_spineboy_pro_json extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_spineboy_pro_atlas extends null { }
@:keep @:bind #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:image("Assets/spineboy-pro.png") #if display private #end class __ASSET__assets_spineboy_pro_png extends lime.graphics.Image {}
@:keep @:file("Assets/spineboy-pro.json") #if display private #end class __ASSET__assets_spineboy_pro_json extends haxe.io.Bytes {}
@:keep @:file("Assets/spineboy-pro.atlas") #if display private #end class __ASSET__assets_spineboy_pro_atlas extends haxe.io.Bytes {}
@:keep @:file("") #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else



#end

#if (openfl && !flash)



#end
#end