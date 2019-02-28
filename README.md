# TikaService

This project makes it possible to run a [tika-server](https://github.com/apache/tika) as a windows service.
It's possible to edit the JVM-Options at install-time (see `config/jvm.opts`) and tika-server parameters (see `config/service.config`) for each startup.

# Installation

* Make sure you have Java installed ([OpenJDK](https://github.com/ojdkbuild/ojdkbuild))
* Move all files (inside the released zip file) to the install-directory
* Run `install\install.bat SERVICE-NAME` as administrator.
    * install.bat is configureable by the following environment variables: `TIKA_STARTUP_TYPE` ("auto" or "manual"), `TIKA_LOG_PATH`, `TIKA_LOGLEVEL` (Error, Info, Warn, Debug) and `PRUNSRV_NAME` which can be prunsrv.exe or prunsrv64.exe (for a 64bit operating system)
    * for example: `set TIKA_STARTUP_TYPE=auto && set TIKA_LOG_PATH=C:/Windows/system32/LogFiles/TikaService && set TIKA_LOGLEVEL=Error && install\install.bat TikaService`
* Now you can start the service with `sc start SERVICE-NAME`.
    * and stop with `sc stop SERVICE_NAME`
* Do NOT move the folder containing the extracted files


The service is now registred as ProcRun service in the registry under: `HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Apache Software Foundation\ProcRun 2.0\<ServiceName>` (under win32). <br />


You can monitor the service with `install\prunmgr.exe //MS//SERVICE-NAME`

# Removal

Stop the service with `sc stop SERVICE-NAME` or with `install\prunsrv.exe //SS//SERVICE-NAME`. <br />
Run `install\prunsrv.exe //DS//SERVICE-NAME` to delete the service (from procrun and windows). Now it's possible to remove all relevant files.

# Versioning

GitVersion is used which is configured in GitVersion.yml (currently using version 3.6.5 because v4 does not yet work on Azure DevOps). <br />
Documentation: [GitVersion](https://gitversion.readthedocs.io/en/v3.6.5/configuration/)


# Building

You need to have Java installed and maven. <br />

Simply run `mvn package` and the deployable .zip file will get created inside the target/ folder