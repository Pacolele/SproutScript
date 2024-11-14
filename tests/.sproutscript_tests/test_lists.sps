x = [5, "This is fun"];
print(x);

//-y = 2;
print(length(x));
print([5,"LOL", 22, True]);
print(length([5,"LOL", 22, True]));
print(x[1]);

append(x, True);
print(x);

print(append(["End of the world", "World War", 3], False));

pop(x);

print(x);

print(pop([1,5,7,8,6,5]));

clear(x);

print(x);

x = [];

for(i = 0; i <= 10; i += 1) {
    append(x, i);
}

print(x);

a = [3, 2, 1];
b = [1, 2, 3];
print(a == b);

sort(a);

print(a == b);

c = [1, 2, "hello", 3, 4];
deleted = delete_at(c, 2);
print(c);
print(deleted);

print(c[9]);
