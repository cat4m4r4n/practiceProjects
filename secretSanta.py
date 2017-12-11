#this is a practice exercise in python 3; if using python 2.X then change input to raw_input
#this script prompts the user to enter in players for secret santa gift giving
#no players are matched to themselves
#there is no input validation and no reset; if you mess up player entry names then you have to kill it or go through the whole thing and restart

import numpy as np
import random
import itertools
import csv

#welcome message and get number of players
print("Welcome to the Secret Santa generator!")
num_players = input("How many players? Enter a number: ")
print("OK so there will be " + num_players + " players.")
num_players = int(num_players)
player_list = []

#get names of each player from user input
i = 0
while i < num_players:
    new_name = input ("\nEnter player name: ")
    player_list.append(new_name)
    print("\nCurrent players are: ")
    for player in player_list:
        print player
    i = i + 1

#function for making unique pairs of giver and receiver
def valid(giver_list, receiver_list):
    for i, j in itertools.izip(giver_list, receiver_list):
        if i == j: return False
    return True
#create lists of givers and receivers
giver_list = list(player_list)
receiver_list = list(player_list)
#randomize order of the giver and receiver lists
while not valid(giver_list,receiver_list):
    random.shuffle(giver_list)
    random.shuffle(receiver_list)

#create pairs
gifting_pairs = []
for i,j in itertools.izip(giver_list,receiver_list):
    pair =(i,j)
    gifting_pairs.append(pair)
#save final lists
giver_list = [x[0] for x in gifting_pairs]
receiver_list = [x[1] for x in gifting_pairs]

#write givers to a file
with open("secretSanta_givers.csv", "w") as f:
    f.write('\n'.join(giver_list))
f.close()

#write receivers to a file
with open("secretSanta_receivers.csv", "w") as f2:
    f2.write('\n'.join(receiver_list))
f2.close()

#display results
counter = 0
while counter < num_players:
    input("\nHello, " + giver_list[counter] +"! Please press enter to draw a name.")
    print("You are the Secret Santa for: " + receiver_list[counter])
    input("Press enter to clear the screen and then pass the device to the next person.")
    print("\n" * 50)
    counter = counter + 1
print("Thanks for playing! If you forget who you are the Secret Santa for, please contact Catherine.")