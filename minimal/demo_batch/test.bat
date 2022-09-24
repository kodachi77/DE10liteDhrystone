@set SHELLOPTS=igncr
@set CYGWIN=nodosfilewarning

@set QUARTUS_BIN=%QUARTUS_ROOTDIR%\bin
@if not exist "%QUARTUS_BIN%" set QUARTUS_BIN=%QUARTUS_ROOTDIR%\bin64

@%QUARTUS_BIN%\quartus_pgm.exe -m jtag -c 1 -o "p;Embed.sof"

@set SOPC_BUILDER_PATH=%SOPC_KIT_NIOS2%+%SOPC_BUILDER_PATH% 
@"%QUARTUS_BIN%\cygwin\bin\bash.exe" --rcfile ".\test.sh" 

pause
