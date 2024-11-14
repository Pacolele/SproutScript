// this file tests all arithmetic functions as thoroughly as possible
// these have all been verified through irb and python, and generate the same result as in SproutScript

// testing longer algorithms with many parentheses and all operators
test_one = (((((-100 * 3) + 56) * 2) - -50) % 100) / -45; // -2
print(test_one);

test_two = (((test_one - 48) / 10) * 365) ^ ((80 % 4) + 3); // -6078390625
print(test_two);

// tests repeated division
test_three = 200 / 2 / 2 / -2; // -25
print(test_three);

test_four = -2000/-200/10; // 1
print(test_four);

// test repeated multiplication
test_five=(1*2*3*4*5)*(5*5*10*100)*2*3; // 18000000
print(test_five);

test_six = ( 160 * -12 ) * -2 * 0; // 0
print(test_six);

// tests really long and complex equations

x = 2;
y = 4;
z = 6;
test_nine = ((x + y) * (x - y) / z * x^2 - y^2 - (z^2 - y^2) / 2 + x * y * z) % 10000001 - 5000000; // result according to irb: -4999986
print(test_nine); // our result: -4999994

test_ten = ((-6*x + 10*y) * (-2*x + 6*y) * (2*x + 6*y) * (6*x - 10*y) * (-2 + 2*y + 4*z) * (x + 2*y + 4*z) * (-2*x + y + 4*z) * (2*x + y + 4*z) * (4*x - 2*y + 4*z) * (-4*x - 2*y + 4*z) * (4*x + 2*y + 4*z) * (-4*x + 2*y + 4*z) * (x - 2*y - 4*z) * (-2 - 2*y - 4*z) * (2*x - y - 4*z) * (-2*x - y - 4*z) * (-4*x + 2*y - 4*z) * (4*x + 2*y - 4*z) * (-4*x - 2*y - 4*z) * (4*x - 2*y - 4*z) * (-5*x + 5*y) * (5*x + 5*y) * (-10*y + 10*z) * (10*y + 10*z)) / ((x - y) * (-x - z) * (y - z));
print(test_ten); // irb gives 343244087020466271682560000000000

test_eleven = 2^3^2;
print(test_eleven);

test_twelve = -2^2;
print(test_twelve);
