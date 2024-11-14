
//print(x^2+(7*x)+4 < 232);


// Test 1
b1 = True;
b2 = False;
b3 = True;

//test_one = b1 and b2 or b2 or (b3 and b2);
//print(test_one);


// Test 2
// Test to check if we can run logic on pure True/False classes
test_two = True or ((!True or True) and (True or False));
print(test_two);

// Test 3
// Test comparisions operations and logic operations.
x = 12;
test_three = x >= 12 && ((True || False) and !b2);
print(test_three);


// Test 4

x = 2;
y = True;

print(x or y);
print(y or x);

z = False;

print(z and y);
print(z or y);

b = 0;
print(not z);
print(not b);
