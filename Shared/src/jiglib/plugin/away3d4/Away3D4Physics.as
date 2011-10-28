package jiglib.plugin.away3d4 {
	
	import away3d.containers.View3D;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.MaterialBase;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;
	import away3d.primitives.Sphere;
	import away3d.tools.MeshHelper;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.geometry.JSphere;
	import jiglib.geometry.JTerrain;
	import jiglib.geometry.JTriangleMesh;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.AbstractPhysics;
	import jiglib.plugin.away3d4.Away3D4Mesh;

	public class Away3D4Physics extends AbstractPhysics {
		
		private var view:View3D;

		public function Away3D4Physics(view:View3D, speed:Number = 1) {
			this.view = view;
			super(speed);
		}
		
		public function getMesh(body:RigidBody):Mesh {
			if(body.skin!=null){
				return Away3D4Mesh(body.skin).mesh;
			}else {
				return null;
			}
		}
		
		public function createGround(material:MaterialBase,width:int=500,height:int=500, segmentsW:uint = 1, segmentsH:uint = 1, yUp:Boolean = true,level:Number = 0):RigidBody {
			var ground:Plane = new Plane(material, width, height, segmentsW, segmentsH, yUp);

			view.scene.addChild(ground);
			
			var jGround:JPlane = new JPlane(new Away3D4Mesh(ground));
			jGround.y = level;
			jGround.rotationX = 90;
			jGround.movable = false;
			addBody(jGround);
			return jGround;
		}
		
		public function createCube(material:MaterialBase,width:Number=500,height:Number=500,depth:Number=500,segmentsW:uint = 1, segmentsH:uint = 1, segmentsD:uint = 1, tile6:Boolean = true):RigidBody
		{
			var cube:Cube = new Cube(material, width, height, depth, segmentsW, segmentsH, segmentsD, tile6);
			view.scene.addChild(cube);
			
			var jBox:JBox = new JBox(new Away3D4Mesh(cube), width, depth, height);
			addBody(jBox);
			return jBox;
		}
		
		public function createCube6(materialsVect:Vector.<BitmapMaterial>, w:Number, h:Number, d:Number):RigidBody
		{
			var cube:Mesh = new Plane(materialsVect[0], w, h) as Mesh;
			cube.castsShadows = true;
			cube.z = -d/2
			var vr:Vector3D;
			var vn:Vector3D;
			var v:Vector3D = new Vector3D()
			var n:Vector3D = new Vector3D()
			var rotM:Matrix3D = new Matrix3D();
			
			for (var cubeFaceNum:int = 1; cubeFaceNum < 6; cubeFaceNum++)
			{
				var subGeometry:SubGeometry = SubGeometry(Mesh(cube).geometry.subGeometries[0]).clone();
				var vtd:Vector.<Number> = new Vector.<Number>
				var vnd:Vector.<Number> = new Vector.<Number>
				rotM.identity();
				
				if (cubeFaceNum == 1) rotM.appendRotation(180, new Vector3D(0, 1, 0));
				if (cubeFaceNum == 2) rotM.appendRotation(90, new Vector3D(0, 1, 0));
				if (cubeFaceNum == 3) rotM.appendRotation(270, new Vector3D(0, 1, 0));
				if (cubeFaceNum == 4) rotM.appendRotation(90, new Vector3D(1, 0, 0));
				if (cubeFaceNum == 5) rotM.appendRotation(-90, new Vector3D(1, 0, 0));
				
				for (var i:int = 0; i < subGeometry.vertexData.length; i = i + 3)
				{ 
					v.setTo(subGeometry.vertexData[i], subGeometry.vertexData[i + 1], subGeometry.vertexData[i + 2])
					vr = rotM.deltaTransformVector(v);
					
					n.setTo(subGeometry.vertexNormalData[i], subGeometry.vertexNormalData[i+1], subGeometry.vertexNormalData[i+2])
					vn = rotM.deltaTransformVector(n);
					vn.normalize();
					
					if (cubeFaceNum == 1) 
					{
						vr.incrementBy(new Vector3D( 0, 0, d));
					}
					if (cubeFaceNum == 2) 
					{
						vr.z *= d / w;
						vr.incrementBy(new Vector3D( -w / 2, 0, d / 2));
					}
					if (cubeFaceNum == 3) 
					{
						vr.z *= d / w;
						vr.incrementBy(new Vector3D( w / 2, 0, d / 2));
					}
					if (cubeFaceNum == 4) 
					{
						vr.z *= d / h;
						vr.incrementBy(new Vector3D( 0, h/2, d / 2));
					}
					if (cubeFaceNum == 5) 
					{
						vr.z *= d / h;
						vr.incrementBy(new Vector3D( 0, -h/2, d / 2));
					}
					vtd.push(vr.x);
					vtd.push(vr.y);
					vtd.push(vr.z);
					
					vnd.push(vn.x);
					vnd.push(vn.y);
					vnd.push(vn.z);
					
				}
				subGeometry.updateVertexData(vtd);
				subGeometry.updateVertexNormalData(vnd);
				Mesh(cube).geometry.addSubGeometry(subGeometry);
				Mesh(cube).subMeshes[cubeFaceNum].material = materialsVect[cubeFaceNum];
			}
			cube.z = 0
			MeshHelper.recenter(cube);
			
			cube.subMeshes[0].material.name = "frontMaterial";
			cube.subMeshes[1].material.name = "backMaterial";
			cube.subMeshes[2].material.name = "leftMaterial";
			cube.subMeshes[3].material.name = "rightMaterial";
			cube.subMeshes[4].material.name = "topMaterial";
			cube.subMeshes[5].material.name = "bottomMaterial";
			
			
			/*
			cube.subMeshes[0].material.bothSides = true;
			cube.subMeshes[1].material.bothSides = true;
			cube.subMeshes[2].material.bothSides = true;
			cube.subMeshes[3].material.bothSides = true;
			cube.subMeshes[4].material.bothSides = true;
			cube.subMeshes[5].material.bothSides = true;*/
			
			view.scene.addChild(cube);
			var jBox:JBox = new JBox(new Away3D4Mesh(cube), w, d, h);
			addBody(jBox);
			return jBox;
		}
		public function createSphere(material:MaterialBase, radius:Number = 50, segmentsW:uint = 16, segmentsH:uint = 12, yUp:Boolean = true):RigidBody 
		{
			var sphere:Sphere = new Sphere(material, radius, segmentsW, segmentsH, yUp);
			view.scene.addChild(sphere);
			var jsphere:JSphere = new JSphere(new Away3D4Mesh(sphere), radius);
			addBody(jsphere);
			return jsphere;
		}
		
		public function createTerrain(material : MaterialBase, heightMap : BitmapData, width : Number = 1000, height : Number = 100, depth : Number = 1000, segmentsW : uint = 30, segmentsH : uint = 30, maxElevation:uint = 255, minElevation:uint = 0, smoothMap:Boolean = false):JTerrain {
			var terrainMap:Away3D4Terrain = new Away3D4Terrain(material, heightMap, width, height, depth, segmentsW, segmentsH, maxElevation, minElevation, smoothMap);
			view.scene.addChild(terrainMap);
			
			var terrain:JTerrain = new JTerrain(terrainMap);
			addBody(terrain);
			
			return terrain;
		}
		
		public function createMesh(skin:Mesh,initPosition:Vector3D,initOrientation:Matrix3D,maxTrianglesPerCell:int = 10, minCellSize:Number = 10):JTriangleMesh{
			var mesh:JTriangleMesh=new JTriangleMesh(new Away3D4Mesh(skin),initPosition,initOrientation,maxTrianglesPerCell,minCellSize);
			addBody(mesh);
			
			return mesh;
		}
	}
}
