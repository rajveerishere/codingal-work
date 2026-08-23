print("~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~")
tmp = int(input("Enter temperature today in Celsius: "))

if tmp < 20:
    act = " reading"
    print("It is cold today.")
    print("Do", act)
else:
    act = "play outdoors "
    print("The weather is warm today.")
    print("Do", act)

rain = input("Is it raining today ? (yes/no): ")

if rain == "yes":
    print("Choose an activity indoors or else carry an umbrella!")

hw_time = int(input("Enter homework time in minutes: "))

if hw_time > 60:
    needs_break = "yes"
    print("You are studying for long today.")
    print("Take a break before your", act)
else:
    needs_break = "no"
    print("Homework time is short today.")
    print(" you shouldnt need any breaks", act)

ft = input("Do you have free time today ? (yes/no): ")

if ft == "yes":
    final_task = "hobby time"
    print("You have free time today.")
    print("Enjoy your", final_task)
else:
    final_task = "planning time"
    print("You have less free time.")
    print("utilise some time for", final_task)

print("")
print("Daily activity checking!")

print(" DAILY ACTIVITY PLANNER ")
print("=========================")
print("Temperature:", tmp)
print("=========================")
print("Activity Chosen:", act)
print("=========================")
print("Raining:", rain)
print("=========================")
print("Study Break :", needs_break)
print("=========================")
print("Final Task:", final_task)
print("~~~~~~~~~~~~~~~~~~~~~~~~~")

