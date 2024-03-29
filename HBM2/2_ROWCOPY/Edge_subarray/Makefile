TARGET := RowCopy
CXX_SRCS := $(wildcard *.cpp) $(wildcard ../../../SoftMC/sw/SoftMC_API/*.cpp)
CXX_OBJS := ${CXX_SRCS:.cpp=.o}
INCLUDE_DIRS := ../../../SoftMC/sw/SoftMC_API/
LIBRARY_DIRS :=
LIBRARIES := 
CPPFLAGS += -g -std=c++11

CPPFLAGS += $(foreach includedir,$(INCLUDE_DIRS),-I$(includedir))
LDFLAGS += $(foreach librarydir,$(LIBRARY_DIRS),-L$(librarydir))
LDFLAGS += $(foreach library,$(LIBRARIES),-l$(library))

CC=g++

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(CXX_OBJS)
	$(CC) $(CPPFLAGS) $(CXX_OBJS) -o $(TARGET) $(LDFLAGS)

clean:
	@- $(RM) $(TARGET)
	@- $(RM) $(CXX_OBJS)

