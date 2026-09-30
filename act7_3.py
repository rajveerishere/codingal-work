print("Enter Marks:")

first_mark = int(input())
second_mark = int(input())
third_mark = int(input())
fourth_mark = int(input())
fifth_mark = int(input())

total_marks = first_mark
total_marks = total_marks + second_mark
total_marks = total_marks + third_mark
total_marks = total_marks + fourth_mark
total_marks = total_marks + fifth_mark
average_mark = total_marks // 5

if average_mark < 0 or average_mark > 100:
    print("Invalid input!")

elif average_mark >= 91:
    print("Your grade is best")

elif average_mark >= 81:
    print("Your grade is nicer")

elif average_mark >= 71:
    print("Your grade is great")

elif average_mark >= 61:
    print("Your grade is okay")

elif average_mark >= 51:
    print("Your grade is can be better")

else:
    print("Your grade is bad") 