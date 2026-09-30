
person_name = "Maya"

if type(person_name) is str:
    print("The student's name is text.")
else:
    print("The student's name is not text.")

test_grade = 87.5

if type(test_grade) is float:
    print("The quiz score has decimal numbers.")
else:
    print("The quiz score is not a decimal number.")

favorite_colors = ["red", "blue", "green"]
same_colors = favorite_colors

if favorite_colors is same_colors:
    print("Both names point to the same list.")
else:
    print("The lists are different objects.")

another_color_list = ["red", "blue", "green"]

if favorite_colors is not another_color_list:
    print("The new list is a different object.")
else:
    print("The new list is the same object.")