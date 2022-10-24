/**关于窗体的设置 例如主题文字、禁止改变宽高、禁止最大化等 在 exec-app.xml里配置**/

/**小技巧  ctrl+alt+/ 自动补完单词    alt+/ 出现提示代码提示或自动import类包      综合以上: 先输入 Mous  再按下 ctrl+alt+/  自动完成单词 MouseEvent ,然后按下 alt+/  自动import flash.events.MouseEvent  **/
package {
	import com.*;


	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import fl.controls.ComboBox;

	public class exec extends Sprite {
		private var view: *;

		public function exec() {

			if (stage) {
				start();
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, start);
			}
		}

		private function start(e: Event = null): void {
			//addChild(new File_Open());//打开文件夹浏览器窗口
			//addChild(new Encrypt_Files());//混淆工具
			view = addChild(new ExcelToJson_Export()); //从excel数据导出json文件
			cb.addEventListener(Event.CHANGE, cbHandler);
			
		}


		private function cbHandler(e: Event): void {
			var cb: * = e.currentTarget;

			switch (cb.selectedIndex) {
				case 0:
					removeChild(view);
					view = addChild(new ExcelToJson_Export());
					break;
				case 1:
					removeChild(view);
					view = addChild(new Encrypt_Files());
					break;

			}
		}

	}
}


