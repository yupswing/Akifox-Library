
package com.akifox.plik;

import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import openfl.text.AntiAliasType;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import com.akifox.transform.Transformation;

#if (flash || !v2)
import openfl.events.Event;
// this class it's a TextField
// Flash renders the TextField beautifully and it doesn't need any trick
class Text extends TextField
#else
// this class is a Bitmap encapsulating a TextField
// the TextField will be drawn every time it changes (now only .text)
import openfl.display.Bitmap;
import openfl.display.BitmapData;
class Text extends Bitmap
#end
{
	var textField:TextField;
	var textFieldFont:Font;
	var textFieldColor:Int;
	var textFieldFormat:TextFormat;
	var textFieldSize:Int;

 	#if (!flash && v2)

	 	// make the use of .text the same in every target
	 	var textFieldBitmapData:BitmapData;
	 	
		public var text(get, set):String;

		function get_text():String {
		  return textField.text;
		}
		function set_text(value:String):String {
		  return setText(value);
		}

		function redraw() {
			var nw = Std.int(textField.textWidth);
			var nh = Std.int(textField.textHeight);
			bitmapData = null;

			if (textFieldBitmapData != null) {
				if (nw <= textFieldBitmapData.width && nh <= textFieldBitmapData.height) {
					// inside the old rect
					textFieldBitmapData.fillRect(new Rectangle(0,0,textFieldBitmapData.width,textFieldBitmapData.height), 0x00000000);
				} else {
					// bigger
					textFieldBitmapData.dispose();
					textFieldBitmapData = null;
		 	    	textFieldBitmapData = new BitmapData(nw, nh, true, 0x000000);
				}
		 	} else {
		 	    textFieldBitmapData = new BitmapData(nw, nh, true, 0x000000);
		 	}
	    	textFieldBitmapData.draw(textField);

	    	bitmapData = textFieldBitmapData;
		    if (_transformation != null) _transformation.updateSize(nw,nh);
		}

	#else

		private function redraw() { 
			if (_transformation != null) _transformation.updateSize();
		}

	#end

    public function setText(value:String) {
        textField.text = value;
        redraw();
	    return value;
    }

	public function setColor(value:Int) {
        textFieldFormat.color = value;
        textField.defaultTextFormat = textFieldFormat;
        textField.setTextFormat(textFieldFormat);
        redraw();
        return value;
    }

	private static var _defaultFont:Font=null;
	private static var _defaultFontName:String="";
	public static var defaultFont(get,set):String;
	private static function get_defaultFont():String {
		return _defaultFontName;

	}
	private static function set_defaultFont(value:String):String {
		_defaultFont = PLIK.getFont(value);
		return _defaultFontName = value;
	}

	public function new (stringText:String="",?size:Int=20,?color:Int=0,?align:#if !v2 TextFormatAlign #else String = null #end,?font:String="",?smoothing:Bool=true) {
		
		super ();

        if (align==null) align = TextFormatAlign.LEFT;

	    textFieldSize = size;
	    textFieldColor = color;
	    if (font=="") {
	    	textFieldFont = _defaultFont;
	    } else {
	    	textFieldFont = PLIK.getFont(font);
	    }


 		#if (flash || !v2)
		    // this class it's actually a TextField
		    textField = this;
	    #else
		    // this class is a Bitmap encapsulating a TextField
			textField = new TextField();
		    bitmapData = textFieldBitmapData;
		    this.smoothing = smoothing;
		#end

		//prepare the TextFormat
	    textFieldFormat = new TextFormat(textFieldFont.fontName, textFieldSize , textFieldColor);

	    textFieldFormat.align = align;
	    textField.autoSize = TextFieldAutoSize.LEFT;
	    textField.antiAliasType = AntiAliasType.ADVANCED;
	    textField.defaultTextFormat = textFieldFormat;
	    textField.embedFonts = true;
	    textField.selectable = false;
	    textField.wordWrap = false;
	    textField.border = false;
		text = stringText;

        _transformation = new Transformation(this.transform.matrix,this.width,this.height);
        _transformation.bind(this);

	}
    
    private var _transformation:Transformation;
    public var t(get,never):Transformation;
    private function get_t():Transformation {
        return _transformation;
    }

    //##########################################################################################
    // IDestroyable

    public override function toString():String {
        return '[PLIK.Text "'+text+'"]';
    }

    public function destroy() {

        #if gbcheck
        trace('GB Destroy > ' + this);
        #end

    	// destroy this element
    	this._transformation.destroy();
    	this._transformation = null;

	 	#if (!flash && v2)
		bitmapData = null;
	 	textFieldBitmapData.dispose();
	 	textFieldBitmapData = null;
	 	#end
    }
	

}