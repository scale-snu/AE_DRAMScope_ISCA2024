program_NAME := Rowpress
program_CXX_SRCS := functions.cpp rowpress.cpp $(wildcard ../../../DRAM-Bender/sources/api/*.c) $(wildcard ../../../DRAM-Bender/sources/api/*.cpp)
program_CXX_OBJS := ${program_CXX_SRCS:.cpp=.o}
program_CXX_OBJS := ${program_CXX_OBJS:.c=.o}
program_OBJS := $(program_CXX_OBJS)
program_INCLUDE_DIRS := ../../../DRAM-Bender/sources/api ../../../DRAM-Bender/sources/boost-lib
program_LIBRARY_DIRS :=
program_LIBRARIES := pthread
CPPFLAGS += -g -std=c++11

CPPFLAGS += $(foreach includedir,$(program_INCLUDE_DIRS),-I$(includedir))
LDFLAGS += $(foreach librarydir,$(program_LIBRARY_DIRS),-L$(librarydir))
LDFLAGS += $(foreach library,$(program_LIBRARIES),-l$(library))

CC=g++

.PHONY: all clean distclean

all: $(program_NAME)

$(program_NAME): $(program_OBJS)
	$(CC) $(CPPFLAGS) $(program_OBJS) -o $(program_NAME) $(LDFLAGS)

clean:
	@- $(RM) $(program_NAME)
	@- $(RM) $(program_OBJS)

distclean: clean
