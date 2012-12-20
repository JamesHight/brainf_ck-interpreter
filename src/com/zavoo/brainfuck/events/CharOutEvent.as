package com.zavoo.brainfuck.events
{
	import flash.events.Event;

	public class CharOutEvent extends Event
	{
		public static const CHAR_OUT_EVENT:String = 'Brainfuck char out event';
		public var char:String;
		public function CharOutEvent(char:String)
		{
			super(CHAR_OUT_EVENT, true, false);
			this.char = char;
			
		}
		
	}
}