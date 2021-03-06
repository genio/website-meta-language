##
##  wml_test/Makefile
##  Copyright (c) 1998-2001 Ralf S. Engelschall
##

# ------------------------------------------------
#   DEFINITIONS
# ------------------------------------------------

SHELL           = /bin/sh

# Define me
top_srcdir      = top_srcdir
srcdir          = srcdir
VPATH           = $(srcdir)

prefix          = prefix
PATH_PERL       = PATH_PERL

# ------------------------------------------------
#   TARGETS
# ------------------------------------------------

test:
	-@set -e; \
	root=`$(PATH_PERL) -e 'use Cwd; ($$cwd = cwd) =~ s|/?$$|/TEST.root|; print $$cwd'`; \
	if [ ! -d TEST.root ]; then \
	    echo "Temporarily installing WML system into local test tree:"; \
	    rm -rf TEST.root 2>/dev/null || :; mkdir TEST.root; \
	    (cd .. && $(MAKE) all 2>&1) |\
	    (cd .. && $(MAKE) install prefix=$$root 2>&1) |\
	    $(PATH_PERL) -n -e 's/^.*$$/./s; print STDERR $$_; $$i++; print STDERR "\n" if ($$i % 60 == 0);'; \
	    echo ''; \
	    echo "Fixing installation prefix for local test tree:"; \
	    case x$(prefix) in \
	      x*wml* ) lib="lib" ;; \
	      x*     ) lib="lib/wml" ;; \
	    esac; \
	    (cd TEST.root; \
	    for file in \
	      bin/wml \
	      bin/wmk \
	      bin/wmd \
	      bin/wmb \
	      bin/wmu \
	      $$lib/exec/wml_aux_freetable \
	      $$lib/exec/wml_aux_htmlclean \
	      $$lib/exec/wml_aux_htmlinfo \
	      $$lib/exec/wml_aux_linklint \
	      $$lib/exec/wml_aux_map2html \
	      $$lib/exec/wml_aux_txt2html \
	      $$lib/exec/wml_aux_weblint \
	      $$lib/exec/wml_p1_ipp \
	      $$lib/exec/wml_p5_divert \
	      $$lib/exec/wml_p6_asubst \
	      $$lib/exec/wml_p7_htmlfix \
	      $$lib/exec/wml_p8_htmlstrip \
	      $$lib/exec/wml_p9_slice \
	      $$lib/include/sys/bootp3.wml; do \
	        sed -e '4,$$'"s;$(prefix);$${root};g" <$$file >$$file.n \
	        && mv $$file.n $$file; \
	        chmod a+x $$file; \
	        echo "dummy"; \
	    done) |\
	    $(PATH_PERL) -n -e 's/^.*$$/./s; print STDERR $$_; $$i++; print STDERR "\n" if ($$i % 60 == 0);'; \
	    echo ''; \
	else :; \
	fi
	echo "Running WML Test Suite (still incomplete):"
	WML="$$root/bin/wml -q -W1,-N"; export WML; \
	LANG=C; LC_ALL=C; export LANG LC_ALL; \
	prove t/*.t ; \
	exit $$?

clean:
	-rm -rf TEST.root tmp.*.cmd 2>/dev/null

distclean: clean
	-rm -f Makefile

realclean: distclean

##EOF##
