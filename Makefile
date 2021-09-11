#
# Compiler flags
#
CXXFLAGS = -pedantic-errors -Wall -Wextra -Werror --std=c++17

#
# Project files
#
SRC = $(wildcard src/*.cpp)
PROJ_SRC = $(filter-out src/main.cpp, $(SRC))

EXE  = tsv_req
INCLUDE = -Iinclude/

#
# TEST files
#
TEST_SRC = $(wildcard test_src/*.cpp) $(PROJ_SRC)
$(info $(TEST_SRC))
TEST_EXE  = tests
TEST_INCLUDE = -Ivendor/catch

#
# Debug build settings
#
DBGDIR = debug
DBGEXE = $(DBGDIR)/$(EXE)
DBGOBJS = $(SRC:%.cpp=$(DBGDIR)/%.o)
DBGCXXFLAGS = -g -O0 -DDEBUG

#
# Release build settings
#
RELDIR = release
RELEXE = $(RELDIR)/$(EXE)
RELOBJS = $(SRC:%.cpp=$(RELDIR)/%.o)
RELCXXFLAGS = -O3 -DNDEBUG


#
# Test build settings
#
TESTDIR = tests
TESTEXE = $(TESTDIR)/$(TEST_EXE)
TESTOBJS = $(TEST_SRC:%.cpp=$(TESTDIR)/%.o)
TESTCXXFLAGS = -g -O0 -DDEBUG

.PHONY: all clean debug prep release test remake

# Default build
all: release debug test

#
# Debug rules
#
debug: $(DBGEXE)

$(DBGEXE): $(DBGOBJS)
	$(CXX) $(CXXFLAGS) $(DBGCXXFLAGS) -o $(DBGEXE) $^

$(DBGDIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) -c $(CXXFLAGS) $(DBGCXXFLAGS) $(INCLUDE) -o $@ $<

#
# Release rules
#
release: $(RELEXE)
$(RELEXE): $(RELOBJS)
	$(CXX) $(CXXFLAGS) $(RELCXXFLAGS) -o $(RELEXE) $^

$(RELDIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) -c $(CXXFLAGS) $(RELCXXFLAGS) $(INCLUDE) -o $@ $<

#
# Test rules
#
test: $(TESTEXE)
$(TESTEXE): $(TESTOBJS)
	$(CXX) $(CXXFLAGS) $(TESTCXXFLAGS) -o $(TESTEXE) $^ -Wall -fprofile-arcs -ftest-coverage

$(TESTDIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) -c $(CXXFLAGS) $(TESTCXXFLAGS) --coverage $(TEST_INCLUDE) $(INCLUDE) -o $@ $<

tests run: $(TESTEXE)
	./$(TESTEXE)

coverage: checks
	lcov --directory $(TESTDIR) --capture --output-file $(TESTDIR)/covdata
	genhtml --legend --title coverage -o $(TESTDIR)/coverage_dir $(TESTDIR)/covdata

checks: prep
	${MAKE} parallel-checks

prep:
	rm -r $(TESTDIR)

parallel-checks: $(addsuffix -runq,${TESTEXE})

%-runq: %
	@echo "  RUN     " $<; rm -f $<.success $<.fail; \
	if ./$<  >$<.out 2>&1 || ./$<  >$<.out 2>&1; then \
	    mv $<.out $<.success ; \
	else \
	    mv $<.out $<.fail ; cat $<.fail; exit 1; \
	fi
#
# Other rules
#

remake: clean all

clean:
	rm -f $(RELEXE) $(RELOBJS) $(DBGEXE) $(DBGOBJS) $(TESTEXE) $(TESTOBJS)