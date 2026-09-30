print("hello!\n this is the holoday planner")
print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
weather = str(input("please enter the todys weather\n sunny/rainy"))
if weather == "sunny":
    print("you should go on a more open place")
    location = str(input("please enter the location you want to go\n beach/park"))
    if location == "beach":
        activity = str = (input("please enter the activity you want to do\n swimming/surfing"))
        if activity == "swimming":
            input("choose the outfit you want red-finned(10$) / blue-slim(7$)")
            if input == "red-finned":
                print("you have used your 10$")
            elif input == "blue-slim":
                print("you have used your 7$")
        elif activity == "surfing":
            input("choose the board you want turquise scooter-board(20$) / shark-board(12$)")
            if input == "turquise scooter-board":
                print("you have used your 20$")
            elif input == "shark-board":
                print("you have used your 12$")
    elif location == "park":
        actpark = str(input("please enter the activity you want to do\n hide and seek/football"))
        if actpark == "hide and seek":
            print("you spent 2 hrs here")
        elif actpark == "football":
            print("you spent 2.5 hrs here")
        actnext = str(input("what do you want to do as your another activity\n ice-cream/cycling"))
        if actnext == "ice-cream":
            x = str(input("what flavour do you want\n chocolate/dark chocolate ?"))
            if x == "chocolate":
                print("you have used your 5$")
            elif x == "dark chocolate":
                print("you have used your 7$")
        elif actnext == "cycling":
            print("you spent 1 hr here")
if weather == "rainy":
    print("you should go on a more closed place")
    location = str(input("please enter the location you want to go\n museum/cinema"))
    if location == "museum":
        actmuseum = str(input("please enter the activity you want to do\n art gallery/ancient history"))
        if actmuseum == "art gallery":
            print("you spent 1 hrs here")
        elif actmuseum == "ancient history":
            print("you spent 1.5 hrs here")
    elif location == "cinema":
        actcinema = str(input("please enter the activity you want to do\n action/comedy"))
        if actcinema == "action":
            print("you spent 2 hrs here")
        elif actcinema == "comedy":
            print("you spent 2.5 hrs here")
        actnext = str(input("what do you want to do as your another activity\n popcorn(2$)/soda(1.5$)"))
        if actnext == "popcorn":
            x = str(input("what flavour do you want\n buttered/salted ?"))
            print("you have used your 7$")
        elif actnext == "soda":
            print("you spent 1 hr here")
print(f"summary of your holiday :\n weather : {weather}\n location : {location}\n activity : {activity}\n")

