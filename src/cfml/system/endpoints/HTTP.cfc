/**
*********************************************************************************
* Copyright Since 2014 CommandBox by Ortus Solutions, Corp
* www.coldbox.org | www.ortussolutions.com
********************************************************************************
* @author Brad Wood, Luis Majano, Denny Valliant
*
* I am the HTTP endpoint.  I get packages from an HTTP URL.
*/
component accessors="true" implements="IEndpoint" singleton {
		
	// DI
	property name="consoleLogger"			inject="logbox:logger:console";
	property name="tempDir" 				inject="tempDir@constants";
	property name="artifactService" 		inject="ArtifactService";
	property name="fileEndpoint"			inject="commandbox.system.endpoints.File";
	property name="progressableDownloader" 	inject="ProgressableDownloader";
	property name="progressBar" 			inject="ProgressBar";
	
	// Properties
	property name="namePrefixes" type="string";
	
	function init() {
		setNamePrefixes( 'HTTP' );
		return this;
	}
		
	public string function resolvePackage( required string package, boolean verbose=false ) {
		
		// TODO: Add artifacts caching
		
		var fileName = 'temp#randRange( 1, 1000 )#.zip';
		var fullPath = tempDir & '/' & fileName;		
		
		// Download File
		var result = progressableDownloader.download(
			getNamePrefixes() & ':' & package, // URL to package
			fullPath, // Place to store it locally
			function( status ) {
				progressBar.update( argumentCollection = status );
			},
			function( newURL ) {
				consoleLogger.info( "Redirecting to: '#arguments.newURL#'..." );
			}
		);
		
		// Defer to file endpoint
		return fileEndpoint.resolvePackage( fullPath, arguments.verbose );
		
	}

	public function getDefaultName( required string package ) {
		
		// strip query string
		var baseURL = listFirst( arguments.package, '?' );
		
		// Github zip downloads tend to be called useless things like "master"
		// https://github.com/Ortus-Solutions/commandbox-docs/archive/master.zip
		if( baseURL contains 'github.com' ) { 
			// Ortus-Solutions/commandbox-docs/archive/master.zip
			var path = mid( baseURL, findNoCase( 'github.com', baseURL ) + 10, len( baseURL ) );
			if( listLen( path, '/' ) >= 2 ) {
				// commandbox-docs
				return listGetAt( path, 2, '/' );				
			}
		}		
		
		// Find last segment of URL (may or may not be a file)
		var fileName = listLast( baseURL, '/' );
		
		// Check for file extension in URL
		if( listLast( fileName, '.' ) == 'zip' ) {
			return listFirst( fileName, '.' );
		}
		return reReplaceNoCase( arguments.package, '[^a-zA-Z0-9]', '', 'all' );
	}

}