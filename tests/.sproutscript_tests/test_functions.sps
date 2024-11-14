x = 1;

function foo(y){
    print(y);
}

foo(x);

function bar(y){
    if (y != 5){
        bar(y + 1);
    } else {
        print(y);
    }
}

bar(x);

bar(1);

function foobar(a, b){
    if (a + b > 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000){
      print(a + b);
    } else {
      foobar(a * 2, b * 2);
    }
}

foobar(5, 10);

x = 1;

function fooprint(var){
    abc = var + 10;
    return abc;
}

print(fooprint(x));

function fooreturn(int){
    return 10 + int;
}

new_value = fooreturn(10);

print(new_value);

function fooadd(x){
    return x + 10;
}

if (fooadd(10) == 20){
    print(666);
}

function foobreak(){
    print(new_value);
}

foobreak();
