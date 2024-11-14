function factorial(n) {
    if (n == 1 or n == 0) {
        return n;
    } else {
        return n * factorial(n - 1);
    }
}

test(factorial(5), 120);
test(factorial(8), 40320);
