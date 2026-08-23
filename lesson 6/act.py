print("SMART SCHOOL DAY PLANNER")
print("hello! welcome to smart school day planner")

day = input ("pls enter todays day  :")
weather = input("please enter the weather today (sunny/rainy/cloudy):")
home = input("please enter your homework is done or not(yes/no):")
print("your this day's plan is - ")
if day == "sunday" or day == "saturday" :
    print("no need to study immedieately have a nice day and enjoy your weekend")
elif day in ("monday", "tuesday", "wednesday", "thursday", "friday"):
    if weather == "sunny":
        print("you can go out and play after school")
    else:
        print("you can stay at home and do your homework")
    if home == "yes":
        print("you can go out and play after school")
    else:
        print("you should complete your homework first before going out to play")

