package away3d.loading
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.events.ResourceEvent;
	import away3d.loading.assets.AssetType;
	import away3d.loading.library.AssetLibrary;
	import away3d.loading.parsers.AWD2Parser;
	import away3d.loading.parsers.ParserBase;
	import away3d.materials.ColorMaterial;
	
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	
	public class Loader3D extends ObjectContainer3D
	{
		private var _useAssetLib : Boolean;
		private var _assetLibId : String;
		
		public function Loader3D(useAssetLibrary : Boolean = true, assetLibraryId : String = null)
		{
			super();
			
			_useAssetLib = useAssetLibrary;
			_assetLibId = assetLibraryId;
		}
		
		
		public function load(req : URLRequest, ignoreDependencies : Boolean = false, parser : ParserBase = null, namespace : String = null) : void
		{
			if (_useAssetLib) {
				var lib : AssetLibrary;
				
				lib = AssetLibrary.getInstance(_assetLibId);
				lib.addEventListener(ResourceEvent.ASSET_RETRIEVED, onAssetRetrieved);
				lib.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);
				lib.load(req, ignoreDependencies, parser, namespace);
			}
			else {
				var loader : AssetLoader = new AssetLoader();
				loader.addEventListener(ResourceEvent.ASSET_RETRIEVED, onAssetRetrieved);
				loader.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);
				loader.load(req, parser);
			}
		}
		
		
		public function parseData(data : *, ignoreDependencies : Boolean = true, parser : ParserBase = null, namespace : String = null) : void
		{
			if (_useAssetLib) {
				var lib : AssetLibrary;
				
				lib = AssetLibrary.getInstance(_assetLibId);
				lib.addEventListener(ResourceEvent.ASSET_RETRIEVED, onAssetRetrieved);
				lib.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);
				lib.parseData(data, ignoreDependencies, parser, namespace);
			}
			else {
				var loader : AssetLoader = new AssetLoader();
				loader.addEventListener(ResourceEvent.ASSET_RETRIEVED, onAssetRetrieved);
				loader.addEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);
				loader.parseData(data, parser);
			}
		}
		
		
		public static function enableParser(parserClass : Class) : void
		{
			AssetLoader.enableParser(parserClass);
		}
		
		
		public static function enableParsers(parserClasses : Vector.<Class>) : void
		{
			AssetLoader.enableParsers(parserClasses);
		}
		
		
		
		private function onAssetRetrieved(ev : ResourceEvent) : void
		{
			var type : String = ev.asset.assetType;
			if (type == AssetType.CONTAINER) {
				this.addChild(ObjectContainer3D(ev.asset));
			}
			else if (type == AssetType.MESH) {
				var mesh : Mesh = Mesh(ev.asset);
				if (mesh.parent == null)
					this.addChild(mesh);
			}
			
			this.dispatchEvent(ev.clone());
		}
		
		
		private function onResourceRetrieved(ev : ResourceEvent) : void
		{
			var dispatcher : EventDispatcher;
			
			dispatcher = EventDispatcher(ev.currentTarget);
			dispatcher.removeEventListener(ResourceEvent.ASSET_RETRIEVED, onAssetRetrieved);
			dispatcher.removeEventListener(ResourceEvent.RESOURCE_RETRIEVED, onResourceRetrieved);
			
			this.dispatchEvent(ev.clone());
		}
	}
}