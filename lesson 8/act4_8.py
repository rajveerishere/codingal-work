print(" This is mean calculator ")
cycl1 = int(input("pls enter the speed of 1st cyclist in kms :"))
cycl2 = int(input("pls enter the speed of 2nd cyclist in kms :") )
cycl3 = int(input("pls enter the speed of 3rd cyclist in kms :")  )
print("Here is the mean speed")
avgspeed = (cycl1 + cycl2 + cycl3)/3
print(f"mean speed is{avgspeed}")
if cycl1 > avgspeed :
    print("The 1st cyclist is faster than average")
else :
    print("1st one slower than average")
if cycl2 > avgspeed :
    print("The 2nd cyclist is faster than average")
else :
    print("2nd one slower than average")
if cycl3 > avgspeed :
    print("The 3rd cyclist is faster than average")
else :
    print(" 3rd one is slower than average")
print("the slower cyclists are - ")
if cycl1 < avgspeed :
    print("1st cyclist")
if cycl2 < avgspeed :
    print("2nd cyclist")
if cycl3 < avgspeed :
    print("3rd cyclist")
print("This was the \n SPEED CHECKER")

    



