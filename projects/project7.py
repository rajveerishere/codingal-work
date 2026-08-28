
print(" Library Visit Planner ")
print("Planning your library visit\n")

de = input("What day is it ? (Monday to Saturday): ").strip().capitalize()
wthr   = input("What is the weather? (sunny / rainy / cloudy/snowy): ").strip().lower()
book_due  = input("Do you want to return a book ? (yes / no): ").strip().lower()

print()
print(f" Your Library Plan is for {de} ")
print("~=~=~=" * 6)

if de in ("Saturday",):
    print("Day type    : Weekend - nice time to visit library!")
elif de == "Monday":
    print("Day type    : Start of the week.its busy around check your list.")
elif de == "Friday":
    print("Day type    : Last school day.please return the books.")
elif de in ("Tuesday", "Wednesday", "Thursday"):
    print("Day type    : Regular school day , busy for library and you too make it fast.")
else:
    print("Day type    : Day not recognised.correct the spelling of day.")

if wthr == "sunny" and book_due == "yes":
    print("Library tip :today is great weather please return your book.")

if wthr == "rainy" or wthr == "cloudy":
    print("Weather tip : Carry an umbrella for a walk to library.")

if not (book_due == "yes"):
    print("Book status : No book return needed today. You can browse new books.") 

if wthr == "rainy" and book_due == "yes":
    print("Best plan   : Visit the library carefully and return your book on time.")
elif wthr == "sunny" and book_due == "yes" and not (de in ("Saturday", "Sunday")):
    print("Best plan   : Stop by the library after school and return your book.")
elif de in ("Saturday", "Sunday") and wthr == "sunny":
    print("Best plan   : Perfect day for a longer reading session at the library!")
else:
    print("Best plan   : Check your schedule and plan a visit asap.")
print(f"so your visit is on {de}, weather will be {wthr}")
if book_due == "yes":
    print("return the book asap or we will get it")
else:
    print("you dont have any books pending nice job kiddo")
print()
print("Library plan complete! Happy reading!")
