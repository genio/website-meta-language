#!/usr/bin/bash

set -xeuo pipefail
shopt -s lastpipe

# Test script for the AppVeyor CI service.
# Ran from ../appveyor.yml.
# Runs under CygWin bash.

# Reset PATH variable inherited from Windows environment
# export PATH=/usr/local/bin:/usr/bin:/bin

# Set correct working directory
echo $PATH
cpan App::cpanminus local::lib
mkdir -p ~/perl_libs
eval "$(perl -Mlocal::lib=~/perl_libs)"
cd repo/build
perl -V
cpanm -n Bit::Vector Class::XSAccessor File::Which Getopt::Long IO::All Image::Size Perl::Tidy Test::Code::TidyAll Term::ReadKey
$(perl ../src/wml_test/run_test.pl)
