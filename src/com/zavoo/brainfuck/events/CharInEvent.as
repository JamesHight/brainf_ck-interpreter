package com.zavoo.brainfuck.events
{
	import flash.events.Event;

	public class CharInEvent extends Event
	{
		public static const CHAR_IN_EVENT:String = 'Brainfuck char in event';
		
		private var returnFunction:Function;
		public function CharInEvent(returnFunction:Function) {
			super(CHAR_IN_EVENT, true, false);
			this.returnFunction = returnFunction;
		}
		
		public function returnChar(char:String):void {
			returnFunction.apply(null,[char]);
		}
		
	}
}