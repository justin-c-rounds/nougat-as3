package org.justincrounds.actionscript {
	import com.hurlant.crypto.symmetric.*;
	import com.hurlant.util.*;
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import com.hurlant.crypto.Crypto;
	public class Cryptkeeper extends Sprite {
		private var type:String='simple-des-ecb';
		private var _key:ByteArray;
		public function Cryptkeeper() {
		}
		public function set key(key:String) {
			_key = Hex.toArray(Hex.fromString(key));// can only be 8 characters long
		}
		public function encrypt(txt:String = ''):String {
			var data:ByteArray = Hex.toArray(Hex.fromString(txt));
			var pad:IPad = new PKCS5;
			var mode:ICipher = Crypto.getCipher(type, _key, pad);
			pad.setBlockSize(mode.getBlockSize());
			mode.encrypt(data);
			return Base64.encodeByteArray(data);
		}
		public function decrypt(txt:String = ''):String {
			var data:ByteArray = Base64.decodeToByteArray(txt);
			var pad:IPad = new PKCS5;
			var mode:ICipher = Crypto.getCipher(type, _key, pad);
			pad.setBlockSize(mode.getBlockSize());
			mode.decrypt(data);
			return Hex.toString(Hex.fromArray(data));
		}
	}
}
