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
