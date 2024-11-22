# Makefile

# Compiler
CC = gcc

# Compiler flags
CFLAGS = -Wall

# Source files
SRC = src/main.c src/onic.c

# Include directories
INCLUDES = -I./src

# Target executable
TARGET = onic

# Build target
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(INCLUDES) -o $(TARGET) $(SRC)

# Clean target
clean:
	rm -f $(TARGET)