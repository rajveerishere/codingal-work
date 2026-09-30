print("The original chore checker\n")

total = 5
print(f"You have {total} chores remaining \n")
nxt = "get ready for next task"
done = 0

while done < total:
   if done == 1:
      nxt = "get ready for school"
   elif done == 2:
      nxt = "have a nice school day"
   elif done == 3:
      nxt = "be ready for tuition"
   elif done == 4 :
      nxt = "go to bed"

   ques = input(f"have you completed {nxt} task  or not ?(yes/no) :")

   if ques == "yes" :
      print("nice work .. you have finished the work")
      if done == 4 :
         print("all the work is done !!!! \n great job")
      done += 1 
   else:
      print("try to finish the work fast ")

   print(f"you have {total - done} chores remaining .. ")

print("==============================================")
print("==================SUMMARY=====================")
print("==============================================")





    
