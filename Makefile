CC := clang
BIN_DIR := ./bin
SRC_DIR := ./src
OBJ_DIR := $(BIN_DIR)/obj
TARGET := $(BIN_DIR)/lisp

SRCS := $(wildcard $(SRC_DIR)/**/*.m $(SRC_DIR)/*.m)
OBJS := $(SRCS:%.m=$(OBJ_DIR)/%.o)

CC_FLAGS := -Iinclude -g -Wno-shadow-ivar

all: $(TARGET)

$(TARGET): $(OBJS)
	@mkdir -p $(@D)
	$(CC) -o $(TARGET) $^ -framework Foundation

$(OBJ_DIR)/%.o: %.m
	@mkdir -p $(@D)
	$(CC) $< -o $@ -c $(CC_FLAGS)

.PHONY:
clean:
	rm -rf $(OBJ_DIR)/*
	rm -rf $(BIN_DIR)/*
