# Compiler options
CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wall -Wextra -Werror
# Source files
SRCS = writer.c
# Object files
OBJS = $(SRCS:.c=.o)
# Binary file
TARGET = writer
# Default target
all: $(TARGET)
# Link the object files to create the binary
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@
# Compile the source files into object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
# Clean up the object files and the binary
clean:
	$(RM) $(OBJS) $(TARGET)
# Cross-compilation
ifeq ($(CROSS_COMPILE),aarch64-none-linux-gnu-)
CC = $(CROSS_COMPILE)gcc
else
CC = gcc
endif