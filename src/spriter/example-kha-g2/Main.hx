package;

import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.util.SpriterUtil;

class KhaG2Example {
	var engine : spriter.engine.SpriterEngine;
	var scml : spriter.definitions.ScmlObject;

	var library : spriter.library.KhaG2Library;
	var rendermode : kha.Framebuffer -> Void;

	var backbuffer : kha.Image;

	public function new() {
		kha.Assets.loadEverything(assets_loadedHandler);

		backbuffer = kha.Image.createRenderTarget(2048, 2048);
		rendermode = renderFramebuffer;
//		rendermode = renderBackbuffer;
	}

	function assets_loadedHandler() {
		setupScene();
	}

	function setupScene() {
		library = new spriter.library.KhaG2Library('/');
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

		kha.System.notifyOnRender(render);
		kha.Scheduler.addTimeTask(update, 0, 1 / 60);
	}

	function render( framebuffer : kha.Framebuffer ) {
		rendermode(framebuffer);
	}

	function renderBackbuffer( framebuffer : kha.Framebuffer ) {
		var bb = backbuffer.g2;
		bb.begin();
			library.renderimpl(bb);
		bb.end();

		var fb = framebuffer.g2;
		fb.begin();
			kha.Scaler.scale(backbuffer, framebuffer, kha.System.screenRotation);
		fb.end();
	}

	function renderFramebuffer( framebuffer : kha.Framebuffer ) {
		var g = framebuffer.g2;

		g.begin();
			library.renderimpl(g);
		g.end();
	}

	function update() {
		if (engine != null) {
			engine.update();
		}
	}
}

class Main  {
	public static function main() {
		kha.System.init('spriter | example | kha | g2', 1366, 768, system_initializedHandler);
	}

	static function system_initializedHandler() {
		new KhaG2Example();
	}
}
