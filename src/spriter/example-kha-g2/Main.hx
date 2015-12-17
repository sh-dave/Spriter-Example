package;

import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.util.SpriterUtil;

typedef Part = {
	var image : kha.Image;

	var x : Float;
	var y : Float;
	var angle : Float;
	var originX : Float;
	var originY : Float;
	var scaleX : Float;
	var scaleY : Float;
	var alpha : Float;
}

typedef Point = {
	var x : Float;
	var y : Float;
}

class C {
	public static var bufferSize = 2048;
}

class SpriterKhaG2Library extends spriter.library.AbstractLibrary {
	public function new( basepath : String ) {
		super(basepath);

		backbuffer = kha.Image.createRenderTarget(C.bufferSize, C.bufferSize);
	}

//	public function getFile(name:String):Dynamic
//	public function clear():Void
//	public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
//	public function render():Void
//	public function destroy():Void

	override public function clear() {
		parts.splice(0, parts.length);
	}

	function getPivotsRelativeToCenter( info : SpatialInfo, pivots : PivotInfo, width : Float, height : Float ) : Point {
		var x : Float = (pivots.pivotX - 0.5) * width * info.scaleX;
		var y : Float = (0.5 - pivots.pivotY) * height * info.scaleY;
		return { x : x, y : y };
	}

	override public function addGraphic( name : String, info : SpatialInfo, pivots : PivotInfo ) {
		var graphic = '${_basePath}/${name}';
		var fixed = KhaTools.fixAssetId(graphic);

		if (!imageCache.exists(fixed)) {
			imageCache.set(fixed, Reflect.field(kha.Assets.images, fixed));

			//kha.Assets.loadImage(fixed, function( image ) {
				//imageCache.set(fixed, image);
			//});
		}

		var image = imageCache.get(fixed);
		var spatialResult : SpatialInfo = compute(info, pivots, image.width, image.height);

		var relativePivots = getPivotsRelativeToCenter(info, pivots, image.width, image.height);

		parts.push({
			x : spatialResult.x,
			y : spatialResult.y,
			angle : SpriterUtil.toRadians(SpriterUtil.fixRotation(spatialResult.angle)),
			//angle : SpriterUtil.toRadians(spatialResult.angle),
			//angle : 0,
			//originX : image.width / 2,
			//originY : image.height / 2,
			originX : 0,
			originY : 0,
			//originX : relativePivots.x,
			//originY : relativePivots.y,
			image : image,
			scaleX : spatialResult.scaleX,
			scaleY : spatialResult.scaleY,
			alpha : spatialResult.a,
		});
	}

	public function renderimpl( framebuffer : kha.Framebuffer ) {
		var g = backbuffer.g2;

		g.begin();
			for (part in parts) {
				g.pushRotation(part.angle, part.x + part.originX, part.y + part.originY);
				g.pushOpacity(part.alpha);
				g.drawImage(part.image, part.x, part.y);
				//g.drawScaledImage(part.image, part.x, part.y, part.scaleX, part.scaleY);
				g.popOpacity();
				g.popTransformation();
			}
		g.end();

		framebuffer.g2.begin();
			kha.Scaler.scale(backbuffer, framebuffer, kha.System.screenRotation);
		framebuffer.g2.end();
	}

	var backbuffer : kha.Image;

	var imageCache = new Map<String, kha.Image>();
	var parts = new Array<Part>();
}

class KhaG2Example {
	var engine : spriter.engine.SpriterEngine;
	var scml : spriter.definitions.ScmlObject;

	public function new() {
		kha.Assets.loadEverything(assets_loadedHandler);
	}

	function assets_loadedHandler() {
		setupScene(scene_setupCompletedHandler);
	}

	function setupScene( handler : Void -> Void ) {
		//spriter.macros.SpriterMacros.texturePackerChecker('ugly.xml');

		var library = new SpriterKhaG2Library('/');
		engine = new spriter.engine.SpriterEngine(kha.Assets.blobs.animations_scml.toString(), null, library);

		var spriter = engine.addSpriter('char1', 256, 768);
		spriter.playAnim('idle');

		spriter = engine.addSpriter('char1', 256 + 512, 768);
		spriter.playAnim('walk');

		spriter = engine.addSpriter('char1', 256 + 512 + 512, 768);
		spriter.playAnim('jump');

		// use
		// crouch
		// crouch_use
		// idle
		// jump
		// walk

		kha.System.notifyOnRender(library.renderimpl);
		kha.Scheduler.addTimeTask(update, 0, 1 / 60);

		handler();
	}

	function scene_setupCompletedHandler() {
	}

	function update() {
		if (engine != null) {
			engine.update();
		}
	}
}

class Main  {
	public static function main() {
		kha.System.init('spriter | example | kha | g2', 1366, 768, system_initialized);
	}

	static function system_initialized() {
		example = new KhaG2Example();
	}

	static var example : KhaG2Example;
}
