@echo off
:StartingAtTheTop
echo starting network thingy
netsh wlan show networks | findstr /i "SSID"
set /p WifiName="Enter the saved Wifi Name: "
echo %WifiName%


echo %WifiName%
netsh wlan show networks |  findstr %WifiName% || goto RIP
netsh wlan show networks |  findstr %WifiName% && echo Found it


:ConnectionCheck
rem ping google.com
ping -n 1 google.com | findstr TTL && goto LinkEstablishedNice
ping -n 1 google.com | findstr TTL || goto Reconnect

:LinkEstablishedNice
color 0a
@timeout /t 60
cls
goto GetIpLocal

:Reconnect
color c0 
echo        //_No_connection_:_%WifiName%\\ 
echo        //_____Disconnecting_____\\
netsh wlan disconnect
timeout /t 3
echo        //____Other_networtks____\\
netsh wlan show networks | findstr /i "SSID"
netsh wlan connect %WifiName%
echo        //____Establishing_Link___\\
ping google.com
goto ConnectionCheck

:GetIpLocal
setlocal
setlocal enabledelayedexpansion
rem thx to DavidPostill for this cool bit from https://superuser.com/questions/1034471/how-do-i-extract-the-ipv4-ip-address-from-the-output-of-ipconfig
for /f "usebackq tokens=*" %%a in (`ipconfig ^| findstr /i "ipv4"`) do (
  rem we have for example "IPv4 Address. . . . . . . . . . . : 192.168.1.69"
  rem split on : and get 2nd token
  for /f delims^=^:^ tokens^=2 %%b in ('echo %%a') do (
    rem we have " 192.168.1.69"
    rem split on . and get 4 tokens (octets)
    for /f "tokens=1-4 delims=." %%c in ("%%b") do (
      	set _o1=%%c
      	set _o2=%%d
      	set _o3=%%e
      	set _o4=%%f
      	rem strip leading space from first octet
      	rem strip leading space from first octet
      	set _3octet=!_o1:~1!.!_o2!.!_o3!.
      	rem echo !_3octet!
	echo My Local IP is%%b	     	
      )
    )
  )
rem add additional commands here
endlocal
timeout /t 4
goto GetLAN

:GetLAN
cls
echo .
arp -a | findstr dynamic
echo //____Ping_test___\\

FOR /L %%G IN (1,1,254) DO (
	echo //__%%G::254___\\
	ping -n 1 192.168.1.%%G | findstr TTL && echo 192.168.1.%%G
)
echo //__Ping_test_end_\\
arp -a
goto ConnectionCheck

:RIP
echo party is over

