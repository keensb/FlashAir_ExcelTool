package com {


	import com.as3xls.xls.ExcelFile;
	import com.as3xls.xls.Sheet;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	public class ExcelToJson_Export extends MovieClip {
		private var file: * = new File();
		private var fileList: Array;

		private var _excelFile: ExcelFile;
		private var _sheet: Sheet;
		private var _xls: ExcelFile;
		private var openDic: Dictionary;

		public function ExcelToJson_Export() {
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

			btn.addEventListener(MouseEvent.CLICK, exportHandler);

			//new TextField().appendText(
			//txt.appendText("aa\n")
			//txt.appendText("bb\n")


			//			var file2:File = new File("F:/flexAir/test.xls");
			//			
			//			var stream:FileStream = new FileStream();
			//			stream.open(file2,FileMode.READ);
			//			var ba:ByteArray = new ByteArray();
			//			stream.readBytes(ba);
			//			stream.close();
			//			
			//			_xls = new ExcelFile();
			//			_xls.loadFromByteArray(ba);
			//			var sheet:Sheet = _xls.sheets[0];
			//			
			//			var rows:int = sheet.rows;//竖直方向上的数量
			//			var cols:int = sheet.cols;//水平方向上的数量
			//			trace("sheet.values: ",sheet.values)
			//			trace("rows and cols:", rows + "   " + cols);
			//			trace("sheet.getCell(0,1):",sheet.getCell(0,1));//sheet.getCell(y,x) 读取信息 左上为 (0,0)


		}

		private function openHandler(evt: MouseEvent): void {
			var excelFilter: FileFilter = new FileFilter("excel文件 *.xls", "*.xls");
			file.browseForOpenMultiple("选择要处理的.xls文件", [excelFilter]);
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
			var excleCount = 0;
			var otherCount = 0;
			for each (var _file: File in dropfiles) {
				if (_file.type == "null" || _file.type == null) { //不支持文件夹导入
					dirCount++;
				}
				if (_file.extension == "xls") {
					excleCount++;
				}
				else {
					otherCount++;
				}
			}
			if (dirCount >= dropfiles.length) { //如果拖拽对象全都是文件夹 禁止释放; 如果是文件夹与文件混合, 则允许释放 在onDrop 中进行过滤处理
				txt.text = "哼╭(╯^╰)╮ 本工具才不吃文件夹"
				return;
			}
			if (excleCount == 0) {
				txt.text = "吼吼 (╯‵□′)╯︵┻━┻ ,我要的是.xls文件!!"
				return;
			}
			if (dirCount >= 1) { //如果拖拽对象全都是文件夹 禁止释放; 如果是文件夹与文件混合, 则允许释放 在onDrop 中进行过滤处理
				txt.text = ".xls文件与文件夹混合拖入时, 文件夹将被忽略"
			}
			else if (otherCount >= 1) {
				txt.text = ".xls文件与其他文件混合拖入时, 其他文件将被忽略"
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
				if (_file.type != "null" && _file.type != null && _file.extension == "xls") { //过滤掉文件夹 筛选出 .xls
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
			txt.text = "点击此文本打开文件夹浏览器查找.xls文件 或直接拖拽.xls文件到此位置   注意:不支持.xlsx格式(好吧, 我告诉你因为这个工具的扩展类包太旧了并且已停止更新)";
			btn.enabled = false;
			fileList = [];
		}

		public function exportHandler(e: MouseEvent): void {
			btn.enabled = false;

			var file:File = new File(File.applicationDirectory.nativePath + "/export_json");
			//file.exists = true or false  这个路径是否有效
			if(file.exists &&  file.getDirectoryListing() &&  file.getDirectoryListing().length > 0){
				file.addEventListener(Event.COMPLETE, deleteCompleteHandler);
				file.deleteDirectoryAsync(true);//先清空旧文件夹(整个删除) 再重新导出  保证每次导出的文件全都是最新的
			}
			else{
				openDic = new Dictionary();
				exportLoop();
			}
		}
		public function deleteCompleteHandler(e:Event):void{
			openDic = new Dictionary();
			exportLoop();
		}

		private var currentvar_file: File;

		private function exportLoop(): void {
			if (!fileList || fileList.length == 0) {
				return;
			}

			currentvar_file = fileList.shift();

			var stream: FileStream = new FileStream();

			openDic[stream] = currentvar_file.name.split(".")[0]; //stream和file地址绑定键值对
			//trace("currentvar_file.name =",currentvar_file.name)
			stream.addEventListener(Event.COMPLETE, completeHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);

			stream.openAsync(currentvar_file, FileMode.READ); //异步打开, 防阻塞

		}

		private function completeHandler(e: Event): void {
			var stream: FileStream = e.currentTarget as FileStream;

			var ba: ByteArray = new ByteArray();
			stream.readBytes(ba);
			stream.close();

			var _xls: ExcelFile = new ExcelFile();
			_xls.loadFromByteArray(ba);
			var object: Object;
			for each (var sheet: Sheet in _xls.sheets) {


				var rows: int = sheet.rows; //竖直方向上的数量
				var cols: int = sheet.cols; //水平方向上的数量

				//trace("sheet.values: ",sheet.values.length, sheet.values[0] == null,"   ",sheet.values[0]);//sheet.values[0] 就是最上面的字段
				//trace("行数", sheet.rows)

				if (sheet.rows <= 1) {
					continue;
				}
				if (!object) {
					object = {};
				}

				var index = _xls.sheets.getItemIndex(sheet) + 1;
				object["sheet" + index] = {};
				var _sheetObj: Object = object["sheet" + index];
				_sheetObj.idList = []; //id是用于索引的基本key 用个数组保存起来 

				var r, c: Number;
				for (r = 1; r < sheet.rows; r++) {
					var v: * = sheet.getCell(r, 0).value;
					var n: Number = Number(v); //id 必须是正整数形式
					var _id: * = isNaN(n) ? v : n; //尽可能以数字的形式保存数据 以方便数值的计算

					if (_sheetObj.idList.indexOf(_id) >= 0) {
						throw new Error(openDic[stream] + ".xls sheet" + index + " 出现重复的id: " + _id);
					}

					_sheetObj.idList.push(_id);
					_sheetObj[_id] = {};

					var _idObj: Object = _sheetObj[_id];
					for (c = 1; c < sheet.cols; c++) {
						var key: String = String(sheet.getCell(0, c));
						v = sheet.getCell(r, c).value;
						n = Number(v);
						var value: * = isNaN(n) ? v : n; //尽可能以数字的形式保存数据 以方便数值的计算
						if (_idObj[key]) {
							throw new Error(openDic[stream] + ".xls sheet" + index + " 出现重复的key: " + key);
						}

						_idObj[key] = value;
					}
				}
					//trace("_sheet.idList =",_sheetObj.idList);




					//var rows:int = sheet.rows;//竖直方向上的数量
					//var cols:int = sheet.cols;//水平方向上的数量



					//JSON.stringify(

					//trace("rows and cols:", rows + "   " + cols);
					//trace("sheet.getCell(0,1):",sheet.getCell(0,1));//sheet.getCell(y,x) 读取信息 左上为 (0,0)

			}

			//trace(openDic[stream] + "json:", JSON.stringify(object));


			var file: File = new File(File.applicationDirectory.nativePath + "/export_json/" + openDic[stream] + ".json");
			var fs: FileStream = new FileStream();
			fs.open(file, flash.filesystem.FileMode.WRITE);
			fs.writeUTFBytes(JSON.stringify(object));
			fs.close();



			if (fileList.length > 0) {
				exportLoop();
			}
			else {
				tip.gotoAndPlay(1);
			}




			//			_mbytes = _xls.saveToByteArray();//目前只能保存单个sheet数据
			//			var file:File = File.desktopDirectory.resolvePath("data.xls");
			//			var fs:FileStream = new FileStream();
			//			fs.open(file, flash.filesystem.FileMode.WRITE);
			//			fs.writeBytes(_mbytes);
			//			fs.close();
		}

		private function errorHandler(e: IOErrorEvent): void {
			if (fileList.length > 0) {
				exportLoop();
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

			btn.removeEventListener(MouseEvent.CLICK, exportHandler);

		}


	}
}
