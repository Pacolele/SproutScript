// Doesn't work since the comparision gets evaluated first run of the for and doesn't keep the comparision as a node.
for (i = 0; i < 10; i += 1) {
    actual = 2;
    var = actual * i;
    //print(var);
    if (i >= 4) {
        print(actual);
        break;
    }
}
