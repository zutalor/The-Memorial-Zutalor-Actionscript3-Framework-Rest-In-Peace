package com.zutalor.ui
{

	import flash.display.*;
	import flash.events.*;
	import flash.text.*;

	[SWF(width="630", height="415", backgroundColor="#000000", frameRate="30")]

	public class FluidGrid extends Sprite {

		// Instantiate stage variables
		public var sw:Number;
		public var sh:Number;

		// Draw grid lines
		public var grid:Sprite = new Sprite();
		public var horzLines:Sprite = new Sprite();
		public var vertLines:Sprite = new Sprite();
		public var gridLines:Array = new Array();
		public var spacing:Number = 24;
		public var lineColor:int = 0x333333;
		public var lineWeight:Number = 1;
		public var lineAlpha:Number = 0.5;
		public var lineHinting:Boolean = true;
		public var lineScale:String = "none";

		// Draw x-axis and y-axis
		public var xAxis:Sprite = new Sprite();
		public var yAxis:Sprite = new Sprite();
		public var xAxisColor:int = 0xeeeeee;
		public var yAxisColor:int = 0xeeeeee;

		public var hLine:Shape = new Shape();
		public var vLine:Shape = new Shape();

		public var numVertLines:int = Math.floor(sw/spacing);
		public var numHorzLines:int = Math.floor(sh/spacing);
		public var xOffset:Number = (Math.ceil(numHorzLines/2) * spacing) - (sw/2);
		public var yOffset:Number = (Math.ceil(numVertLines/2) * spacing) - (sh/2); 

		// Reusable array index variable
		private var i:int;

		public function FluidGrid() {
		}
		
		public function show():void
		{
			sw = stage.stageWidth;
			sh = stage.stageHeight;

			// Turn scaling off and set alignment to top left
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			// Draw grid lines
			drawGridLines();
			addChild(grid);
			grid.addChild(horzLines);
			grid.addChild(vertLines);

			// Draw x- and y-axes and add to display list
			drawAxes();

			// Add event listener to redraw grid on stage resize
			stage.addEventListener(Event.RESIZE, resizeListener, false, 0, true);
		}

		private function resizeListener(e:Event):void {
			// Stage size at resize
			sh = stage.stageHeight;
			sw = stage.stageWidth;

			resizeAxes();
			redrawGridLines();
		}

		private function resizeAxes():void {
			// Scale x-axis and y-axis at stage resize
			yAxis.height = sh;
			yAxis.x = sw/2;
			xAxis.width = sw;
			xAxis.y = sh/2;
		}

		private function redrawGridLines():void {
			// Determine number of lines to draw
			numHorzLines = Math.floor(sh/spacing);
			numVertLines = Math.floor(sw/spacing);

			// Determine horizontal and vertical offsets
			xOffset = (sw/2) - (Math.ceil(numVertLines/2) * spacing);
			yOffset = (sh/2) - (Math.ceil(numHorzLines/2) * spacing); 

			// Resize horizontal lines
			for (i = 0; i < horzLines.numChildren; i++) {
				horzLines.getChildAt(i).width = sw;
				horzLines.getChildAt(i).y = i * spacing + yOffset;
			}

			// Resize vertical lines
			for (i = 0; i < vertLines.numChildren; i++) {
				vertLines.getChildAt(i).height = sh;
				vertLines.getChildAt(i).x = i * spacing + xOffset;
			}

			// If number of existing lines is less than lines required to fill screen
			if (numHorzLines > horzLines.numChildren) {
				// Draw additional horizontal lines
				for (i = horzLines.numChildren - 1; i <= numHorzLines; i++) {
					gridLines[i] = new Shape();
					gridLines[i].name = "hLine" + i;
					drawHorzLine(gridLines[i]);
					gridLines[i].y = (i + 1) * spacing + yOffset;
				}
			}

			// If number of existing lines is less than lines required to fill screen
			if (numVertLines > vertLines.numChildren) {
				// Draw additional vertical lines
				for (i = vertLines.numChildren - 1; i <= numVertLines; i++) {
					gridLines[i] = new Shape();
					gridLines[i].name = "vLine" + i;
					drawVertLine(gridLines[i]);
					gridLines[i].x = (i + 1) * spacing + xOffset;
				}
			}
		}

		private function drawAxes():void {
			// Draw lines at center stage
			var yg:Graphics = yAxis.graphics;
			var xg:Graphics = xAxis.graphics;

			yg.lineStyle(lineWeight, yAxisColor, lineAlpha, lineHinting, lineScale);
			yg.moveTo(0,0);
			yg.lineTo(0,sh);
			yAxis.x = sw/2;

			xg.lineStyle(lineWeight, xAxisColor, lineAlpha, lineHinting, lineScale);
			xg.moveTo(0,0);
			xg.lineTo(sw,0);
			xAxis.y = sh/2;

			addChild(yAxis);
			addChild(xAxis);
		}

		private function drawHorzLine(horzLine:Shape):void {
			var hl:Graphics = horzLine.graphics;
			hl.lineStyle(lineWeight, lineColor, lineAlpha, lineHinting, lineScale);
			hl.moveTo(0,0);
			hl.lineTo(sw,0);
			horzLines.addChild(horzLine);
		}

		private function drawVertLine(vertLine:Shape):void {
			var vl:Graphics = vertLine.graphics;
			vl.lineStyle(lineWeight, lineColor, lineAlpha, lineHinting, lineScale);
			vl.moveTo(0,0);
			vl.lineTo(0,sh);
			vertLines.addChild(vertLine);
		}

		private function drawGridLines():void {
			// Set grid spacing and line style
			numHorzLines = Math.floor(sh/spacing);
			numVertLines = Math.floor(sw/spacing);

			xOffset = (sw/2) - (Math.ceil(numVertLines/2) * spacing);
			yOffset = (sh/2) - (Math.ceil(numHorzLines/2) * spacing); 

			// Draw horizontal lines
			for (i = 0; i <= numHorzLines; i++) {
				gridLines[i] = new Shape();
				gridLines[i].name = "hLine" + i;
				drawHorzLine(gridLines[i]);
				gridLines[i].y = i * spacing + yOffset;
			}

			// Draw vertical lines
			for (i = 0; i <= numVertLines; i++) {
				gridLines[i] = new Shape();
				gridLines[i].name = "vLine" + i;
				drawVertLine(gridLines[i]);
				gridLines[i].x = i * spacing + xOffset;
			}
		}
	}
}