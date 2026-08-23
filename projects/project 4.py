
nm = input("Enter your name, Club Member: ")
cb = input("Enter your school club name: ")
rank = input("enter your rank in the club:")
print(f"you are {nm} from {cb} at rank {rank}")
 

member_number = 12
points_earned = 20.7
event_count = 7
meeting_hours = 3
is_active = True

print("Name:", nm, "-> type:", type(nm))
print("Club:", cb, "-> type:", type(cb))
print("Member Number:", member_number, "-> type:", type(member_number))
print("Points Earned:", points_earned, "-> type:", type(points_earned))
print("Event Count:", event_count, "-> type:", type(event_count))
print("Meeting Hours:", meeting_hours, "-> type:", type(meeting_hours))
print("Is Active:", is_active, "-> type:", type(is_active))

member_number_text = str(member_number)
event_count_text = str(event_count)
points_text = str(points_earned)
meeting_hours_text = str(meeting_hours)
status_text = str(is_active)

print("Member Number as text:", member_number_text, "-> type:", type(member_number_text))
print("Event Count as text:", event_count_text, "-> type:", type(event_count_text))
print("Points as text:", points_text, "-> type:", type(points_text))
print("Meeting Hours as text:", meeting_hours_text, "-> type:", type(meeting_hours_text))
print("Status as text:", status_text, "-> type:", type(status_text))

first_four = nm[0:4]
last_letter = nm[-1:]
badge_code = first_four + last_letter

print("First 4 letters of name:", first_four)
print("Last letter of name:", last_letter)
print("Badge Code:", badge_code)

reversed_club = cb[::-1]
print("Reversed Club Name:", reversed_club)

badge_line_1 = "CLUB MEMBER " + badge_code.upper()
badge_line_2 = "ID: " + member_number_text + " | EVENTS: " + event_count_text
badge_line_3 = "POINTS: " + points_text + " | ACTIVE: " + status_text
badge_line_4 = "SECRET CLUB CODE: " + reversed_club.upper()

print("")
print("===== SCHOOL CLUB MEMBER BADGE ======")
print(badge_line_1)
print(badge_line_2)
print(badge_line_3)
print(badge_line_4)
print("have a great day!")
print("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=")
