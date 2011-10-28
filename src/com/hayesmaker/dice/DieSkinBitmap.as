package com.hayesmaker.dice
{
	import away3d.cameras.SpringCam;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class DieSkinBitmap
	{
		private var _diceSize:Number;
		private var _diceColour:Number;
		private var _diceAlpha:Number;
		private var _spotsColour:Number;
		private var _spotRadius:Number;
		private var _spotsAlpha:Number = 2;
		
		private static const SHRINK_Y:Number = 1;
		
		private var _side:Sprite;
		private var _dots:Sprite;
		
		public function DieSkinBitmap(diceSize:Number, diceColour:Number, spotsColour:Number, spotRadius:Number, diceAlpha:Number)
		{
			_diceSize  = diceSize;
			_diceColour = diceColour;
			_diceAlpha = diceAlpha;
			_spotsColour = spotsColour;
			_spotRadius = spotRadius;
			
			_side = new Sprite();
			_dots = new Sprite();
			_side.addChild(_dots);
		}
		
		public function get3x2CubeMap():BitmapData
		{
			//_diceSize = 341.3;
			var bmpData:BitmapData = new BitmapData(1024,1024,true);

			var sourceRect:Rectangle = new Rectangle(0,0,_diceSize, _diceSize*SHRINK_Y);
			
			bmpData.copyPixels(side1(), sourceRect, new Point(0,0));
			bmpData.copyPixels(side2(), sourceRect, new Point(_diceSize,0));
			bmpData.copyPixels(side3(), sourceRect, new Point(_diceSize*2,0));
			bmpData.copyPixels(side4(), sourceRect, new Point(0,_diceSize*SHRINK_Y));
			bmpData.copyPixels(side5(), sourceRect, new Point(_diceSize,_diceSize*SHRINK_Y));
			bmpData.copyPixels(side6(), sourceRect, new Point(_diceSize*2,_diceSize*SHRINK_Y));
			
			trace("bmpData.width: " + bmpData.width + " bmpData.height: " + bmpData.height);
			
			return bmpData;
		}
		
		public function side1():BitmapData
		{
			//_diceSize = 341.3;
			drawBackGround();
			
			_dots.graphics.clear();
			_dots.graphics.beginFill(_spotsColour, _spotsAlpha);
			_dots.graphics.drawCircle(_diceSize*0.5, _diceSize*0.5, _spotRadius);
			
			var bmpData:BitmapData = new BitmapData(_diceSize, _diceSize*SHRINK_Y, true);
			_side.scaleY = SHRINK_Y;
			bmpData.draw(_side);
			return bmpData;
		}
		
		public function side2():BitmapData
		{
			//_diceSize = 341.3;
			drawBackGround();
			
			_dots.graphics.clear();
			_dots.graphics.beginFill(_spotsColour, _spotsAlpha);
			_dots.graphics.drawCircle(_diceSize*0.2, _diceSize*0.2, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.8, _diceSize*0.8, _spotRadius);
			
			var bmpData:BitmapData = new BitmapData(_diceSize, _diceSize*SHRINK_Y, true);
			_side.scaleY = SHRINK_Y;
			bmpData.draw(_side);
			return bmpData;
		}
		
		public function side3():BitmapData
		{
			//_diceSize = 341.3;
			drawBackGround();

			_dots.graphics.clear();
			_dots.graphics.beginFill(_spotsColour, _spotsAlpha);
			_dots.graphics.drawCircle(_diceSize*0.2, _diceSize*0.2, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.5, _diceSize*0.5, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.8, _diceSize*0.8, _spotRadius);
			
			var bmpData:BitmapData = new BitmapData(_diceSize, _diceSize*SHRINK_Y, true);
			_side.scaleY = SHRINK_Y;
			bmpData.draw(_side);
			return bmpData;
			
		}
		
		public function side4():BitmapData
		{
			//_diceSize = 341.3;
			drawBackGround();
			
			_dots.graphics.clear();
			_dots.graphics.beginFill(_spotsColour, _spotsAlpha);
			_dots.graphics.drawCircle(_diceSize*0.2, _diceSize*0.2, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.2, _diceSize*0.8, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.8, _diceSize*0.2, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.8, _diceSize*0.8, _spotRadius);
			
			var bmpData:BitmapData = new BitmapData(_diceSize, _diceSize*SHRINK_Y, true);
			_side.scaleY = SHRINK_Y;
			bmpData.draw(_side);
			return bmpData;
			
		}
		
		public function side5():BitmapData
		{
			//_diceSize = 341.3;
			drawBackGround();
			
			_dots.graphics.clear();
			_dots.graphics.beginFill(_spotsColour, _spotsAlpha);
			_dots.graphics.drawCircle(_diceSize*0.2, _diceSize*0.2, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.2, _diceSize*0.8, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.8, _diceSize*0.2, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.8, _diceSize*0.8, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.5, _diceSize*0.5, _spotRadius);
			_dots.graphics.endFill();
			
			var bmpData:BitmapData = new BitmapData(_diceSize, _diceSize*SHRINK_Y, true);
			_side.scaleY = SHRINK_Y;
			bmpData.draw(_side);
			return bmpData;
		}
		
		public function side6():BitmapData
		{
			//_diceSize = 341.3;
			drawBackGround();
			
			_dots.graphics.clear();
			_dots.graphics.beginFill(_spotsColour, _spotsAlpha);
			_dots.graphics.drawCircle(_diceSize*0.2, _diceSize*0.2, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.2, _diceSize*0.5, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.2, _diceSize*0.8, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.8, _diceSize*0.2, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.8, _diceSize*0.5, _spotRadius);
			_dots.graphics.drawCircle(_diceSize*0.8, _diceSize*0.8, _spotRadius);
			_dots.graphics.endFill();

			var bmpData:BitmapData = new BitmapData(_diceSize, _diceSize*SHRINK_Y, true);
			_side.scaleY = SHRINK_Y;
			bmpData.draw(_side);
			return bmpData;
		}
		
		private function drawBackGround():void
		{
			//_diceSize = 341.3;
			_side.graphics.clear();
			_side.graphics.beginFill(_diceColour, _diceAlpha);
			_side.graphics.drawRect(0, 0, _diceSize, _diceSize);
			_side.graphics.endFill();
		}
	}
}