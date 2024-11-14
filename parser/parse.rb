#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'rdparse'
require_relative '../requirements/requirements'

# main parser
class SproutScript
  attr_accessor :sprout_parser, :syntax_tree

  def initialize
    @@syntax_struct = Struct.new(:tree, :prev)
    @@syntax = SyntaxTree.new(NilClass)
    @@global = Frame.new(NilClass)
    @@test_list = []
    @@is_function = false

    @sprout_parser = Parser.new('Sprout') do
      token(/\s+/)
      token(%r{//.+})
      # Matches for correctly formatted strings
      token(/(".+?")/)            { |m| m.to_s }

      # Matches for general symbols
      token(/;/)                  { :SEMICOLON }
      token(/==/)                 { :EQUAL }
      token(/!=/)                 { :NEQUAL }
      token(/<=/)                 { :LESSOREQ }
      token(/>=/)                 { :GREATOREQ }
      token(/</)                  { :LESSTHAN }
      token(/>/)                  { :GREATERTHAN }
      token(/=/)                  { :ASSIGN }
      token(/\(/)                 { :LPAREN }
      token(/\)/)                 { :RPAREN }
      token(/{/)                  { :LBRACE }
      token(/}/)                  { :RBRACE }
      token(/\]/)                 { :RBRACKET }
      token(/\[/)                 { :LBRACKET }
      token(/&&/)                 { :AND }
      token(/and/)                { :AND }
      token(/\+=/)                { :PLUSEQ }
      token(/\+\+/)               { :INCREMENT }
      token(/\|\|/)               { :OR }
      token(/or/)                 { :OR }
      token(/not/)                { :NOT }
      token(/!/)                  { :NOT }
      token(/%/)                  { :MODULO }

      # Keywords
      token(/return/)             { :RETURN }
      token(/length/)             { :LENGTH }
      token(/function/)           { :FUNCTION }
      token(/print/)              { :PRINT }
      token(/split\(/)            { :SPLIT }
      token(/append\(/)           { :APPEND }
      token(/pop\(/)              { :POP }
      token(/clear\(/)            { :CLEAR }
      token(/sort\(/)             { :SORT }
      token(/delete_at\(/)        { :DELETEAT }
      token(/input\(/)            { :INPUT }
      token(/what_is\(/)          { :WHATIS }
      token(/test\(/)             { :TEST }
      token(/if/)                 { :IF }
      token(/else if/)            { :ELSEIF }
      token(/else/)               { :ELSE }
      token(/do/)                 { :DO }
      token(/('\s')/)             { :WSDELIM }
      token(/'/)                  { :APOS }
      token(/while/)              { :WHILE }
      token(/for/)                { :FOR }
      token(/True/)               { :TRUE }
      token(/False/)              { :FALSE }
      token(/break;/)             { :BREAK }

      # General matches for data
      token(/\d+\.\d+/)           { |m| m.to_f }
      token(/\d+/)                { |m| m.to_i }
      token(/\w+/)                { |m| m }
      token(/./)                  { |m| m }

      start :program do
        match(:block)
      end

      rule :block do
        match(:block, :row)
        match(:row)
      end

      rule :row do
        match(:if_statement)
        match(:loop)
        match(:BREAK) { @@syntax.tree.append(SproutBreak.new(@@global)) }
        match(:append_statement, :SEMICOLON)
        match(:var, :SEMICOLON)
        match(:function_declaration)
      end

      # ========== Function rules ==========
      # These rules manage function definit-
      # ion, function parameters, returns.
      # ====================================
      rule :function_declaration do
        match(:function, :function_name, :LPAREN, :parameters, :RPAREN, :LBRACE, :block,
              :RBRACE) do |_, name, _, p, _, _, _block, _|
          temp = SproutUserFunction.new(@@global, @@syntax, p)
          @@is_function = false
          @@global.functions[name.to_sym] = temp
          @@global = @@global.parent
          @@global.functions[name.to_sym] = temp
          @@syntax = @@syntax.prev
        end
      end

      rule :function_name do
        match(/^[a-zA-Z][a-zA-Z0-9_]{2,}/) { |m| m }
      end

      rule :parameters do
        match(:parameters, ',', :logical) { |lparam, _, rparam| lparam + [rparam] }
        match(:logical) { |param| [param] }
        match { [] }
      end

      # ========== Appending to syntax tree ==========
      # This rule appends nodes to the syntax tree.
      # ==============================================
      rule :append_statement do
        match(:statement) do |stmnt|
          @@syntax.tree.append(stmnt) unless stmnt.is_a? String
          stmnt
        end
      end

      # ========== Statements ==========
      # A statement is any keyword-prot-
      # ected action matched to this
      # rule. The first rule depends on
      # variables and/or function calls
      # and require a separate rule.
      # ================================

      rule :statement do
        match(:PRINT, :LPAREN, :statement_list, :RPAREN) do |_, _, stmnt, _|
          SproutPrint.new(stmnt, @@global)
        end

        match(:RETURN, :logical) do |_, m, _|
          raise SproutReturnError unless @@is_function

          SproutReturn.new(m, @@global)
        end
        match(:statement_list)
        match(:function_call)
      end

      # ========== Statement List ==========
      # Keyword protected actions not depen-
      # dant on function calls in the same
      # manner as the previous rule.
      # ====================================

      rule :statement_list do
        match(:SPLIT, :str, ',', :split_delim, :RPAREN) do |_, str, _, delim, _|
          raise SproutSplitError unless str.is_a? SproutString or str.is_a? String

          SproutSplit.new(str, delim, @@global)
        end

        match(:APPEND, :type, ',', :data, :RPAREN) do |_, list, _, add, _|
          unless list.is_a? SproutList or list.is_a? String and (add.is_a? SproutMainData or add.is_a? String)
            raise SproutMethodError,
                  'append'
          end

          SproutAppend.new(list, add, @@global)
        end

        match(:POP, :type, :RPAREN) do |_, list, _|
          raise SproutMethodError, 'pop' unless list.is_a? SproutList or list.is_a? String

          SproutPop.new(list, @@global)
        end

        match(:CLEAR, :type, :RPAREN) do |_, list, _|
          raise SproutMethodError, 'clear' unless list.is_a? SproutList or list.is_a? String

          SproutClear.new(list, @@global)
        end

        match(:SORT, :type, :RPAREN) do |_, list, _|
          raise SproutMethodError, 'sort' unless list.is_a? SproutList or list.is_a? String

          SproutSort.new(list, @@global)
        end

        match(:DELETEAT, :type, ',', :data, :RPAREN) do |_, list, _, index, _|
          raise SproutMethodError, 'delete at' unless list.is_a? SproutList or list.is_a? String

          SproutDeleteAt.new(list, index, @@global)
        end

        match(:INPUT, :type, :RPAREN) do |_, m, _|
          SproutInput.new(m, @@global)
        end

        match(:WHATIS, :type, :RPAREN) do |_, m, _|
          SproutWhatIs.new(m, @@global)
        end

        match(:TEST, :type, ',', :type, :RPAREN) do |_, lhs, _, rhs, _|
          SproutTest.new(lhs, rhs, @@global, @@test_list)
        end

        match(:logical)
      end

      rule :split_delim do
        match(:WSDELIM) { ' ' }
        match(:APOS, String, :APOS) { |_, delim, _| delim }
      end

      # ========== Function call nodes ==========
      # Function call nodes can be nested inside
      # several other construction nodes, and is
      # treated as a construction node itself.
      # Thus, it matches further down in the
      # hierarchy.
      # =========================================

      rule :function_call do
        match(:function_name, :LPAREN, :parameters, :RPAREN) do |name, _, param, _|
          SproutFunctionCall.new(name, param, @@global)
        end
        match(:logical)
      end

      # ========== Variable assignment nodes ==========
      # These rules ensure that variable assignment can
      # accept any valid construction node that yields
      # proper data.
      # ===============================================

      rule :var do
        match(:var_name, :ASSIGN, :logical) do |name, _, val|
          temp = SproutAssign.new(name, val, @@global)
          @@syntax.tree.append(temp)
        end

        match(:var_name, :PLUSEQ, :expr) do |name, _, val|
          add = SproutArithmetic.new(mame, '+', val, @@global)
          temp = SproutAssign.new(name, add, @@global)
          @@syntax.tree.append(temp)
        end

        match(:var_name, :ASSIGN, :function_call) do |name, _, func|
          temp = SproutAssign.new(name, func, @@global)
          @@syntax.tree.append(temp)
        end

        match(:var_name, :ASSIGN, :list) do |name, _, list|
          temp = SproutAssign.new(name, list, @@global)
          @@syntax.tree.append(temp)
        end

        match(:var_name, :ASSIGN, :statement_list) do |name, _, stmnt|
          temp = SproutAssign.new(name, stmnt, @@global)
          @@syntax.tree.append(temp)
        end

        match(:data)
      end

      rule :var_name do
        match(:str, :LBRACKET, :expr, :RBRACKET) do |a, _, b, _|
          SproutIndex.new(a, b, @@global)
        end
        match(/^[a-z][a-zA-z_0-9]*/) do |m|
          m
        end
      end

      # ========== Control statements ==========
      # Only one node exists for control statem-
      # ents, so the chaining logic lies in the-
      # se rules.
      # ========================================

      rule :if_statement do
        match(:if_statement, :row)
        match(:if, :LPAREN, :logical, :RPAREN, :LBRACE, :block, :RBRACE) do |_s, _, cond, _, _, _, _|
          temp = SproutIfNode.new(cond, @@global, @@syntax)
          @@syntax = @@syntax.prev
          @@syntax.tree.append(temp)
          @@global = @@global.parent
        end
        match(:else_if_statement)
      end

      rule :else_if_statement do
        match(:else_if_statement, :if_statement)
        match(:else_if, :LPAREN, :logical, :RPAREN, :LBRACE, :block, :RBRACE) do |_s, _, cond, _, _, _, _|
          raise SproutElseError, @@syntax unless @@syntax.prev.tree.last.is_a? SproutCaseNode

          temp = SproutIfNode.new(cond, @@global, @@syntax)
          @@syntax = @@syntax.prev
          @@syntax.tree[-1].append_statement(temp)
          @@global = @@global.parent
        end
        match(:else_statement)
      end

      rule :else_statement do
        match(:else, :LBRACE, :block, :RBRACE) do |_s, _, _, _, _, _b, _|
          raise SproutElseError, @@syntax unless @@syntax.prev.tree.last.is_a? SproutCaseNode

          temp = SproutIfNode.new(true, @@global, @@syntax)
          @@syntax = @@syntax.prev
          @@syntax.tree.last.append_statement(temp)
          @@global = @@global.parent
        end
      end

      # ========== Loops ==========
      # Rules defining loops.
      # ===========================

      rule :loop do
        match(:while, :LPAREN, :logical, :RPAREN, :LBRACE, :block, :RBRACE) do |_, _, cond, _, _, _, _|
          temp = SproutWhile.new(cond, @@global, @@syntax)
          @@syntax = @@syntax.prev
          @@syntax.tree.append(temp)
          @@global = @@global.parent
        end

        match(:do, :LBRACE, :block, :RBRACE, :WHILE, :LPAREN, :logical, :RPAREN,
              :SEMICOLON) do |_, _, _, _, _, _, cond, _, _|
          temp = SproutDoWhile.new(cond, @@global, @@syntax)
          @@syntax = @@syntax.prev
          @@syntax.tree.append(temp)
          @@global = @@global.parent
        end

        match(:for, :LPAREN, :for_assign, :SEMICOLON, :logical, :SEMICOLON, :expr, :RPAREN, :LBRACE, :block,
              :RBRACE) do |_, _, assign, _, comp, _, expr, _, _, _, _|
          temp = SproutFor.new(assign, comp, expr, @@global, @@syntax)
          @@syntax = @@syntax.prev
          @@syntax.tree.append(temp)
          @@global = @@global.parent
        end

        # Specific assign for loops
        rule :for_assign do
          match(:var_name, :ASSIGN, :logical) do |a, _, b|
            SproutAssign.new(a, b, @@global)
          end
        end

        # ========== Logical nodes ==========
        # Logical nodes,
        # ===================================
        rule :logical do
          match(:logical, :operator_logic, :comparision) do |log, op, comp|
            SproutLogicNode.new(log, op, comp, @@global)
          end
          match(:comparision)
        end

        rule :comparision do
          match(:comparision, :operator_comp, :not) { |comp, op, val| SproutComparison.new(comp, op, val, @@global) }
          match(:not)
        end

        rule :not do
          match(:operator_not, :not) { |_, a| SproutNotNode.new(a, @@global) }
          match(:index)
        end

        rule :index do
          match(:str, :LBRACKET, :expr, :RBRACKET) do |a, _, b, _|
            SproutIndex.new(a, b, @@global)
          end
          match(:expr)
        end

        # ========== Arithmetic nodes ==========
        # Nodes for arithmetic operations, stru-
        # ctured after their mathematical prior-
        # ities.
        # ======================================
        rule :expr do
          match(:expr, :operator_basic, :adv) { |a, op, b| SproutArithmetic.new(a, op, b, @@global) }
          match(:expr, :INCREMENT) { |a, _| SproutArithmetic.new(a, '+', 1, @@global) }
          match(:expr, :PLUSEQ, :adv) do |a, _op, b|
            SproutArithmetic.new(a, '+', b, @@global)
          end
          match(:adv)
        end

        rule :adv do
          match(:adv, :operator_adv, :term) { |adv, op, term| SproutArithmetic.new(adv, op, term, @@global) }
          match(:term)
        end

        rule :term do
          match(:type, '^', :term) { |type, _, pow| SproutArithmetic.new(type, '**', pow, @@global) }
          match(:type)
        end

        # ========== Symbols to send-compatible operators ===========
        # We may need to convert some operators to a Ruby-compatible
        # format, and some operators just need to be translated into
        # strings for the send-method here.
        # ===========================================================

        rule :operator_logic do
          match(:AND) { '&' }
          match(:OR) { '|' }
        end

        rule :operator_not do
          match(:NOT) { '!' }
        end

        rule :operator_comp do
          match(:EQUAL) { '==' }
          match(:NEQUAL) { '!=' }
          match(:GREATERTHAN) { '>' }
          match(:GREATOREQ) { '>=' }
          match(:LESSTHAN) { '<' }
          match(:LESSOREQ) { '<=' }
        end

        rule :increment do
          match(:INCREMENT) { '++' }
          match(:PLUSEQ) { '+=' }
        end

        rule :operator_basic do
          match('+') { |m| m }
          match('-') { |m| m }
        end

        rule :operator_adv do
          match('*') { |m| m }
          match('/') { |m| m }
          match(:MODULO) { '%' }
        end

        # ========== Type ==========
        # Allows for chaining mathe-
        # matical nodes with parent-
        # heses
        # ==========================
        rule :type do
          match(:LPAREN, :logical, :RPAREN) { |_, m, _| m }
          match(:list)
          match(:data)
        end

        rule :list do
          match(:LBRACKET, :parameters, :RBRACKET) do |_, list, _|
            SproutList.new(list)
          end
        end

        # ========== Basic data nodes ==========
        # Generates the simplest form of data.
        # ======================================

        rule :data do
          match(:TRUE) { SproutBool.new(true) }
          match(:FALSE) { SproutBool.new(false) }
          match(Float) { |m| SproutFloat.new(m) }
          match(Integer) { |m| SproutInt.new(m) }
          match('-', Float) { |_, m| SproutFloat.new(m).negate }
          match('-', Integer) { |_, m| SproutInt.new(m).negate }
          match('-', String) { |_, m| SproutArithmetic.new(SproutInt.new(0), '-', m, @@global) }
          match(:LENGTH, :LPAREN, :type, :RPAREN) do |_, _, a, _|
            raise SproutLengthError unless a.is_a? SproutComplexData or a.is_a? String

            SproutLength.new(a, @@global)
          end
          match(:function_name, :LPAREN, :parameters, :RPAREN) do |n, _, p, _|
            SproutFunctionCall.new(n, p, @@global)
          end
          match(:str)
        end

        rule :str do
          match(/(".+?")/) { |m| SproutString.new(m) }
          match(String)
        end

        # ========== Scope management rules ==========
        # Due to how our parser operates, frames and
        # syntax-trees need to be generated when cert-
        # ain keywords appear. This is done in these
        # rules.
        # ============================================

        rule :function do
          match(:FUNCTION) do |m|
            raise StandardError unless @@global.parent == NilClass

            @@syntax = SyntaxTree.new(@@syntax)
            @@global = Frame.new(@@global)
            @@is_function = true
            m
          end
        end

        rule :while do
          match(:WHILE) do |m|
            @@syntax = SyntaxTree.new(@@syntax)
            @@global = Frame.new(@@global)
            m
          end
        end

        rule :do do
          match(:DO) do |m|
            @@syntax = SyntaxTree.new(@@syntax)
            @@global = Frame.new(@@global)
            m
          end
        end

        rule :for do
          match(:FOR) do |m|
            @@syntax = SyntaxTree.new(@@syntax)
            @@global = Frame.new(@@global)
            m
          end
        end

        rule :if do
          match(:IF) do |m|
            @@syntax = SyntaxTree.new(@@syntax)
            @@global = Frame.new(@@global)
            m
          end
        end

        rule :else_if do
          match(:ELSEIF) do |m|
            @@syntax = SyntaxTree.new(@@syntax)
            @@global = Frame.new(@@global)
            m
          end
        end

        rule :else do
          match(:ELSE) do |m|
            @@syntax = SyntaxTree.new(@@syntax)
            @@global = Frame.new(@@global)
            m
          end
        end
      end # end parser
    end # end initialize

    def log(state: false)
      @sprout_parser.logger.level = (state ? Logger::DEBUG : Logger::WARN)
    end

    def run(boolean)
      if boolean
        puts "\nSyntax tree:\n"
        pp @@syntax.tree
        puts "\n"
      end

      @@syntax.tree.each do |i|
        i.run
      end

      return if @@test_list.empty?

      total_tests = @@test_list.length
      successful_tests = 0
      puts
      puts '*-' * (IO.console.winsize[1] / 2)
      puts
      puts 'Program completed! Commencing tests...'
      @@test_list.each_with_index do |test, index|
        print "Test #{index} \t|\tTesting if #{test[0]} == #{test[1]}: \t"
        if test[0] == test[1]
          successful_tests += 1
          puts 'PASSED!'
        else
          puts 'FAILED!'
        end
      end
      puts
      puts '*-' * (IO.console.winsize[1] / 2)
      if total_tests == successful_tests
        puts 'All tests were successful!'
      else
        puts "Out of #{total_tests} tests, only #{successful_tests} tests succeeded. Please check your code to see what went wrong!"
      end
      puts
    end
  end
end
