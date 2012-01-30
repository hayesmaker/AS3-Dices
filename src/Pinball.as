package
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.SpringCam;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.materials.*;
	import away3d.materials.utils.CubeMap;
	import away3d.materials.utils.WireframeMapGenerator;
	import away3d.primitives.Cube;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.hayesmaker.dice.DieSkinBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Scene;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display3D.textures.CubeTexture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Vector3D;
	
	import flashx.textLayout.formats.VerticalAlign;
	
	import jiglib.cof.JConfig;
	import jiglib.debug.Stats;
	import jiglib.geometry.JBox;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.away3d4.Away3D4Mesh;
	import jiglib.plugin.away3d4.Away3D4Physics;
	
	import org.aswing.AsWingManager;
	import org.aswing.Component;
	import org.aswing.FlowLayout;
	import org.aswing.GridLayout;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JSlider;
	import org.aswing.JTextField;
	import org.aswing.border.EmptyBorder;
	import org.aswing.colorchooser.VerticalLayout;
	import org.aswing.event.AWEvent;
	import org.aswing.event.InteractiveEvent;
	import org.aswing.geom.IntDimension;
	
	public class Pinball extends Sprite
	{
		private var _view : View3D;
		private var _light:PointLight;
		private var _camera:Camera3D;
		private var _scene:Scene3D;
		private var _physics:Away3D4Physics;
		private var _ground:RigidBody;
		private var _skipFrames:Number = 0;

		private var _ball:RigidBody;
		private var _ballSize:Number = 32;
		private var _ballSpawn:Vector3D;
		private var _ballForce:Vector3D;

		/*
		private var _defaultDiceSpawnPos:Vector3D = new Vector3D(-1000,500,-200);
		private var _defaultDiceForce:Vector3D = new Vector3D(1100,0,200);*/

		private static const BOX_WIDTH:Number = 400;
		private static const BOX_HEIGHT:Number =150;
		private static const BOX_DEPTH:Number = 600;
		private static const BOX_THICKNESS:Number = 5;
		
		
		public function Pinball()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			AsWingManager.setRoot(this);
			
			initStage();
			init3D();
			create3DBoxes();
			initBall();
			init2dui();
			
			
			_view.camera.lookAt(_physics.getMesh(_ground).position);
		}
		
		private function initStage():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.stageFocusRect = false;
			stage.frameRate = 60;
			stage.quality = StageQuality.MEDIUM;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(MouseEvent.CLICK, onStageClick);
		}
		
		private function init3D():void
		{
			_light = new PointLight();
			_light.color = 0xffffff;
			_light.diffuse = 1;
			_light.y = 1000;
			_light.z = -1000;
			
			_view = new View3D();
			_view.backgroundColor = 0x666666;
			_view.antiAlias = 4;
			_view.scene.addChild(_light);
			_view.camera.y = _light.y/2;
			_view.camera.z = _light.z/2;
			_view.camera.rotationX = 20;
			JConfig.solverType = "ACCUMULATED";
			JConfig.doShockStep = true;
			JConfig.angVelThreshold =0;
			JConfig.velThreshold = 0;
			JConfig.numPenetrationRelaxationTimesteps = 100;
			JConfig.collToll = 0.05;
			
			addChild(_view);
			
			_physics = new Away3D4Physics(_view,2);
			
			
			var mats:ColorMaterial = new ColorMaterial(0x00ff00,0.5);
			//_cube = new Cube(mats,_diceSize, _diceSize, _diceSize,1,1,1,false);
			//_cube.position = diceSpawnPosition;
			/*
			_rCube = _physics.createCube(mats,_diceSize,_diceSize,_diceSize,1,1,1,false);
			
			_rCube.x = _diceSpawnPosition.x;
			_rCube.y = _diceSpawnPosition.y;
			_rCube.z = _diceSpawnPosition.z;
			_rCube.movable = false;
			//rDie.
			
			//_view.scene.addChild(_cube);
			*/
			addEventListener(Event.ENTER_FRAME, render);
		}
		
		protected function onStageClick(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			var vThrow:Vector3D  = new Vector3D(0,0,5000);
			_ball.applyWorldImpulse(vThrow,_ball.currentState.position);
			
		}
		
		private function render(e:Event):void
		{
			//_view.camera.x++;
			//_view.camera.lookAt(_physics.getMesh(_ground).position);
			_physics.step(0.2);
			//if (_skipFrames++ % 2 == 0)
			_view.render();
		}
		
		private function create3DBoxes():void
		{
			var colourMat:ColorMaterial = new ColorMaterial(0x00ff00,1);
			var groundMat:ColorMaterial = new ColorMaterial(0x0000ff,1);
			
			var left:RigidBody = _physics.createCube(colourMat, BOX_THICKNESS, BOX_HEIGHT, BOX_DEPTH);  
			left.movable = false;  
			left.x = -BOX_WIDTH/2;
			left.y = 0;
			
			var right:RigidBody = _physics.createCube(colourMat, BOX_THICKNESS, BOX_HEIGHT, BOX_DEPTH,3,3,2);  
			right.movable = false;  
			right.x = BOX_WIDTH/2;
			right.y = 0;
			
			var wall1:RigidBody = _physics.createCube(colourMat, BOX_THICKNESS/2, 60, BOX_DEPTH*0.9,3,3,2);
			wall1.movable = false;
			wall1.x = 170;
			wall1.y = 0;
			wall1.z = -35;
			
			var wall2:RigidBody = _physics.createCube(colourMat, BOX_THICKNESS/2,BOX_HEIGHT*0.7,75, 1,1.1);
			wall2.movable = false;
			wall2.x = 170;
			wall2.y = 0;
			wall2.z = 240;
			wall2.rotationX = 0;
			wall2.rotationY = -45;
			
			
			var front:RigidBody = _physics.createCube(colourMat, BOX_WIDTH, BOX_HEIGHT/2, BOX_THICKNESS,3,3,2);   
			front.movable = false;  
			front.z =  -(BOX_DEPTH+BOX_THICKNESS)/2 ;
			front.y = -25;
			
			var back:RigidBody = _physics.createCube(colourMat, BOX_WIDTH, BOX_HEIGHT*3, BOX_THICKNESS*15,10,10,5);   
			back.movable = false;  
			back.z = (BOX_DEPTH+BOX_THICKNESS)/2 ;
			back.y = 0;
			
			_ground = _physics.createCube(groundMat, BOX_WIDTH, BOX_THICKNESS, BOX_DEPTH,2,2);
			_ground.movable = false;  
			_ground.y = 0;
			_ground.rotationX = -6.5;
			_ground.friction = 0.15;
			_ground.restitution = 0.5;

			colourMat.lights = [_light];
			groundMat.lights = [_light]
		}
		
		
		private function initBall():void
		{
			var mats:ColorMaterial = new ColorMaterial(0xff0000,1);
			mats.lights = [_light];
			_ball = _physics.createSphere(mats,10,16,12,true);
		
			_ball.x = 175
			_ball.y = 45;
			_ball.z = -280;
			
			_ball.mass = 70;
			_ball.friction = 0.15;
			_ball.restitution = 1;
		}
		
		private function init2dui():void
		{
			addChild(new Stats(_view,_physics));
			
		}
		
	}
}
