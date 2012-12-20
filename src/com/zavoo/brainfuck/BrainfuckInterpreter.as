package com.zavoo.brainfuck
{
	import com.zavoo.brainfuck.events.CharInEvent;
	import com.zavoo.brainfuck.events.CharOutEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	public class BrainfuckInterpreter extends EventDispatcher
	{
		public static const EXECUTION_START:String = 'Brainfuck execution start';
		public static const EXECUTION_END:String = 'Brainfuck execution end';
		
		private static const WORKSPACE_LIMIT:uint = 60000;
		
		/**
		 * Code pointer
		 **/ 
		private var codePtr:uint;
		
		/**
		 * ByteArray used to hold working data
		 **/
		private var workspace:ByteArray; 
		
		private var workspaceArray:Array;
		
		/**
		 * Data pointer
		 **/
		private var ptr:uint;
		
		/**
		 * Brainfuck Code
		 **/	
		private var code:String;
		
		public var output:String = '';
		
		public function BrainfuckInterpreter(){
			super(null);
		}
		
		private function reset():void {
			this.code = '';
			this.codePtr = 0;
			this.ptr = 0;
			this.workspace = new ByteArray();
		}
		
		public function interpret(code:String):void {
			this.reset();			
			this.code = code;
			this.dispatchEvent(new Event(EXECUTION_START, true));
			
			this.execute();
					
		}
		
		private function execute():void {
						
			//var executionCount:uint = 0;
			while(codePtr < this.code.length) {				 	
				var codeByte:String = code.charAt(codePtr);		
						
				switch(codeByte) {
					case '>':
						this.incPtr();
						break;
					case '<':
						this.decPtr();
						break;
					case '+':						
						this.incWorkspaceByte();						
						break;
					case '-':
						this.decWorkspaceByte();						
						break;
					case '.':
						this.outputChar();
						break;
					case ',':
						getChar();
						return;
					case '[':
						this.startLoop();
						break;
					case ']':
						this.endLoop();
						break;				
				}	
				if ((codeByte != '[')
					&& (codeByte != ']')) {
					codePtr++;
				}		
				
			}
			
			this.dispatchEvent(new Event(EXECUTION_END, true));			
		}
		
		private function incPtr():void {
			if (this.ptr == WORKSPACE_LIMIT) {
				this.codeError("ptr out of range, cannot increment");
			}
			else {
				this.ptr++;
			}
		}
		
		private function decPtr():void {
			
			if (this.ptr == 0) {
				 this.codeError("ptr out of range, cannot decrement");	  
			}
			else {
				this.ptr--;
			}
		}
		
		private function readWorkspaceByte():uint {
			if (this.workspace[ptr] == undefined) {				
				this.writeWorkspaceByte(0);
			}
			return this.workspace[ptr];
		}
		
		private function writeWorkspaceByte(value:uint):void {
			this.workspace[ptr] = value;
			workspaceArray = this.byteArrayToArray(workspace);
		}
		
		private function incWorkspaceByte():void {
			var byte:uint = this.readWorkspaceByte();
			if (byte == 255) {
				byte = 0;
			}
			else {
				byte++;
			}
			this.writeWorkspaceByte(byte);
		}
		
		private function decWorkspaceByte():void {
			var byte:uint = this.readWorkspaceByte();
			if (byte == 0) {
				byte = 255;
			}
			else {
				byte--;
			}
			this.writeWorkspaceByte(byte);
		}
		
		private function startLoop():void {
			
			
			if (this.readWorkspaceByte() != 0) {
				codePtr++;
			}
			else {
				var tmpPtr:uint = codePtr;
				while (tmpPtr < this.code.length) {
					tmpPtr++;
					var brackets:uint = 0;
					if (code.charAt(tmpPtr) == '[') {
						brackets++;
					}
					if (code.charAt(tmpPtr) == ']') {
						if (brackets == 0) {
							break;
						}
						brackets--;
					}						
				}
				
				if (code.charAt(tmpPtr) == ']') {
					codePtr = tmpPtr + 1;
				}
				else {
					this.codeError("found [ without a corresponding ]"); 
				}
			}
		}
		
		private function endLoop():void {
					
			if (this.readWorkspaceByte() != 0) {		
				var tmpPtr:uint = codePtr;
				while (tmpPtr >= 0) {
					var brackets:uint = 0;				
					if (code.charAt(tmpPtr) == ']') {
						brackets++;
					}
					if (code.charAt(tmpPtr) == '[') {
						if (brackets == 0) {
							break;
						}
						brackets--;
					}
					tmpPtr--;	
				}
				
				if (code.charAt(tmpPtr) == '[') {
					codePtr = tmpPtr + 1;
				}
				else {
					this.codeError("found ] without a corresponding ["); 
				}
				
			}
			else {				
				codePtr++;
			} 
			
		}
		
		private function getChar():void {
			this.dispatchEvent(new CharInEvent(this.returnChar));
		}
		
		private function returnChar(char:String):void {
			this.writeWorkspaceByte(char.charCodeAt(0));
			this.codePtr++;
			this.execute();
		}
		
		private function outputChar():void {
			var byte:uint = this.readWorkspaceByte();
			if (byte > 0) { 
				var char:String = String.fromCharCode(byte);
				this.dispatchEvent(new CharOutEvent(char));
				output += char;
			}
		}
		
		private function codeError(msg:String):void {
			throw new Error('char[' + codePtr.toString() + ']: ' + msg); 
		}
		
		private function byteArrayToArray(byteArray:ByteArray):Array {
			
			var output:Array = new Array();
			for (var i:uint = 0; i < byteArray.length; i++) {
				output.push(byteArray[i] + ': ' + String.fromCharCode(byteArray[i]));
			}	
			return output;
				
		}
		
	}
}