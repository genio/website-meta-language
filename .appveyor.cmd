call :%*
goto :eof

:perl_setup
mkdir build
if not defined perl_type set perl_type=system
if "%perl_type%" == "cygwin" (
  ECHO "Updating CygWin's setup file"
  start /wait %CYGWIN%\\\bin\\wget.exe -O %CYGDRIVE%/setup-%ARCH%.exe https://cygwin.com/setup-%ARCH%.exe
  ECHO "Updating and installing necessary cygwin packages"
  start /wait %CYGWIN%\\setup-%ARCH%.exe --quiet-mode --upgrade-also --packages perl,binutils,cmake,make,gcc,g++,gcc-core,gcc-g++,glibc-devel,pkg-config,libcrypt-devel,openssl-devel,autoconf,automake,m4,libtool,curl,libdb-devel,libncurses-devel,libgd-devel,libgdbm-devel,libpcre-devel,perl-CPAN,perl-GD,perl-devel
  ECHO "Trying to install cpanminus and local::lib"
  start /wait %CYGSH% -c 'cpan App::cpanminus local::lib'
  ECHO "Adding the local::lib eval to the bashrc"
  start /wait %CYGSH% -c 'echo "eval $(perl -I$HOME/perl_libs/lib/perl5 -Mlocal::lib=$HOME/perl_libs)" >>~/.bashrc'
  ECHO "Copying repo to %CYGWIN%\\home\\appveyor\\repo"
  xcopy /i /q /e /s . %CYGWIN%\\home\\appveyor\\repo
) else if "%perl_type%" == "strawberry" (
  if not defined perl_version (
    cinst -y StrawberryPerl
  ) else (
    cinst -y StrawberryPerl --version %perl_version%
  )
  if errorlevel 1 (
    type C:\ProgramData\chocolatey\logs\chocolatey.log
    exit /b 1
  )
  set "PATH=C:\Strawberry\perl\site\bin;C:\Strawberry\perl\bin;C:\Strawberry\c\bin;%PATH%"
) else if "%perl_type%" == "activestate" (
  start /wait ppm install dmake MinGW
) else (
  echo.Unknown perl type "%perl_type%"! 1>&2
  exit /b 1
)
for /f "usebackq delims=" %%d in (`perl -MConfig -e"print $Config{make}"`) do set "make=%%d"
set "perl=perl"
set "cpanm=call .appveyor.cmd cpanm"
set "cpan=%perl% -S cpan"
set TAR_OPTIONS=--warning=no-unknown-keyword
goto :eof

:cpanm
%perl% -S cpanm >NUL 2>&1
if ERRORLEVEL 1 (
  curl -V >NUL 2>&1
  if ERRORLEVEL 1 cinst -y curl
  curl -k -L https://cpanmin.us/ -o "%TEMP%\cpanm"
  %perl% "%TEMP%\cpanm" -n App::cpanminus
)
set "cpanm=%perl% -S cpanm"
%cpanm% %*
goto :eof

:local_lib
if "%perl_type%" == "cygwin" goto :local_lib_cygwin
if "%perl_type%" == "cygwin64" goto :local_lib_cygwin
%perl% -Ilib -Mlocal::lib=--shelltype=cmd %* > %TEMP%\local-lib.bat
call %TEMP%\local-lib.bat
del %TEMP%\local-lib.bat
goto :eof

:local_lib_cygwin
for /f "usebackq delims=" %%d in (`sh -c "cygpath -w $HOME/perl5"`) do (
  c:\perl\bin\perl.exe -Ilib -Mlocal::lib - %%d --shelltype=cmd > "%TEMP%\local-lib.bat"
)
setlocal
  call "%TEMP%\local-lib.bat"
endlocal & set "PATH=%PATH%"
set "PATH_BACK=%PATH%"
%perl% -Ilib -Mlocal::lib - --shelltype=cmd > "%TEMP%\local-lib.bat"
call "%TEMP%\local-lib.bat"
set "PATH=%PATH_BACK%"
del "%TEMP%\local-lib.bat"
goto :eof

:eof
