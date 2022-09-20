# Documentation home: https://github.com/engrit-illinois/handy-log-functions
# By mseng3

# To prevent anyone blindly running this file as a script:
Exit



# --------------------------------------------------------
# Parameters used by the primary log function
# --------------------------------------------------------

# Logging parameters
# If you're making a module, you can use this param block, otherwise you can take them out of the param() and just make them global variables.
param(
	# ":ENGRIT:" will be replaced with "c:\engrit\logs\$($MODULE_NAME)_:TS:.csv"
	# ":TS:" will be replaced with start timestamp
	[string]$Csv,
		
	# ":ENGRIT:" will be replaced with "c:\engrit\logs\$($MODULE_NAME)_:TS:.log"
	# ":TS:" will be replaced with start timestamp
	[string]$Log,

	# This logging is designed to output to the console (Write-Host) by default
	# This switch will silence the console output
	[switch]$NoConsoleOutput,
	
	# If you'd rather the console logging be OFF by default, use this instead, and replace the logic as necessary in the function
	#[switch]$Loud,
	
	[string]$Indent = "    ",
	[string]$LogFileTimestampFormat = "yyyy-MM-dd_HH-mm-ss",
	[string]$LogLineTimestampFormat = "[HH:mm:ss] ", # Minimal timestamp
	#[string]$LogLineTimestampFormat = "[yyyy-MM-dd HH:mm:ss:ffff] ", # Full timestamp
	#[string]$LogLineTimestampFormat = $null, # No timestamp
	
	[int]$Verbosity = 0
)

# Logic to determine final log filename
$MODULE_NAME = "Module-Name"
$ENGRIT_LOG_DIR = "c:\engrit\logs"
$ENGRIT_LOG_FILENAME = "$($MODULE_NAME)_:TS:"
$START_TIMESTAMP = Get-Date -Format $LogFileTimestampFormat

if($Log) {
	$Log = $Log.Replace(":ENGRIT:","$($ENGRIT_LOG_DIR)\$($ENGRIT_LOG_FILENAME).log")
	$Log = $Log.Replace(":TS:",$START_TIMESTAMP)
}
if($Csv) {
	$Csv = $Csv.Replace(":ENGRIT:","$($ENGRIT_LOG_DIR)\$($ENGRIT_LOG_FILENAME).csv")
	$Csv = $Csv.Replace(":TS:",$START_TIMESTAMP)
}



# --------------------------------------------------------
# Primary log function
# --------------------------------------------------------

function log {
	param (
		[Parameter(Position=0)]
		[string]$Msg = "",
		
		# Replace this value with whatever the default value of the full log file path should be
		[string]$Log = $Log,

		[int]$L = 0, # level of indentation
		[int]$V = 0, # verbosity level

		[ValidateScript({[System.Enum]::GetValues([System.ConsoleColor]) -contains $_})]
		[string]$FC = (get-host).ui.rawui.ForegroundColor, # foreground color
		[ValidateScript({[System.Enum]::GetValues([System.ConsoleColor]) -contains $_})]
		[string]$BC = (get-host).ui.rawui.BackgroundColor, # background color

		[switch]$E, # error
		[switch]$NoTS, # omit timestamp
		[switch]$NoNL, # omit newline after output
		[switch]$NoConsole, # skip outputting to console
		[switch]$NoLog # skip logging to file
	)
	if($E) { $FC = "Red" }

	$ofParams = @{
		"FilePath" = $Log
		"Append" = $true
	}
	
	$whParams = @{}
	
	if($NoNL) {
		$ofParams.NoNewLine = $true
		$whParams.NoNewLine = $true
	}
	
	if($FC) { $whParams.ForegroundColor = $FC }
	if($BC) { $whParams.BackgroundColor = $BC }

	# Custom indent per message, good for making output much more readable
	for($i = 0; $i -lt $L; $i += 1) {
		$Msg = "$Indent$Msg"
	}

	# Add timestamp to each message
	# $NoTS parameter useful for making things like tables look cleaner
	if(-not $NoTS) {
		if($LogLineTimestampFormat) {
			$ts = Get-Date -Format $LogLineTimestampFormat
		}
		$Msg = "$ts$Msg"
	}

	# Each message can be given a custom verbosity ($V), and so can be displayed or ignored depending on $Verbosity
	# Check if this particular message is too verbose for the given $Verbosity level
	if($V -le $Verbosity) {

		# Check if this particular message is supposed to be logged
		if(-not $NoLog) {

			# Check if we're allowing logging
			if($Log) {

				# Check that the logfile already exists, and if not, then create it (and the full directory path that should contain it)
				if(-not (Test-Path -PathType "Leaf" -Path $Log)) {
					New-Item -ItemType "File" -Force -Path $Log | Out-Null
					log "Logging to `"$Log`"."
				}
				
				$Msg | Out-File @ofParams
			}
		}

		# Check if this particular message is supposed to be output to console
		if(-not $NoConsole) {

			# Check if we're allowing console output at all
			if(-not $NoConsoleOutput) {
			
			# If using the $Loud parameter, use this instead of the above if():
			#if($Loud) {
				
				Write-Host $Msg @whParams
			}
		}
	}
}



# -----------------------------------------------------------------------------
# Function for logging just the useful bits of error records in a readable format
# Designed for use with above log() function
# https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-exceptions?view=powershell-7.1
# -----------------------------------------------------------------------------

function Log-Error($e, $L=0) {
	$msg = $e.Exception.Message
	$inv = ($e.InvocationInfo.PositionMessage -split "`n")[0]
	log $msg -L $l -E
	log $inv -L ($L + 1) -E
}

try {
	[System.IO.File]::ReadAllText( '\\test\no\filefound.log')
}
catch {
	log "Custom message explaining what happened in English" -L 1
	Log-Error $_ 2
}



# -----------------------------------------------------------------------------
# Handy function for logging whole objects, while still preserving custom timestamp and indentation markup
# Designed for use with above log() function
# -----------------------------------------------------------------------------

function Log-Object {
	param(
		[PSObject]$Object,
		[string]$Format = "Table",
		[int]$L = 0,
		[int]$V = 0,
		[switch]$NoTs,
		[switch]$E
	)
	if(!$NoTs) { $NoTs = $false }
	if(!$E) { $E = $false }

	switch($Format) {
		"List" { $string = ($object | Format-List | Out-String) }
		#Default { $string = ($object | Format-Table | Out-String) }
		Default { $string = ($object | Format-Table -AutoSize | Out-String) }
	}
	$string = $string.Trim()
	$lines = $string -split "`n"

	$params = @{
		L = $L
		V = $V
		NoTs = $NoTs
		E = $E
	}

	foreach($line in $lines) {
		$params["Msg"] = $line
		log @params
	}
}



# -----------------------------------------------------------------------------
# Handy code for outputting ENTIRE error records in a readable format
# https://stackoverflow.com/a/57548069/994622
# -----------------------------------------------------------------------------

try {
	[System.IO.File]::ReadAllText( '\\test\no\filefound.log')
}
catch {
	Write-Host ($_ | ConvertTo-Json)
}

