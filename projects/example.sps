// Bubble Sort
arr = [800, 11, 50, 771, 649, 770, 240, 9];

for (write = 0; write < length(arr); write++) {
    for (sort = 0; sort < length(arr) - 1; sort++) {
        if (arr[sort] > arr[sort + 1]) {
            temp = arr[sort + 1];
            arr[sort + 1] = arr[sort];
            arr[sort] = temp;
        }
    }
}

test(arr, [9, 11, 50, 240, 649, 770, 771, 800]);

// Recursive factorial
function factorial(n) {
    value = n;
    if (n == 1 or n == 0) {
        value = n * 1;
    } else {
        value = n * factorial(n - 1);
    }
    return value;
}

test(factorial(5), 120);
test(factorial(8), 40320);

// Fizz Buzz
for (i = 1; i <= 100; i++) {
    if (i % 3 == 0 && i % 5 == 0) {
        print("Fizz Buzz");
    } else if (i % 3 == 0) {
       print("Fizz");
    } else if (i % 5 == 0) {
       print("Buzz");
    } else {
        print(i);
    }
}
