function factorial(n) {
    value = n;
    if (n == 1 or n == 0) {
        value = n * 1;
    } else {
        value = n * factorial(n - 1);
    }
    return value;
}

//function factorial(n) {
//    if (n == 1 or n == 0) {
//        return 1;
//    } else {
//        return n * factorial(n - 1);
//    }
//}

test(factorial(5), 120);
test(factorial(8), 40320);
