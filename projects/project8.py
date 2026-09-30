print("welcom to identity checker programme")

print ("what are you? student/adult")

position = input("pls enter your position \n student/adult :")
no_kid_app = ("game","shop","browser","youtube","social media")

print (" state your name :")

name = input("what is your name? :")

print(f" you are {name}  a {position} ")

apps_for_student = ["food app","gallery","ai","camera","calculator"]

print("what app you want to use?")

if position == "student" :
    print(" you have a limited access to apps")

    print(f" you can use -- {apps_for_student}")

    selecapp = input("enter the app you want to use :")

    if selecapp in apps_for_student:

        print(f"you have selected {selecapp} which you are permitted to use")

    app2 = input("do you want to use any other app? yes/no")

    if app2 == "yes" :

        print(f"you can use only 2 apps at once 2nd app is \n {app2}")
    elif app2 == "no" :
        print(" you dont want to use 2nd app  \n be focused")
elif position == "adult":
    print("you have all acces")
    adu_app = input("enter the app you want to use")
    print(f"you have selected{adu_app}")

    adu_app1 = input("enter the app you want to use")
    print(f"you have selected{adu_app1}")

    adu_app2 = input("enter the app you want to use")
    print(f"you have selected{adu_app2}")

    adu_app3 = input("enter the app you want to use")
    print(f"you have selected{adu_app3}")

    print ("you can only use 4 app at a time max")
    print(f"the selected apps as an adult are {adu_app}, {adu_app1}, {adu_app2}, and {adu_app3}")

else:
    print("invalid position. Please restart and enter student or adult.")

print(f"your position is {position}")
print("type of the things --")

print("adult app type:", type(adu_app1))
print("the number of apps that you can use as adult in binary ")

print(bin(4))

print("the number of apps that you can use as student in binary ")

print(bin(2))
print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
print("1 for student ,10 for adult")
code = int(input("enter the code with respect to your position :"))

if code == 10 :
    print ("the apps you are using are \n all apps allowed")

no_kid_app = ("game","shop","browser","youtube","social media")

print(f"the apps avilable for you are \n{no_kid_app} and {apps_for_student}")

if code == 1 :
    print(f"your position is{position}")
    
    app_nono = input("enter another app name")

    if app_nono in (apps_for_student) :

        print (f"allow access to this app-{app_nono}")

    elif app_nono in (no_kid_app) :


        print("dont use this app kid")

    else:
        print("select an app from the permitted list next time")
print (f"the apps selected are {selecapp},{app2},{adu_app1},{adu_app2},{adu_app3},{adu_app}")
print("every variable with its type and binary value")

print("position", type(position))
print("name", type(name))
print("apps_for_student", type(apps_for_student))
print("selecapp", type(selecapp))
print("app2", type(app2))
print("adu_app", type(adu_app))
print("adu_app1", type(adu_app1))
print("adu_app2", type(adu_app2))
print("adu_app3", type(adu_app3))
print("code", type(code), bin(code))
print("no_kid_app", type(no_kid_app))
print("app_nono", type(app_nono))

print("bye done")









    