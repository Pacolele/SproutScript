x = 0;
y = 1000;

while (x < 10){
    print(x);
    x = x + 1;
    if (x == 4){
        print(y);
        break;
    }
}

while (5){
    print(x);
    if (x == 6){
        break;
    }
    x = x + 1;
}

y = 0;

do {
    print(y);
    y = y + 1;
    print(y);
} while (y == 0);

first_variable = 0;
x = 1;

do {
    while (x == 30){
        print(x);
        first_variable = first_variable + 1;
        x = 0;

    }
    x = x + 1;
} while (first_variable != 5);

while (x < 10){
    print(x);
    x = x + 1;
}
print(test);
