
ifeq ($(DEBUG),0)
    CXXFLAGS += -O2 -DNDEBUG
else
    CXXFLAGS += -g -ggdb -O0 -DDEBUG -D_DEBUG
endif
CXXFLAGS += -Ieinclude -Wall -ansi -pedantic
HEADERS = *.h
SUPPORT = util.o marching.o minkval.o readpgm.o tinyconf.o readpoly.o \
    label.o \
    intersect.o \

VERSION_NUMBER = 1.4
CXXFLAGS += -DVERSION=\"$(VERSION_NUMBER)\"

BINARIES = papaya testdata/eigensystem testdata/tsvdiff

all: $(BINARIES)

clean:
	rm -f $(BINARIES) *.o ts.*
	$(MAKE) -C testdata clean

test: $(BINARIES)
	$(MAKE) -C testdata test

# trick to recompile everything when the headers change.
ts.headers: $(HEADERS)
	$(MAKE) clean
	touch $@

papaya: ts.headers $(SUPPORT) driver.o
	$(CXX) -o $@ $(SUPPORT) driver.o

fallobst: ts.headers $(SUPPORT) fallobst.o
	$(CXX) -o $@ $(SUPPORT) fallobst.o

testdata/tsvdiff: ts.headers util.o tsvdiff.o
	$(CXX) -o $@ util.o tsvdiff.o

testdata/eigensystem: ts.headers $(SUPPORT) testdata/eigensystem.cpp
	$(CXX) $(CXXFLAGS) -o $@ $(SUPPORT) testdata/eigensystem.cpp

tar:
	git archive --format=tar --prefix=papaya-$(VERSION_NUMBER)/ VERSION_1_4 | gzip -9 >../papaya-$(VERSION_NUMBER).tar.gz

.PHONY: all clean tar
