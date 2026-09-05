x = 10 
y = 20
z = 5
a = 25
b = 50 
c = 100
v = (x/y)*(z/x)
n = v/x+z+a/b/c/v
print (v,n)

avg = (x+y+z+a+b+c)/6
rnd_num = x/z/y
if avg == rnd_num :
    print("value is right")
elif avg <= rnd_num or y >= 56 and n+v >= 10:
    print("well done")
else :
    print ("not well done")
print("=====================================")



