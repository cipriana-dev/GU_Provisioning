REM md "c:\program files\BGInfo" >> c:\gu\logs\bginfo.txt
copy %~dp0*.* "c:\program files\BGInfo" >> c:\gu\logs\bginfoconfig.txt
copy %~dp0GU_DefaultBG.lnk "c:\programdata\Microsoft\Windows\Start Menu\Programs\Startup" >> c:\gu\logs\bginfoconfig.txt
