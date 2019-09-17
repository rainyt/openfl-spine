package;


import haxe.io.Bytes;
import lime.utils.AssetBundle;
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
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

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

		Assets.defaultRootPath = rootPath;

		#if (openfl && !flash && !display)
		
		#end

		var data, manifest, library, bundle;

		#if kha

		null
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("null", library);

		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("null");

		#else

		data = '{"name":null,"assets":"aoy4:pathy19:assets%2Fwild.atlasy4:sizei4946y4:typey4:TEXTy2:idR1y7:preloadtgoR0y26:assets%2Fsesame_shiba.jsonR2i15909R3R4R5R7R6tgoR0y19:assets%2Fbonus.jsonR2i47792R3R4R5R8R6tgoR0y23:assets%2Fred_shiba.jsonR2i13930R3R4R5R9R6tgoR0y23:assets%2FsxkCenter.jsonR2i142712R3R4R5R10R6tgoR0y18:assets%2Fbonus.pngR2i327223R3y5:IMAGER5R11R6tgoR0y25:assets%2Fspineboy-pro.pngR2i1967241R3R12R5R13R6tgoR0y24:assets%2Fred_shiba.atlasR2i3201R3R4R5R14R6tgoR0y22:assets%2Fred_shiba.pngR2i98179R3R12R5R15R6tgoR0y25:assets%2Fsesame_shiba.pngR2i96705R3R12R5R16R6tgoR0y24:assets%2FsxkCenter.atlasR2i3689R3R4R5R17R6tgoR0y18:assets%2Fwild.jsonR2i28551R3R4R5R18R6tgoR0y17:assets%2Fwild.pngR2i914325R3R12R5R19R6tgoR0y27:assets%2Fsesame_shiba.atlasR2i3302R3R4R5R20R6tgoR0y26:assets%2Fspineboy-pro.jsonR2i181796R3R4R5R21R6tgoR0y20:assets%2Fbonus.atlasR2i3844R3R4R5R22R6tgoR0y27:assets%2Fspineboy-pro.atlasR2i4436R3R4R5R23R6tgoR0y22:assets%2FsxkCenter.pngR2i66183R3R12R5R24R6tgoR0y29:assets%2Foff%2Fred_shiba.jsonR2i13930R3R4R5R25R6tgoR0y30:assets%2Foff%2Fred_shiba.atlasR2i2975R3R4R5R26R6tgoR0y28:assets%2Foff%2Fred_shiba.pngR2i628290R3R12R5R27R6tgh","rootPath":"../","version":2,"libraryArgs":[],"libraryType":null}';
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

@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_wild_atlas extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sesame_shiba_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_bonus_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_red_shiba_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sxkcenter_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_bonus_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_spineboy_pro_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_red_shiba_atlas extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_red_shiba_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sesame_shiba_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sxkcenter_atlas extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_wild_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_wild_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sesame_shiba_atlas extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_spineboy_pro_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_bonus_atlas extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_spineboy_pro_atlas extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sxkcenter_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_off_red_shiba_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_off_red_shiba_atlas extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_off_red_shiba_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:file("Assets/wild.atlas") @:noCompletion #if display private #end class __ASSET__assets_wild_atlas extends haxe.io.Bytes {}
@:keep @:file("Assets/sesame_shiba.json") @:noCompletion #if display private #end class __ASSET__assets_sesame_shiba_json extends haxe.io.Bytes {}
@:keep @:file("Assets/bonus.json") @:noCompletion #if display private #end class __ASSET__assets_bonus_json extends haxe.io.Bytes {}
@:keep @:file("Assets/red_shiba.json") @:noCompletion #if display private #end class __ASSET__assets_red_shiba_json extends haxe.io.Bytes {}
@:keep @:file("Assets/sxkCenter.json") @:noCompletion #if display private #end class __ASSET__assets_sxkcenter_json extends haxe.io.Bytes {}
@:keep @:image("Assets/bonus.png") @:noCompletion #if display private #end class __ASSET__assets_bonus_png extends lime.graphics.Image {}
@:keep @:image("Assets/spineboy-pro.png") @:noCompletion #if display private #end class __ASSET__assets_spineboy_pro_png extends lime.graphics.Image {}
@:keep @:file("Assets/red_shiba.atlas") @:noCompletion #if display private #end class __ASSET__assets_red_shiba_atlas extends haxe.io.Bytes {}
@:keep @:image("Assets/red_shiba.png") @:noCompletion #if display private #end class __ASSET__assets_red_shiba_png extends lime.graphics.Image {}
@:keep @:image("Assets/sesame_shiba.png") @:noCompletion #if display private #end class __ASSET__assets_sesame_shiba_png extends lime.graphics.Image {}
@:keep @:file("Assets/sxkCenter.atlas") @:noCompletion #if display private #end class __ASSET__assets_sxkcenter_atlas extends haxe.io.Bytes {}
@:keep @:file("Assets/wild.json") @:noCompletion #if display private #end class __ASSET__assets_wild_json extends haxe.io.Bytes {}
@:keep @:image("Assets/wild.png") @:noCompletion #if display private #end class __ASSET__assets_wild_png extends lime.graphics.Image {}
@:keep @:file("Assets/sesame_shiba.atlas") @:noCompletion #if display private #end class __ASSET__assets_sesame_shiba_atlas extends haxe.io.Bytes {}
@:keep @:file("Assets/spineboy-pro.json") @:noCompletion #if display private #end class __ASSET__assets_spineboy_pro_json extends haxe.io.Bytes {}
@:keep @:file("Assets/bonus.atlas") @:noCompletion #if display private #end class __ASSET__assets_bonus_atlas extends haxe.io.Bytes {}
@:keep @:file("Assets/spineboy-pro.atlas") @:noCompletion #if display private #end class __ASSET__assets_spineboy_pro_atlas extends haxe.io.Bytes {}
@:keep @:image("Assets/sxkCenter.png") @:noCompletion #if display private #end class __ASSET__assets_sxkcenter_png extends lime.graphics.Image {}
@:keep @:file("Assets/off/red_shiba.json") @:noCompletion #if display private #end class __ASSET__assets_off_red_shiba_json extends haxe.io.Bytes {}
@:keep @:file("Assets/off/red_shiba.atlas") @:noCompletion #if display private #end class __ASSET__assets_off_red_shiba_atlas extends haxe.io.Bytes {}
@:keep @:image("Assets/off/red_shiba.png") @:noCompletion #if display private #end class __ASSET__assets_off_red_shiba_png extends lime.graphics.Image {}
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
