package com {
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	public class Encrypt_Files extends MovieClip {
		private var file: * = new File();
		private var fileList: Array;
		
		public function Encrypt_Files() {
			x = 40;
			y = 120;
			
			addEventListener(Event.ADDED_TO_STAGE, start);
			addEventListener(Event.REMOVED_FROM_STAGE, dispose);
		}
		
		public function start(e: Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, start);
			
			block.buttonMode = true;
			file.addEventListener(FileListEvent.SELECT_MULTIPLE, multipleSelected); //FileListEvent.SELECT_MULTIPLE 监听选择单个或复数个文件的事件
			//file.browseForDirectory("Select a directory"); //打开文件夹浏览器窗口的同时, 在窗口上显示文字提示 "Select a directory"
			block.addEventListener(MouseEvent.CLICK, openHandler);
			
			block.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragEnter);
			block.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDrop);
			block.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, onDragExit);
			
			btn.addEventListener(MouseEvent.CLICK, encryptHandler);
		
			//new TextField().appendText(
			//txt.appendText("aa\n")
			//txt.appendText("bb\n")
		
		}
		
		private function openHandler(evt: MouseEvent): void {
			file.browseForOpenMultiple("选择要混淆的文件");
		}
		
		private function multipleSelected(e: FileListEvent): void {
			btn.enabled = true;
			var files = e.files;
			fileList = [];
			txt.text = "";
			for each (var _file: File in files) {
				
				if (_file.type != "null" && _file.type != null) {
					fileList.push(_file);
					
					if (_file != files[files.length - 1]) {
						txt.appendText(_file.nativePath + "\n");
					}
					else {
						txt.appendText(_file.nativePath);
					}
				}
			}
		
		}
		
		public function onDragEnter(event: NativeDragEvent): void {
			//trace("拖入事件");
			//NativeDragManager.acceptDragDrop(this);//拖进窗体后显示允许释放
			var dropfiles: Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			
			/*
			   for each(var _file:File in dropfiles){
			   if(_file.extension != "zip"){//检测 file 的类型才运行释放
			   return;
			   }
			   }
			   NativeDragManager.acceptDragDrop(block);
			 */
			
			btn.enabled = false;
			fileList = [];
			var dirCount: Number = 0;
			for each (var _file: File in dropfiles) {
				if (_file.type == "null" || _file.type == null) { //不支持文件夹导入
					dirCount++;
				}
			}
			if (dirCount >= dropfiles.length) { //如果拖拽对象全都是文件夹 禁止释放; 如果是文件夹与文件混合, 则允许释放 在onDrop 中进行过滤处理
				txt.text = "哼╭(╯^╰)╮ 本工具才不吃文件夹"
				return;
			}
			if (dirCount >= 1) { //如果拖拽对象全都是文件夹 禁止释放; 如果是文件夹与文件混合, 则允许释放 在onDrop 中进行过滤处理
				txt.text = "文件与文件夹混合拖入时, 文件夹将被忽略"
			}
			else {
				txt.text = "在这里释放文件即可"
			}
			NativeDragManager.acceptDragDrop(block); //指定释放位置为组件 block 上方, 当拖拽进来的文件列表中包含zip的时候 允许释放(鼠标移至block上方, 会进行判断, 允许释放时文件icon上的"禁止"符号会消失)
		
		}
		
		
		public function onDrop(event: NativeDragEvent): void {
			//trace("合法释放事件");
			btn.enabled = true;
			fileList = [];
			txt.text = "";
			var dropfiles: Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			
			for each (var _file: File in dropfiles) {
				if (_file.type != "null" && _file.type != null) { //过滤掉文件夹
					fileList.push(_file);
					
					if (_file != dropfiles[dropfiles.length - 1]) {
						txt.appendText(_file.nativePath + "\n");
					}
					else {
						txt.appendText(_file.nativePath);
					}
				}
			}
		}
		
		public function onDragExit(event: NativeDragEvent): void {
			//trace("拖出或非法释放事件");//非法释放 指释放时的 文件类型不符合要求 或者没有释放在指定的组件位置上方, 总之就是没有成功响应 NativeDragEvent.NATIVE_DRAG_DROP
			txt.text = "点击此文本打开文件夹浏览器 或直接拖拽目标文件到此位置";
			btn.enabled = false;
			fileList = [];
		}
		
		public function encryptHandler(e: MouseEvent): void {
			encryptLoop();
		}
		
		private var currentvar_file: File;
		
		private function encryptLoop(): void {
			if (!fileList || fileList.length == 0) {
				return;
			}
			currentvar_file = fileList.shift();
			
			var _urlLoader: URLLoader = new URLLoader();
			
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener(Event.COMPLETE, loaded);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			
			_urlLoader.load(new URLRequest(currentvar_file.nativePath));
		}
		
		private function loaded(e: Event): void {
			
			e.currentTarget.removeEventListener(Event.COMPLETE, loaded);
			var data: ByteArray = e.currentTarget.data as ByteArray; //用二进制数组保持读取的数据
			
			if (!data) {
				if (fileList.length > 0) {
					encryptLoop();
				}
				else {
					tip.gotoAndPlay(1);
				}
				return;
			}
			//下面就是加密算法
			var p: int = data.length / 2; //获取原始数据中间的位置索引
			var b: ByteArray = new ByteArray();
			for (var i: int = 0; i < data.length; i++) {
				var d = data[i];
				
				d += 1; //这个初级demo的混淆算法只是个简单的 +1 , 可以根据需求自定义混淆算法
				if (d > 255) {
					d = d - 255;
				}
				b.writeByte(d);
			}
			
			b.position = 0;
			
			var _name: String = currentvar_file.name.split(".")[0];
			
			var outFile: File = new File(File.applicationDirectory.nativePath + "/export_cfg/" + _name + ".cfg");
			
			var fs: FileStream = new FileStream();
			fs.open(outFile, FileMode.WRITE);
			fs.writeBytes(b);
			fs.close();
			
			btn.enabled = false;
			
			if (fileList.length > 0) {
				encryptLoop();
			}
			else {
				tip.gotoAndPlay(1);
			}
		}
		
		private function errorHandler(e: IOErrorEvent): void {
			if (fileList.length > 0) {
				encryptLoop();
			}
			else {
				tip.gotoAndPlay(1);
			}
		}
		
		private function dispose(e: Event): void {
			removeEventListener(Event.REMOVED_FROM_STAGE, dispose);
			
			file.removeEventListener(FileListEvent.SELECT_MULTIPLE, multipleSelected); //FileListEvent.SELECT_MULTIPLE 监听选择单个或复数个文件的事件
			
			block.removeEventListener(MouseEvent.CLICK, openHandler);
			
			block.removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragEnter);
			block.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDrop);
			block.removeEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, onDragExit);
			
			btn.removeEventListener(MouseEvent.CLICK, encryptLoop);
			
		}
	
	
	}
}
