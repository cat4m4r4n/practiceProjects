import numpy as np
import random
import itertools

print("Welcome to the Secret Santa generator!")
num_players = raw_input("How many players? Enter a number: ")
print("OK so there will be " + num_players + " players.")
num_players = int(num_players)
player_list = []

i = 0
while i < num_players:
    new_name = raw_input ("\nEnter player name: ")
    player_list.append(new_name)
    print("Current players are: ")
    for player in player_list:
        print player
    i = i + 1

def valid(giver_list, receiver_list):
    for i, j in itertools.izip(giver_list, receiver_list):
        if i == j: return False
    return True

giver_list = list(player_list)
receiver_list = list(player_list)

while not valid(giver_list,receiver_list):
    random.shuffle(giver_list)
    random.shuffle(receiver_list)

gifting_pairs = []
for i,j in itertools.izip(giver_list,receiver_list):
    pair =(i,j)
    gifting_pairs.append(pair)

giver_list = [x[0] for x in gifting_pairs]
receiver_list = [x[1] for x in gifting_pairs]

counter = 0
while counter < num_players:
    raw_input("\nHello, " + giver_list[counter] +"! Please press enter to draw a name.")
    print("You are the Secret Santa for: " + receiver_list[counter])
    raw_input("Press enter to clear the screen and then pass the device to the next person.")
    print("\n" * 50)
    counter = counter + 1
print("Thanks for playing! If you forget who you are the Secret Santa for, please contact Catherine.")