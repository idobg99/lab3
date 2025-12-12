#!/bin/bash

echo "========================================="
echo "Lab 3 Testing Script"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test Task 0.A
echo "Testing Task 0.A: Argument Printing"
echo "-------------------------------------"
make task0 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Compilation successful${NC}"
    echo "Running: ./task0 hello world test"
    ./task0 hello world test
    echo ""
else
    echo -e "${RED}✗ Compilation failed${NC}"
    echo ""
fi

# Test Task 0.B
echo "Testing Task 0.B: Hello World in Assembly"
echo "------------------------------------------"
make task0b 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Compilation successful${NC}"
    echo "Running: ./task0b"
    ./task0b
    echo ""
else
    echo -e "${RED}✗ Compilation failed${NC}"
    echo ""
fi

# Test Task 1
echo "Testing Task 1: Encoder"
echo "-----------------------"
make task1 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Compilation successful${NC}"
    
    # Test 1.A: Print arguments
    echo "Test 1.A - Printing arguments:"
    ./task1 arg1 arg2 arg3
    echo ""
    
    # Test 1.B: Basic encoding
    echo "Test 1.B - Encoding 'HELLO WORLD' from stdin:"
    echo "HELLO WORLD" | ./task1
    echo ""
    
    # Test 1.C: File I/O
    echo "Test 1.C - Encoding with file I/O:"
    echo "ABCXYZ" > test_input.txt
    ./task1 -itest_input.txt -otest_output.txt
    echo "Input file contents:"
    cat test_input.txt
    echo "Output file contents:"
    cat test_output.txt
    rm -f test_input.txt test_output.txt
    echo ""
else
    echo -e "${RED}✗ Compilation failed${NC}"
    echo ""
fi

# Test Task 2
echo "Testing Task 2: Directory Listing"
echo "----------------------------------"
make task2 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Compilation successful${NC}"
    
    # Test 2.A: List all files
    echo "Test 2.A - Listing all files:"
    ./task2
    echo ""
    
    # Test 2.B: Virus attachment (on safe test files)
    echo "Test 2.B - Creating test files for virus attachment:"
    echo "This is test file 1" > virustest1.txt
    echo "This is test file 2" > virustest2.txt
    chmod u+wx virustest1.txt virustest2.txt
    
    echo "Attaching virus to files starting with 'virus':"
    ./task2 -avirus
    
    echo ""
    echo "Checking if virus was attached:"
    ls -la virustest*.txt
    
    echo ""
    echo "Cleaning up test files..."
    rm -f virustest*.txt
    echo ""
else
    echo -e "${RED}✗ Compilation failed${NC}"
    echo ""
fi

echo "========================================="
echo "Testing Complete"
echo "========================================="
