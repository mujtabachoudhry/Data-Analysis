#while and for loops
    #while loops
    #syntax:
    # initialize a variable
    #while <condition>:
        #do something
        #increment/decrement the variable
    


# x=0 #initialize the variable
# while (x<=5): #while the condition is true
#     print(x)
#     x+=1 #increment the variable


# for i in range(5,10):
#     print(i)

# array
days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
for day in days:
    # if (day=="Sat"):break # break the loop if the condition is true
    if (day=="Sat"):continue # skip saturday
    print(day)