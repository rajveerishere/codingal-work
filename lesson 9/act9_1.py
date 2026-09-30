average_before = 42
number_of_values = 30
old_value = 27
new_value = 47

# Find the original total.
original_total = average_before * number_of_values
print("Original total:", original_total)

# Replace the incorrect value with the correct value.
change_in_total = new_value - old_value
updated_total = original_total + change_in_total
print("Updated total:", updated_total)

# Work out the new average.
average_after = updated_total / number_of_values
print("Correct average:", average_after)
