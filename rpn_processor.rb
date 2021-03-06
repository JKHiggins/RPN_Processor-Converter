OPERATORS = { '^' => 3, '*' => 2, '/' => 2, '+' => 1, '-' => 1 }

class RPN
  def self.calculate(expression)
    operands = []
    # Expect a value to be space delimited
    expression.split(/\s+/).each do |op|
      if OPERATORS.keys.include?(op)
        # If we find an operator we want to apply it to the previous 2 values in
        # the stack and push the result onto the stack.
        operands.push(apply_operator(operands, op))
      else
        # If we dont find an operator we just push the value onto the stack.
        operands.push(op.to_f)
      end
    end

    # Once we're done, theres only the result on the stack so we return it.
    operands.pop
  end

  def self.apply_operator(operands, operator)
    # Pop last 2 and apply the operator.
    operand2 = operands.pop
    operand1 = operands.pop

    # Convert a common exponent key to rubys specific one.
    if operator == "^"
      operator = "**"
    end

    # Apply the operator to the values here.
    operand1.send(operator.to_sym, operand2)
  end
end

class Infix
  def self.calculate(expression)
    # Expect a value to be space delimited and split it into an array of components.
    components = expression.gsub(/\s+/, " ").split(/\s+/)
    # Parse the split components.
    rpn_expression = parse(components)

    # Use our calculator that we made above to take the parsed infix expression.
    RPN.calculate(rpn_expression.join(' '))
  end

  def self.parse(expression_ops)
    # We're gonna use two stacks, one for staging(temp) and one
    # for the final result(rpn).
    rpn_stack = []
    temp_stack = []
    tracked_op = nil

    expression_ops.each do |op|
      # Push everything onto the temp stack for manipulation in the future.
      temp_stack.push(op)

      if OPERATORS.keys.include?(op)
        # Make sure we have a tracked op.
        if tracked_op.nil?
          tracked_op = op
        end

        # Compare precedence to enforce order of operations.
        if compare_precedence(OPERATORS[op], OPERATORS[tracked_op])
          # If the current operator is higher precedence than the tracked
          # we track the new operator and push the second value to the rpn
          # stack, leaving the previously tracked operator on the temp stack.
          stack_op = temp_stack.pop
          stack_val = temp_stack.pop
          tracked_op = op

          rpn_stack.push(stack_val)
          temp_stack.push(stack_op)
        else
          # If the current operator is lower precedence than the new operator
          # we pop 3, push the value(second location) followed by the
          # operator(third location) to the rpn stack.
          # A few safe assumptions about the state of the stack have been made
          # to make this work.
          # 1) We know if we find an operator there is always an operator 2 back in
          # the stack so we can pop back 3 to find it.
          # 2) We know if we find an operator there is always an operand 1 back in
          # the stack so we can pop back 2 to find it.
          # 3) We know if we find an operator that the head of the stack is an operator
          # so we can pop back 1 to find it.
          # 4) If we find a lighter operator it wont interfere with the operator
          # that is 2 back in the stack, so we can safely pop that operator onto
          # the rpn stack.
          stack_op = temp_stack.pop
          stack_val = temp_stack.pop
          stack_op2 = temp_stack.pop
          tracked_op = stack_op

          rpn_stack.push(stack_val)
          rpn_stack.push(stack_op2)
          temp_stack.push(stack_op)
        end
      end
    end

    # We know that the remaining stack is in the correct reverse order, so we
    # shovel the temp stack onto the rpn stack in reverse order.
    rpn_stack << temp_stack.reverse
    rpn_stack.flatten
  end

  # Compares precedence of operators, first >= second>
  def self.compare_precedence(curr_op, tracked_op)
    curr_op > tracked_op
  end
end

#  inputs
rpn_example1 = "1 1 -"
rpn_example2 = "5 3 2 * +"
rpn_example3 = "4 8 2 * 8 + -"
rpn_example4 = "1 1 9 * 0 + -"
rpn_example5 = "2 3 ^"
rpn_example6 = "1 2 120 * 63 / +"
rpn_example7 = "1 5 3 * 2 + -"

infix_example1 = "1 - 1"
infix_example2 = "5 + 3 * 2"
infix_example3 = "4 - 8 * 2 + 8"
infix_example4 = "1 - 1 * 9 + 0"
infix_example5 = "2 ^ 3"
infix_example6 = "1 + 2 * 120 / 63"
infix_example7 = "1 - 5 * 3 + 2"

complex_infix1 = "5 ^ 2 * 10 / 2 + 2 - 1"
complex_infix2 = "5 - 2 + 10 / 2 * 2 ^ 1"
complex_infix3 = "5 ^ 2 * 10 / 2 + 2 - 1 + 5 - 2 + 10 / 2 * 2 ^ 1"
#  inputs

#  answers
puts "\n\n\====== Polish ======\n\n"
puts "Expression: #{rpn_example1} = #{RPN.calculate(rpn_example1)}"
puts "Expression: #{rpn_example2} = #{RPN.calculate(rpn_example2)}"
puts "Expression: #{rpn_example3} = #{RPN.calculate(rpn_example3)}"
puts "Expression: #{rpn_example4} = #{RPN.calculate(rpn_example4)}"
puts "Expression: #{rpn_example5} = #{RPN.calculate(rpn_example5)}"
puts "Expression: #{rpn_example6} = #{RPN.calculate(rpn_example6)}"
puts "Expression: #{rpn_example7} = #{RPN.calculate(rpn_example7)}"

puts "\n\n\====== Infix ======\n\n"
puts "Expression: #{infix_example1} = #{Infix.calculate(infix_example1)}"
puts "Expression: #{infix_example2} = #{Infix.calculate(infix_example2)}"
puts "Expression: #{infix_example3} = #{Infix.calculate(infix_example3)}"
puts "Expression: #{infix_example4} = #{Infix.calculate(infix_example4)}"
puts "Expression: #{infix_example5} = #{Infix.calculate(infix_example5)}"
puts "Expression: #{infix_example6} = #{Infix.calculate(infix_example6)}"
puts "Expression: #{infix_example7} = #{Infix.calculate(infix_example7)}"

puts "\n\n====== More Complicated Infix ======\n\n"
puts "Expression: #{complex_infix1} = #{Infix.calculate(complex_infix1)}"
puts "Expression: #{complex_infix2} = #{Infix.calculate(complex_infix2)}"
puts "Expression: #{complex_infix3} = #{Infix.calculate(complex_infix3)}"
#  answers

#  for if you want to test more edge cases
expression = ''
while expression != 'exit'
  puts "\nEnter an infix expression(or exit to be done): "
  expression = gets.tr("\n", '')
  if expression != 'exit'
    puts "\nAnswer: #{Infix.calculate(expression)}"
  end
end

