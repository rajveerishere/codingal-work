#hi 
print("welcome to your harvest manager")

f1 = 800
f2 = 1100
f3 =1200
f4 = 1500
f5 = 1000
total = f1+f3+f2+f4+f5 
print(f"your total harvet is {total}")
avg = total/5
print (f"your each feilds average is {avg} ")

rate_kg = 50 
total_income = 50*total
print(f"rate today avg is {rate_kg} , your total income is {total_income}")
sack_space = 30
sacks_needed = total//sack_space
extra = total%sack_space
print(f"one sack holds {sack_space} kg , you will need {sacks_needed} sacks ")
print(f"you will have {extra} kg left")



