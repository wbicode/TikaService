@echo off
REM comment the previous line to show each line in cmd

REM first argument is the service-location 
pushd
cd %~dp0\..\
set SERVICE_PATH=%CD%
popd

set CONFIG_PATH=%SERVICE_PATH%\config
set SERVICE_CONFIG_FILE=%CONFIG_PATH%\service.config
set TIKA_CONFIG_FILE=%CONFIG_PATH%\tika-config.xml
set JVM_OPTION_FILE=%CONFIG_PATH%\jvm.opts

@setlocal EnableDelayedExpansion

for /f "usebackq delims== tokens=1,2" %%G in ("%JVM_OPTION_FILE%") do (
	set "isMem="
	if "%%G"=="Xmx" ( 
		set isMem=1
	)
	if "%%G"=="Xms" ( 
		set isMem=1
	)
	
	if not defined isMem (
		set "JVM_OPTIONS=!JVM_OPTIONS!-%%G=%%H;";
	) else (
		set "JVM_OPTIONS=!JVM_OPTIONS!-%%G%%H;"
	)
)

for /f "delims== tokens=1,*" %%A in ("%SERVICE_CONFIG_FILE%") do (
    SET "%%~A=%%~B"
)

REM ############ CONFIG ###########################
set SERVICE_NAME=AATestTikaService

if NOT "%~1"=="" (
	set SERVICE_NAME=%~1
)

if "%TIKA_LOG_PATH%"=="" (
	set "TIKA_LOG_PATH=%SERVICE_PATH%\logs"
)

if "%TIKA_STARTUP_TYPE%"=="" (
	set TIKA_STARTUP_TYPE=auto
)

if "%TIKA_LOGLEVEL%"=="" (
	set TIKA_LOGLEVEL=Info
)

if "%PRUNSRV_NAME%"=="" (
	ECHO."%JAVA_HOME%"| FIND /I "x86">Nul && ( 
	  set PRUNSRV_NAME=prunsrv.exe
	) || (
	  set PRUNSRV_NAME=prunsrv64.exe
	)
)


REM create log path
mkdir "%TIKA_LOG_PATH%"


REM search for jvm.dll
REM store path in JVM_DLL

REM Check JVM server dll first
if exist "%JAVA_HOME%\jre\bin\server\jvm.dll" (
	set JVM_DLL=\jre\bin\server\jvm.dll
	goto found
)

REM Check JVM client
if exist "%JAVA_HOME%\bin\client\jvm.dll" (
	set JVM_DLL=\bin\client\jvm.dll
	goto found
)

REM Check 'server' JRE (JRE installed on Windows Server)
if exist "%JAVA_HOME%\bin\server\jvm.dll" (
	set JVM_DLL=\bin\server\jvm.dll
	goto found
) else (
  	echo unable to find jvm.dll
  	exit 1
)


REM it's also possible to add StartParams and StopParams
REM the "-Jvm" param is needed when starting in jvm mode; the "auto" value only works for Oracle Java (and not for openjdk or AdoptOpenJDK)
:found
"%SERVICE_PATH%\install\%PRUNSRV_NAME%" //IS//"%SERVICE_NAME%" ^
--DisplayName="%SERVICE_NAME%" ^
--Description="tika-server Windows Service" ^
--Install="%SERVICE_PATH%\install\%PRUNSRV_NAME%" ^
--Classpath="%SERVICE_PATH%\lib\*" ^
--Jvm="%%JAVA_HOME%%%JVM_DLL%" ^
--JvmOptions=%JVM_OPTIONS% ^
--StartMode=jvm ^
--StartClass="org.apache.tika.server.core.TikaServerCli" ^
--StartMethod=main ^
--StopMode=jvm ^
--StopClass="org.apache.tika.server.core.TikaServerCli" ^
--StopMethod=stop ^
--LogPath="%TIKA_LOG_PATH%" ^
--StdOutput=auto ^
--StdError=auto ^
--LogLevel=%TIKA_LOGLEVEL% ^
--Startup=%TIKA_STARTUP_TYPE% ^
--StartPath="%SERVICE_PATH%" ^
--StartParams=-c#"%TIKA_CONFIG_FILE%"
