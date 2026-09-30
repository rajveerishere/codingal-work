print("================================")
print(" welcome to custom banner maker")
print("================================")
print("please enter your vehical type")
x = int(input("for car type 1 \n for bike press 2 :"))
y = input("enter the type of vehical you have\n for big vehical enter 1 \n for small vehical enter 2 \n for super vehical enter 3 :")
if x == 1 :
    if y == 1:
        print("big car is nice use for vacation \n 6 seats \n 130 kmph")
        print("1 is big car")
    elif y == 2 :
        print("you have a small car use in city \n 4 seats \n 110 kmph")
        print("2 is small car")
    elif y == 3:
        print("you have a super car enjoy speed \n 2 seats \n 240 kmph")
        print("3 is super car")
    else : 
        print(" not this 1,2,3  only :)")
elif x == 2 :
    if y == 1:
        print("big bike is nice for vacation \n 2 seats \n 90 kmph")
    elif y == 2 :
        print("you have a small bike use in city \n 2 seats \n 80 kmph")
    elif y == 3:
        print("you have a super bike enjoy speed \n 2 seats \n 300 kmph")
    else : 
        print(" not this 1,2,3  only :)")
else :
    print("only integers 1,2,3 ")
print(f"you have a {x} vehical and its type is {y}")
    