@echo off
set ip="IP Address"
for /f "tokens=3 delims=: " %%I in ('netsh interface IPv4 show addresses "MajorAmariVPN" ^| findstr /C:%ip%') do set ip_address=%%I
route add 63.0.0.0 mask 255.0.0.0 %ip_address%
route add 74.0.0.0 mask 255.0.0.0 %ip_address%
route add 188.0.0.0 mask 255.0.0.0 %ip_address%
route add 216.0.0.0 mask 255.0.0.0 %ip_address%

exit