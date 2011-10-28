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
	
	public class AS3Dices extends Sprite
	{
		private var _view : View3D;
		private var _light:PointLight;
		private var _camera:Camera3D;
		private var _scene:Scene3D;
		private var _physics:Away3D4Physics;
		private var _ground:RigidBody;
		private var _skipFrames:Number = 0;
		private var _diceSize:Number = 32;
		
		private var _diceSpawnPosition:Vector3D;
		private var _diceForce:Vector3D;
		private var _defaultDiceSpawnPos:Vector3D = new Vector3D(-1000,500,-200);
		private var _defaultDiceForce:Vector3D = new Vector3D(1100,0,200);
		private var _rCube:RigidBody;

		private static const BOX_WIDTH:Number = 400;
		private static const BOX_HEIGHT:Number = 20;
		private static const BOX_DEPTH:Number = 350;
		private static const BOX_THICKNESS:Number = 5;
		
		
		public function AS3Dices()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function get diceForce():Vector3D
		{
			return _diceForce;
		}

		public function set diceForce(value:Vector3D):void
		{
			_diceForce = value;
		}

		public function get diceSpawnPosition():Vector3D
		{
			return _diceSpawnPosition;
		}

		public function set diceSpawnPosition(value:Vector3D):void
		{
			_diceSpawnPosition = value;
			trace("setSpawn: " + _diceSpawnPosition.toString());
			_rCube.x = value.x;
			_rCube.y = value.y;
			_rCube.z = value.z;
		}

		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			stage.align = StageAlign.TOP_LEFT;
			stage.stageFocusRect = false;
			stage.frameRate = 60;
			stage.quality = StageQuality.MEDIUM;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			AsWingManager.setRoot(this);
			
			init3D();
			create3DBoxes();
			
			initDie();
			
			init2dui();
			
			_view.camera.lookAt(_physics.getMesh(_ground).position);
		}
		
		private function render(e:Event):void
		{
			//_view.camera.x++;
			//_view.camera.lookAt(_physics.getMesh(_ground).position);
			_physics.step(0.1);
			//if (_skipFrames++ % 2 == 0)
			_view.render();
		}
		
		private function create3DBoxes():void
		{
			var colourMat:ColorMaterial = new ColorMaterial(0x00ff00,1);
			var groundMat:ColorMaterial = new ColorMaterial(0x0000ff,1);
			
			var left:RigidBody = _physics.createCube(colourMat, BOX_THICKNESS, BOX_HEIGHT, BOX_DEPTH);  
			left.movable = false;  
			left.x = -(BOX_WIDTH+BOX_THICKNESS)/2;
			left.y = (BOX_HEIGHT)/2; 
			
			var right:RigidBody = _physics.createCube(colourMat, BOX_THICKNESS, BOX_HEIGHT*10, BOX_DEPTH,3,3,2);  
			right.movable = false;  
			right.x = (BOX_WIDTH+BOX_THICKNESS)/2 ;
			right.y = (BOX_HEIGHT*10/2) - (BOX_THICKNESS);
			
			var front:RigidBody = _physics.createCube(colourMat, BOX_WIDTH, BOX_HEIGHT*3, BOX_THICKNESS,3,3,2);   
			front.movable = false;  
			front.z =  (BOX_DEPTH+BOX_THICKNESS)/2 ;
			front.y = (BOX_HEIGHT*3)/2;
			
			var back:RigidBody = _physics.createCube(colourMat, BOX_WIDTH, BOX_HEIGHT*3, BOX_THICKNESS,3,3,2);   
			back.movable = false;  
			back.z = -(BOX_DEPTH+BOX_THICKNESS)/2 ;
			back.y = (BOX_HEIGHT*3)/2; 
			
			_ground = _physics.createCube(groundMat, BOX_WIDTH, BOX_THICKNESS, BOX_DEPTH,2,2);
			_ground.movable = false;  
			_ground.y = (BOX_HEIGHT)/2;
			
			colourMat.lights = [_light];
			groundMat.lights = [_light]
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
			_view.camera.z = _light.z/4;
			_view.camera.rotationX = 20;
			JConfig.solverType = "NORMAL";
			JConfig.doShockStep = false;
			
			addChild(_view);
			
			_physics = new Away3D4Physics(_view,10);
			
			
			var mats:ColorMaterial = new ColorMaterial(0x00ff00,0.5);
			//_cube = new Cube(mats,_diceSize, _diceSize, _diceSize,1,1,1,false);
			//_cube.position = diceSpawnPosition;
			
			_rCube = _physics.createCube(mats,_diceSize,_diceSize,_diceSize,1,1,1,false);
			setDefaultDiceVars();
			_rCube.x = _diceSpawnPosition.x;
			_rCube.y = _diceSpawnPosition.y;
			_rCube.z = _diceSpawnPosition.z;
			_rCube.movable = false;
			//rDie.
			
			//_view.scene.addChild(_cube);
			
			addEventListener(Event.ENTER_FRAME, render);
		}
		
		private function setDefaultDiceVars():void
		{
			diceSpawnPosition = _defaultDiceSpawnPos.clone();
			diceForce = _defaultDiceForce.clone();
		}
		
		private function initDie():void
		{
			//var diceSize:Number = 32;
			//var defaultMat:ColorMaterial = new ColorMaterial(0xff0000,1);
			var skin:DieSkinBitmap = new DieSkinBitmap(_diceSize,0xff0000,0xffffff,2.5,1);
			
			var mat1:BitmapMaterial = new BitmapMaterial(skin.side1(),true,false,false);
			var mat2:BitmapMaterial = new BitmapMaterial(skin.side2(),true,false,false);
			var mat3:BitmapMaterial = new BitmapMaterial(skin.side3(),true,false,false);
			var mat4:BitmapMaterial = new BitmapMaterial(skin.side4(),true,false,false);
			var mat5:BitmapMaterial = new BitmapMaterial(skin.side5(),true,false,false);
			var mat6:BitmapMaterial = new BitmapMaterial(skin.side6(),true,false,false);
			
			/*
			mat1.alpha = 0.5;
			mat2.alpha = 0.5;
			mat3.alpha = 0.5;
			mat4.alpha = 0.5;
			mat5.alpha = 0.5;
			mat6.alpha = 0.5;*/
			
			
			var mats:Vector.<BitmapMaterial> = new Vector.<BitmapMaterial>();
			mats.push(mat1);
			mats.push(mat2);
			mats.push(mat3);
			mats.push(mat4);
			mats.push(mat5);
			mats.push(mat6);
			
			
			for each (var mat:BitmapMaterial in mats)
				mat.lights = [_light];
			
			var rDie:RigidBody = _physics.createCube6(mats, _diceSize,_diceSize,_diceSize);
			rDie.x = _diceSpawnPosition.x;
			rDie.y = _diceSpawnPosition.y;
			rDie.z = _diceSpawnPosition.z;
			rDie.maxRotVelocities = new Vector3D(6,6,6);
			
			rDie.restitution = 0.3;
			rDie.friction = 0.5;
			rDie.mass = 1;
			
			var vThrow:Vector3D = _diceForce;
			rDie.addWorldForce(vThrow, rDie.currentState.position);
		}
		
		private function init2dui():void
		{
			addChild(new Stats(_view,_physics));
			
			var dieSkinBitmap:DieSkinBitmap = new DieSkinBitmap(341.3,0xff0000,0xffffff,20,1);
			var bitmap:Bitmap = new Bitmap(dieSkinBitmap.get3x2CubeMap());
			//addChild(bitmap);
			
			var frame : JFrame = new JFrame( this, "DicesApp control thing" );
			frame.getContentPane().append( createRollingPane() );
			frame.setSize(new IntDimension( 300, 300 ) );
			frame.show();
			frame.y = 200;
			
			createDicePanel();
		}
		
		private function createDicePanel():void
		{
			var frame:JFrame = new JFrame(this, "Dice Spawn stuff");
			frame.getContentPane().append( createDiceSpawnPane() );
			frame.setSize(new IntDimension(300,300));
			frame.show();
			frame.y = 250;
		}
		
		private function createDiceSpawnPane():JPanel
		{
			var pane : JPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
			var pane1: JPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
			var pane2 : JPanel = new JPanel(new VerticalLayout(VerticalLayout.CENTER));
			
			var rollButton:JButton = new JButton("Roll Die");
			var resetBtn:JButton = new JButton("Reset Dice Spawn");
			pane1.append(rollButton);
			pane1.append(resetBtn);
			rollButton.addEventListener(MouseEvent.CLICK, onRollButtonClick);
			resetBtn.addEventListener(MouseEvent.CLICK, onResetBtnClick);
			
			var label1:JLabel = new JLabel("SpawnX");
			var label2:JLabel = new JLabel("SpawnY");
			var label3:JLabel = new JLabel("SpawnZ");
			var label4:JLabel = new JLabel("ForceX");
			var label5:JLabel = new JLabel("ForceY");
			var label6:JLabel = new JLabel("ForceZ");
			pane.append(pane1);
			pane.append(pane2);
			pane2.append(label1);
			pane.setBorder(new EmptyBorder(null, new Insets(10,5,10,5)));
			var spawnXSlider:JSlider = new JSlider(JSlider.HORIZONTAL, -5000,1000,_diceSpawnPosition.x);
			pane2.append(spawnXSlider);
			spawnXSlider.setExtent(10);
			spawnXSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onSpawnXSlider);
			
			pane2.append(label2);
			var spawnYSlider:JSlider = new JSlider(JSlider.HORIZONTAL, 0,1000,_diceSpawnPosition.y);
			pane2.append(spawnYSlider);
			spawnYSlider.setExtent(5);
			spawnYSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onSpawnYSlider);
			
			pane2.append(label3);
			var spawnZSlider:JSlider = new JSlider(JSlider.HORIZONTAL, -1000,10000,_diceSpawnPosition.z);
			pane2.append(spawnZSlider);
			spawnZSlider.setExtent(5);
			spawnZSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onSpawnZSlider);
			
			pane2.append(label4);
			var forceXSlider:JSlider = new JSlider(JSlider.HORIZONTAL, 0, 3000, _diceForce.x);
			pane2.append(forceXSlider);
			forceXSlider.setExtent(10);
			forceXSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onForceXSlider);
			
			pane2.append(label5);
			var forceYSlider:JSlider = new JSlider(JSlider.HORIZONTAL, -500,500,_diceForce.y);
			pane2.append(forceYSlider);
			forceYSlider.setExtent(5);
			forceYSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onForceYSlider);
			
			pane2.append(label6);
			var forceZSlider:JSlider = new JSlider(JSlider.HORIZONTAL, -500,500,_diceForce.z);
			pane2.append(forceZSlider);
			forceZSlider.setExtent(5);
			forceZSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onForceZSlider);
			return pane;
		}
		
		protected function onForceZSlider(e:Event):void
		{
			var slider:JSlider = e.target as JSlider;
			diceForce.z = slider.getValue();
			
		}
		
		protected function onForceYSlider(e:Event):void
		{
			var slider:JSlider = e.target as JSlider;
			diceForce.y = slider.getValue();
		}
		
		protected function onForceXSlider(e:Event):void
		{
			var slider:JSlider = e.target as JSlider;
			diceForce.x = slider.getValue();
		}
		
		protected function onSpawnZSlider(e:Event):void
		{
			var slider:JSlider = e.target as JSlider;
			diceSpawnPosition = new Vector3D(_diceSpawnPosition.x, _diceSpawnPosition.y, slider.getValue());
		}
		
		protected function onSpawnYSlider(e:Event):void
		{
			var slider:JSlider = e.target as JSlider;
			diceSpawnPosition = new Vector3D(_diceSpawnPosition.x, slider.getValue(), _diceSpawnPosition.z);
		}
		
		protected function onSpawnXSlider(e:Event):void
		{
			var slider:JSlider = e.target as JSlider;
			diceSpawnPosition = new Vector3D(slider.getValue(), _diceSpawnPosition.y , _diceSpawnPosition.z);
		}
		
		protected function onDiceXInput(e:Event):void
		{
			var slider:JSlider = e.target as JSlider;
			_diceSpawnPosition.z = slider.getValue();
		}
		
		protected function onInputClick(e:Event):void
		{
			var input:JTextField = e.currentTarget as JTextField;
			input.setText("");
		}
		
		private function createRollingPane():JPanel
		{
			var pane : JPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
			var pane1: JPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
			var pane2 : JPanel = new JPanel(new VerticalLayout(VerticalLayout.CENTER));
			
			var rollButton:JButton = new JButton("Roll Die");
			var rollButton2:JButton = new JButton("Roll 2 Dice");
			pane1.append(rollButton);
			pane1.append(rollButton2);
			rollButton.addEventListener(MouseEvent.CLICK, onRollButtonClick);
			rollButton2.addEventListener(MouseEvent.CLICK, onRollButtonClick2);
			
			var label1:JLabel = new JLabel("CameraX");
			var label2:JLabel = new JLabel("CameraY");
			var label3:JLabel = new JLabel("CameraZ");
			var label4:JLabel = new JLabel("CameraRotX");
			var label5:JLabel = new JLabel("CameraRotY");
			var label6:JLabel = new JLabel("CameraRotZ");
			pane.append(pane1);
			pane.append(pane2);
			pane2.append(label1);
			pane.setBorder(new EmptyBorder(null, new Insets(10,5,10,5)));
			var cameraXSlider:JSlider = new JSlider(JSlider.HORIZONTAL, -10000,10000,_view.camera.x);
			pane2.append(cameraXSlider);
			cameraXSlider.setExtent(5);
			cameraXSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onCameraXSlider);
			
			pane2.append(label2);
			var cameraYSlider:JSlider = new JSlider(JSlider.HORIZONTAL, -10000,10000,_view.camera.y);
			pane2.append(cameraYSlider);
			cameraYSlider.setExtent(5);
			cameraYSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onCameraYSlider);
			
			pane2.append(label3);
			var cameraZSlider:JSlider = new JSlider(JSlider.HORIZONTAL, -10000,10000,_view.camera.z);
			pane2.append(cameraZSlider);
			cameraZSlider.setExtent(5);
			cameraZSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onCameraZSlider);
			
			pane2.append(label4);
			var cameraRotXSlider:JSlider = new JSlider(JSlider.HORIZONTAL, -90,90,_view.camera.rotationX);
			pane2.append(cameraRotXSlider);
			cameraRotXSlider.setExtent(1);
			cameraRotXSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onCameraRotXSlider);
			
			pane2.append(label5);
			var cameraRotYSlider:JSlider = new JSlider(JSlider.HORIZONTAL, -90,90,_view.camera.rotationY);
			pane2.append(cameraRotYSlider);
			cameraRotYSlider.setExtent(1);
			cameraRotYSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onCameraRotYSlider);
			
			pane2.append(label6);
			var cameraRotZSlider:JSlider = new JSlider(JSlider.HORIZONTAL, -90,90,_view.camera.rotationZ);
			pane2.append(cameraRotZSlider);
			cameraRotZSlider.setExtent(1);
			cameraRotZSlider.addEventListener(InteractiveEvent.STATE_CHANGED, onCameraRotZSlider);
			return pane;
		}
		
		protected function onResetBtnClick(event:MouseEvent):void
		{
			setDefaultDiceVars();
		}
		
		protected function onRollButtonClick(event:MouseEvent):void
		{
			initDie();
		}
		
		protected function onRollButtonClick2(event:MouseEvent):void
		{
			initDie();
			TweenLite.to(this, 0.2, {onComplete:initDie});
		}
		
		private function onCameraXSlider(e:InteractiveEvent):void
		{
			var slider:JSlider = e.target as JSlider;
			TweenLite.to(_view.camera, 0.3, {x:slider.getValue(), ease:Quad.easeOut});
			//_view.camera.x = slider.getValue();
		}
		
		private function onCameraYSlider(e:InteractiveEvent):void
		{
			var slider:JSlider = e.target as JSlider;
			TweenLite.to(_view.camera, 0.3, {y:slider.getValue(), ease:Quad.easeOut});
			//_view.camera.y = slider.getValue();
		}
		
		private function onCameraZSlider(e:InteractiveEvent):void
		{
			var slider:JSlider = e.target as JSlider;
			TweenLite.to(_view.camera, 0.3, {z:slider.getValue(), ease:Quad.easeOut});
			//_view.camera.z = slider.getValue();
		}
		
		private function onCameraRotXSlider(e:InteractiveEvent):void
		{
			var slider:JSlider = e.target as JSlider;
			TweenLite.to(_view.camera, 0.3, {rotationX:slider.getValue(), ease:Quad.easeOut});
			//_view.camera.z = slider.getValue();
		}	
		
		private function onCameraRotYSlider(e:InteractiveEvent):void
		{
			var slider:JSlider = e.target as JSlider;
			TweenLite.to(_view.camera, 0.3, {rotationY:slider.getValue(), ease:Quad.easeOut});
			//_view.camera.z = slider.getValue();
		}	
		
		private function onCameraRotZSlider(e:InteractiveEvent):void
		{
			var slider:JSlider = e.target as JSlider;
			TweenLite.to(_view.camera, 0.3, {rotationZ:slider.getValue(), ease:Quad.easeOut});
			//_view.camera.z = slider.getValue();
		}	
	}
}
