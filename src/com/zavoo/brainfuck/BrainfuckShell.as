package com.zavoo.brainfuck
{
	import com.zavoo.brainfuck.events.CharInEvent;
	import com.zavoo.brainfuck.events.CharOutEvent;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.TextArea;

	public class BrainfuckShell extends TextArea
	{
		
		public static const RUN_COMMAND:String = 'Brainfuck run command';
		
		private var instructions:String = '** type \'bf\' to execute code **';
		private var shellPrompt:String = 'bf@labs.zavoo.com:~$';
		
		private var cursorTimer:Timer = new Timer(500);
		private var showCursor:Boolean = false;
		private const CURSOR_CHAR:String = '|';
			
		private var running:Boolean = false;
		
		private var userInput:String = '';
		private var history:String = '';
		
		private var runInput:Array = new Array();;
		private var runInputQueue:Array = new Array();
		
		private var brainfuckInterpreter:BrainfuckInterpreter = new BrainfuckInterpreter();
		
		public function BrainfuckShell()
		{
			super();
			
			super.editable = false;
			history = instructions + "\n\n" + shellPrompt;
			this.updateText();
			
			this.setStyle('color', '#00FF00');
			this.setStyle('backgroundColor','#000000');
			this.setStyle('fontSize','12');
			
			this.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			this.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			this.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			
			brainfuckInterpreter.addEventListener(CharInEvent.CHAR_IN_EVENT, onCharIn);
			brainfuckInterpreter.addEventListener(CharOutEvent.CHAR_OUT_EVENT, onCharOut);
			
			brainfuckInterpreter.addEventListener(BrainfuckInterpreter.EXECUTION_END, onExecutionEnd);
			
			cursorTimer.addEventListener(TimerEvent.TIMER, updateText);
		}
		
		private function onExecutionEnd(event:Event):void {
			this.running = false;
			this.history += "\n" + this.shellPrompt;
			this.updateText();
		}
		
		private function onCharIn(event:CharInEvent):void {
			if (runInput.length > 0) {
				event.returnChar(runInput.shift());
			}
			else {
				this.runInputQueue.push(event);
			}
		}
		
		private function onCharOut(event:CharOutEvent):void {
			this.history += event.char;
			this.updateText();
		}
		
		private function onFocusIn(event:FocusEvent):void {
			cursorTimer.start();
			this.showCursor = true;
			this.updateText();
		}
		
		private function onFocusOut(event:FocusEvent):void {
			cursorTimer.stop();
			this.showCursor = false;
			this.updateText();
		}
		
		public function runCode(code:String):void {
			this.running = true;
			this.history += "\n";
			this.updateText();
			this.brainfuckInterpreter.interpret(code);			
		}
		
		private function updateText(event:Event = null):void {
			if (running) {
				this.text = history;
			}
			else {
				if (event != null) {
					this.showCursor = !this.showCursor;
				}
				this.text = history + userInput;
				if (showCursor) {
					this.text += CURSOR_CHAR;					
				}
			}
			this.verticalScrollPosition = this.maxVerticalScrollPosition;
		}
		
		
		private function onKeyUp(event:KeyboardEvent):void {
			if (running) {
				if (event.charCode != 0) {
					if (this.runInputQueue.length == 0) {
						this.runInput.push(String.fromCharCode(event.charCode));
					}
					else {
						var charInEvent:CharInEvent = this.runInputQueue.shift();
						charInEvent.returnChar(String.fromCharCode(event.charCode));
					}
				} 
			}
			else {
				switch(event.charCode) {
					case 8: //Backspace
					case 127: //Delete
						if (this.userInput.length > 0) {
							this.userInput = this.userInput.substr(0, (this.userInput.length - 1));
						}
						break;
					case 13: //Return						
						this.handleReturn();
						break;
						
					default:
						if ((event.charCode > 31) && (event.charCode < 126)) {
							this.userInput += String.fromCharCode(event.charCode);
						}
				}
				this.updateText();
			}
		}
		
		private function handleReturn():void {
			this.history += userInput + "\n";			
			switch(userInput) {
				case 'clear':
					this.history = this.shellPrompt;
					break;
				case 'bf':
				case 'run':
					this.dispatchEvent(new Event(RUN_COMMAND,true));					
					break;
				case '':
					this.history += this.shellPrompt;
					break;
				default:
					this.history += "\nCommand '" + userInput + "' is not known\n";
					this.history += this.shellPrompt;
					break;
			}
			
			userInput = '';
			
			
		}
		
		/**
		 * @private
		 **/
		override public function set editable(value:Boolean):void {
			//Do nothing
		} 
		
		
		
	}
}