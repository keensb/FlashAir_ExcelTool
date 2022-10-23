package com {
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	
	
	
	public class File_Open extends MovieClip {
		
		private var file: File = new File();
		
		public function File_Open() {
			x = 40;
			y = 120;
			
			
			//var file:File = new File(); 
			file.addEventListener(Event.SELECT, dirSelected);
			file.addEventListener(FileListEvent.SELECT_MULTIPLE, filesSelected);
			//file.browseForDirectory("Select a directory"); //打开文件夹浏览器窗口的同时, 在窗口上显示文字提示 "Select a directory"
			btn.addEventListener(MouseEvent.CLICK, this.openHandler);
		
		}
		
		private function openHandler(evt: MouseEvent): void {
			file.browseForDirectory("Select a directory"); //打开一个文件夹, 在窗口上显示文字提示 "Select a directory"
		
			// file.browseForOpen
			// file.browseForSave("请选择保存位置")//单选并保存 同名文件会弹出提示 询问是否替换 ???不知道有什么用
		
		
		
			// browseForOpenMultiple();//多选
			//var txtFilter:FileFilter = new FileFilter("Text", "*.as;*.css;*.html;*.txt;*.xml");
			//file.browseForOpenMultiple("选择若干文件", [txtFilter]);
		
		
		
		
		
		/*//保存文件到当前文件夹
		   var file: File = new File(File.applicationDirectory.nativePath+"/test2.zip");
		
		   var fs: FileStream = new FileStream();
		   fs.open(file, FileMode.WRITE);
		   fs.writeBytes(data);
		   fs.close();
		 */
		
		}
		
		
		private function dirSelected(e: Event): void {
			
			txt.text = file.nativePath;
			var list = file.getDirectoryListing(); //打开了一个文件夹 此时 file 就是文件夹实例 通过 getDirectoryListing() 方法读取文件夹下的所有 子 File 实例
			
			for (var i = 0; i < list.length; i++) {
				trace(list[i].type); // 一般子文件 type 的格式是 ".后缀名"  例如 .xml  .json  .jpg  ; 如果 是子文件夹 则没有 type 属性, 返回值是 null
			}
		
		
		}
		
		private function filesSelected(e: FileListEvent): void {
			
			trace(e.files);
			
			for (var i = 0; i < e.files.length; i++) {
				trace(e.files[i].nativePath);
			}
		
		}
	}
}
