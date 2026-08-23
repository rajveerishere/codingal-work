ts = [130, 85, 160, 140, 135]
ts = sum(ts)
ap = ts / len(ts)

print("Total points:", ts)
print("Average per team:", ap)

stars_per_point = 2
reward_stars = ts * stars_per_point
print("Total reward stars:", reward_stars)

boxes = reward_stars // 25
leftover_stars = reward_stars % 25
print("boxes full:", boxes)
print("Left stars:", leftover_stars)

last_week = 500
print("Better than 7 days?", ts > last_week)
print("Same as last week?", ts == last_week)
print("at least you tried to keep up?", ts >= last_week)

ts += 30
print("After adding bonus points:", ts)

ts -= 15
print("After evaluatingmissed tasks:", ts)

final_reward_stars = ts * stars_per_point
final_boxes = final_reward_stars // 25
print("Final boxes packed:", final_boxes)
print("try to be better next week, you can do it!")

