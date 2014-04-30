/**
* 
* I am a helper object that wraps the print helper.  Instead of returning
* text, I accumulate it in a variable that can be retreived at the end.	 
*
**/
component extends="Print" {

	print = new Print();
	// TODO-- actually use a String Buffer
	result = '';
		
	// Reset the result
	function clear(  ) {
		result = '';		
	}
	
	// Retrieve the current text that has been accumulated
	function getResult(  ) {
		return result;
	}
		
	// Proxy through any methods to the actual print helper
	function onMissingMethod( missingMethodName, missingMethodArguments ) {
		result &= super.onMissingMethod( missingMethodName, missingMethodArguments );
	}
	
}