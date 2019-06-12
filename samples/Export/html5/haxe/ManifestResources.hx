package;


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
	
	
	public static function init (config:Dynamic):Void {
		
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
		
		#if kha
		
		null
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("null", library);
		
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("null");
		
		#else
		
		data = '{"name":null,"assets":"aoy4:pathy23:assets%2FsxkCenter.jsony4:sizei142712y4:typey4:TEXTy2:idR1y7:preloadtgoR0y25:assets%2Fspineboy-pro.pngR2i1967241R3y5:IMAGER5R7R6tgoR0y24:assets%2FsxkCenter.atlasR2i3689R3R4R5R9R6tgoR0y26:assets%2Fspineboy-pro.jsonR2i181796R3R4R5R10R6tgoR0y27:assets%2Fspineboy-pro.atlasR2i4436R3R4R5R11R6tgoR0y22:assets%2FsxkCenter.pngR2i66183R3R8R5R12R6tgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
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

@:keep @:bind #if display private #end class __ASSET__assets_sxkcenter_json extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_spineboy_pro_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_sxkcenter_atlas extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_spineboy_pro_json extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_spineboy_pro_atlas extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_sxkcenter_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:file("Assets/sxkCenter.json") #if display private #end class __ASSET__assets_sxkcenter_json extends haxe.io.Bytes {}
@:keep @:image("Assets/spineboy-pro.png") #if display private #end class __ASSET__assets_spineboy_pro_png extends lime.graphics.Image {}
@:keep @:file("Assets/sxkCenter.atlas") #if display private #end class __ASSET__assets_sxkcenter_atlas extends haxe.io.Bytes {}
@:keep @:file("Assets/spineboy-pro.json") #if display private #end class __ASSET__assets_spineboy_pro_json extends haxe.io.Bytes {}
@:keep @:file("Assets/spineboy-pro.atlas") #if display private #end class __ASSET__assets_spineboy_pro_atlas extends haxe.io.Bytes {}
@:keep @:image("Assets/sxkCenter.png") #if display private #end class __ASSET__assets_sxkcenter_png extends lime.graphics.Image {}
@:keep @:file("") #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else



#end

#if (openfl && !flash)

#if html5

#else

#end

#end
#end

#end