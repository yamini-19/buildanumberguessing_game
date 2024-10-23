#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

if [[ ${#USERNAME} -gt 22 ]]; then
  echo "Username cannot exceed 22 characters. Please try again."
  exit 1
fi

USER_INFO=$($PSQL "SELECT COUNT(*), MIN(guesses) FROM games WHERE username = '$USERNAME';")
GAMES_PLAYED=$(echo $USER_INFO | cut -d ' ' -f 1)
BEST_GAME=$(echo $USER_INFO | cut -d ' ' -f 2)

if [[ $GAMES_PLAYED -gt 0 ]]; then
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
while true; do
  read GUESS

  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

$PSQL "INSERT INTO games (username, guesses) VALUES ('$USERNAME', $NUMBER_OF_GUESSES);"
