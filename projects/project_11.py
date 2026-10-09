print("this is your personal homework planner")
print("you should have 4 homeworks as usual")

a=input("please enter your first homework:~"),
b=input("please enter your second homework:~"),
c=input("please enter your third homework:~"),
d=input("please enter your fourth homework:~"),


print("your homeworks are:", a,b,c,d)

hw_done = 0
index = 0
total_hw = 4 
taskno = 1

while taskno <= total_hw :
    x = input(f"is your {taskno} homework done?")
    if x == "yes" :
        hw_done = hw_done + 1
        taskno = taskno + 1
    else:
        print("please complete your homework")
print ("all your homeworks are done, you have completed", hw_done, "homeworks")





