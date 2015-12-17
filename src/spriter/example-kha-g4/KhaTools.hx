package;

class KhaTools {
	public static function fixAssetId( original : String ) : String {
		var fullPath = original.substr(0);
		var withoutExtension : String;

		// TODO (DK) test for all kinds of graphic file extensions
		if (StringTools.endsWith(fullPath, 'png')) {
			withoutExtension = haxe.io.Path.withoutExtension(fullPath);
		} else {
			withoutExtension = fullPath;
		}

		var withoutDirectory = haxe.io.Path.withoutDirectory(withoutExtension);

		// TODO (DK) any more special characters?
		var replacedMinus = StringTools.replace(withoutDirectory.substr(0), '-', '_');
		var replacedDot = StringTools.replace(replacedMinus.substr(0), '.', '_');

		var normalizedPath = replacedDot;
		return normalizedPath;
	}
}
