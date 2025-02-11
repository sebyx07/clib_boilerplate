#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "hello_world.h"

void test_hello_world() {
    const char* result = hello_world();
    assert(strcmp(result, "Hello, World!") == 0);
    printf("✓ hello_world returns correct string\n");
}

int main() {
    printf("Running tests...\n");
    test_hello_world();
    printf("All tests passed!\n");
    return 0;
}