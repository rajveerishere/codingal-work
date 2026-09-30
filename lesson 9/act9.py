print("the divisibility checker")
x = input("please enter your numerator or the number on the upper side of the divider line")
y = input("please enter your denominator or the number on the down side of the divider line")
division = x%y
division2 = x/y
print("print the quotiont is " , division2)
if division == 0 :
    print("the number is divisible")
else :
    print("this number is not divisible")