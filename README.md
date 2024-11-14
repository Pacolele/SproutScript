# SproutScript

SproutScript is a beginner-friendly programming language designed to combine the simplicity of Python and Ruby with the stricter syntax of Java and C-based languages. It provides an easy introduction to programming fundamentals while fostering good habits for transitioning to more complex languages.

## Table of Contents
- [About SproutScript](#about-sproutscript)
- [Features](#features)
- [Getting Started](#getting-started)
- [Syntax Overview](#syntax-overview)
  - [Variables and Data Types](#variables-and-data-types)
  - [Functions](#functions)
  - [Control Structures](#control-structures)
  - [Loops](#loops)
- [Example Code](#example-code)
- [Implementation Details](#implementation-details)
- [Challenges](#challenges)
- [Future Improvements](#future-improvements)

## About SproutScript
SproutScript is designed for new programmers who have no prior experience in coding. It takes the best aspects of dynamically-typed languages, like Python, and blends them with stricter syntax elements that are common in languages such as Java and C. This helps beginners learn basic programming concepts while also preparing them for future learning in more advanced languages.

## Features
- **Dynamic Typing**: No need to declare variable types.
- **Simple Function Definitions**: Functions are easy to create and use without specifying return types.
- **Print Statements**: Use `print()` to output to the console, similar to Python.
- **Stricter Syntax Elements**: Utilizes semicolons for line endings and braces for defining code blocks, preparing users for more rigid languages.

## Getting Started
SproutScript is implemented on top of Ruby and uses a custom parser to interpret and execute the code. To get started, ensure you have Ruby installed, and then run the SproutScript parser with your `.sprout` file.

## Syntax Overview
### Variables and Data Types
- **Integers, Strings, Booleans**: Supports fundamental data types, including integers, strings, and booleans.
- **Variable Assignment**: Variables can be assigned without specifying types.
  ```sprout
  x = 5;
  name = "Sprout";
  isLearning = true;
  ```

### Functions
- **Function Declaration**: Functions are defined using the `function` keyword, with optional parameters.
  ```sprout
  function greet(name) {
    print("Hello, " + name);
  }
  ```
- **Calling Functions**: Functions can be called by their name, passing in arguments as needed.
  ```sprout
  greet("World");
  ```

### Control Structures
- **If Statements**: Uses `if`, `else if`, and `else` for conditional logic.
  ```sprout
  if (x > 0) {
    print("Positive number");
  } else {
    print("Non-positive number");
  }
  ```

### Loops
- **While Loops**: Uses `while` for iteration.
  ```sprout
  while (x > 0) {
    print(x);
    x = x - 1;
  }
  ```
- **Do-While Loops**: Executes the block at least once before checking the condition.
  ```sprout
  do {
    print("Running");
  } while (x < 5);
  ```

## Example Code
```sprout
function add(a, b) {
  return a + b;
}

result = add(3, 4);
print("The result is: " + result);
```

## Implementation Details
SproutScript is built on top of Ruby and consists of three core components:
1. **Parsing**: The user-written code is parsed using a lexer to generate tokens.
2. **Abstract Syntax Tree (AST)**: Constructs an AST from the parsed code to represent program structure.
3. **Execution**: The AST is executed, with each node running in sequence.

The language uses a `Frame` system to manage variable scopes and includes both data nodes (for values like integers and strings) and executable nodes (for operations, loops, and function calls).

## Challenges
While implementing SproutScript, two major challenges were identified:
- **Nested Loops**: Managing nested loops and ensuring proper iteration was a complex task.
- **Function Return Values**: Functions containing conditional logic sometimes failed to return values correctly due to issues with scope management.

## Future Improvements
- **Custom Error Messages**: Currently, errors are mostly handled by Ruby. Future versions will implement more descriptive error messages to enhance the learning experience.
- **Improved Scope Handling**: Enhancements to function scoping will allow more flexibility, especially for recursive functions and nested conditionals.



## Explanation of files
- This document specifies the file(s) relevant for specific data structures in SproutScript. Please consider the current folder as root for these paths. These are listed in alphabetical order.

cases/cases.rb              - Defines the nodes used for if-statements (as well as else if, else)
data/basic_data.rb          - Defines the most basic data nodes such as integers, booleans
data/complex_data.rb        - Defines complex data such as lists, strings
data/frames.rb              - Defines frames (used for scope) and syntax trees, mainly used in the parser and complex nodes needing access to variables
errors/errors.rb            - Creates custom error messages for SproutScript
functions/functions.rb      - Defines nodes used to create and execute user-defined functions (see also: frames.rb)
loops/for.rb                - Defines for-loops which can be executed by SproutScript (see also: frames.rb)
loops/while.rb              - Defines while- and do while-loops (see also: frames.rb)
nodes/function_nodes.rb     - Defines SproutScripts custom functions such as print, input, test
nodes/nodes.rb              - Defines construction nodes, responsible for creating a new node from two others - for example, arithmetic nodes, comparison nodes
parser/parse.rb             - The parser for SproutScript - defines the tokens and rules for the language
parser/rdparse.rb           - The recursive descent parser given to us in the course, virtually unchanged except for one pass with RuboCop
projects/                   - Contains complete example projects written in SproutScript
tests/unit_tests.rb         - Unit test suite for SproutScript, testing all nodes in a vacuum
tests/.sproutscript_tests/   - Tests written in SproutScript used during development (hidden folder as it may be interesting for evaluation, but not relevant to end user)
