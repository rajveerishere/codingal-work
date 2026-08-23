#The out fit picker
print("Welcome to the outfit picker!")
tmp = int(input("please enter the temprature today:"))
if tmp>22:
   print("Wear airy clothes like normal t-shirt")
else: 
   print("Weather is cold wear some warm cloths")
wnd = int(input("please enter the approx wind speed at your area in kms:"))
if wnd>25:
   print("The weather is very windy , \n please carry warm cloths and a cap")
else:
   print("The winds are clam, \n and you can carry a cap ")
cloudy = str(input("please enter, is it cloudy or not at your area(type only - yes/no):"))
if cloudy == "yes":
   print("There could be puddles and rain carry a raincoat and gumboots if possible")
else:
   print("There are less chances of the rain, \n and low wind speed so wear your regular cloths")

print ("so you should wear(summary)")
if tmp>22:
    print("Wear airy clothes like normal t-shirt")
if tmp<22:
   print("waer warm cloths instead of the regular ones")
if wnd>25:
   print("The the weather is windy carry thick cloths")
else:
   print("The weather is normal wear normally")
if cloudy == "yes":
   print("It might rain wear a raincoat try to carry gumboots")
else:
   print("The weather is clear and try to wear the normal cloths to be comfortabel")
feedback = int(input("please rate the outfit selector out of 10 (x/10):"))
print(f"so your feedback was {feedback}/10,\n thankyou for your feedback user")
print("have a nice day")




