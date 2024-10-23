#!/bin/bash

# Set the PSQL variable for querying the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read USERNAME

# Validate username length
if [[ ${#USERNAME} -gt 22 ]]; then
  echo "Username cannot exceed 22 characters. Please try again."
  exit 1
fi

# Check if the user exists in the database
USER_INFO=$($PSQL "SELECT COUNT(*), MIN(guesses) FROM games WHERE username = '$USERNAME';")
GAMES_PLAYED=$(echo $USER_INFO | cut -d ' ' -f 1)
BEST_GAME=$(echo $USER_INFO | cut -d ' ' -f 2)

# Provide feedback based on user status
if [[ $GAMES_PLAYED -gt 0 ]]; then
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

# Generate a random secret number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

# Start guessing
echo "Guess the secret number between 1 and 1000:"
while true; do
  read GUESS

  # Check if input is an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  # Compare guess to secret number
  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    # Print the final message when guessed correctly
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

# Save the game result
$PSQL "INSERT INTO games (username, guesses) VALUES ('$USERNAME', $NUMBER_OF_GUESSES);"
