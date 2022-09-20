# Summary
Some handy, feature-rich log functions, intended for use within custom PowerShell modules.  
I frequently re-use this code in my various custom modules, so I gave it a dedicated home here.  

# Usage
See documentation in the code. Making effective use of this function requires understanding the need and the code itself, so I won't go into it in this readme.  

# Template for log parameter README.md documentation
The following markdown can be copied into a new module's README and customized to suit, depending on how you implement the log function code.

### -Log \<string\>
Optional string.  
The full path of a text file to log to.  
If omitted, no log will be created.  
If `:TS:` is given as part of the string, it will be replaced by a timestamp of when the script was started, with a format specified by `-LogFileTimestampFormat`.  
Specify `:ENGRIT:` to use a default path (i.e. `c:\engrit\logs\<Module-Name>_<timestamp>.log`).  

### -Csv \<string\>
Optional string.  
The full path of a CSV file to output resulting data to.  
If omitted, no CSV will be created.  
If `:TS:` is given as part of the string, it will be replaced by a timestamp of when the script was started, with a format specified by `-LogFileTimestampFormat`.  
Specify `:ENGRIT:` to use a default path (i.e. `c:\engrit\logs\<Module-Name>_<timestamp>.csv`).  

### -NoConsoleOutput
Optional switch.  
If specified, progress output is not logged to the console.  

### -Loud
_Note: This is an alternative to -NoConsoleOutput, see comments in the code and use one or the other._  
Optional switch.  
If specified, progress output is logged to the console.

### -Indent \<string\>
Optional string.  
The string used as an indent, when indenting log entries.  
Default is four space characters.  

### -LogFileTimestampFormat \<string\>
Optional string.  
The format of the timestamp used in filenames which include `:TS:`.  
Default is `yyyy-MM-dd_HH-mm-ss`.  

### -LogLineTimestampFormat \<string\>
Optional string.  
The format of the timestamp which prepends each log line.  
Default is `[HH:mm:ss:ffff]⎵`.  

### -Verbosity \<int\>
Optional integer.  
The level of verbosity to include in output logged to the console and logfile.  
Currently not significantly implemented.  
Default is `0`.  
<br />
<br />

# Notes
- By mseng3. See my other projects here: https://github.com/mmseng/code-compendium.
