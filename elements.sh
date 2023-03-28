#!/bin/bash
if [[ -z $1 ]] 
then
  echo -e "Please provide an element as an argument."
  exit
fi

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Create conditional based on input type
if grep -q "^[0-9]*$" <<< $1
then
  # If the input is for the atomic_number
  CONDITION="elements.atomic_number = $1"
elif grep -q "^[A-Z][a-z]\?$" <<< $1
then 
  # If the input is for the symbol
  CONDITION="symbol='$1'"
else
  # If the input is for the name (i.e. any other string value)
  CONDITION="name='$1'"
fi

# Search database using condition
SEARCH_RESULTS="$($PSQL "SELECT elements.atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties ON elements.atomic_number = properties.atomic_number FULL JOIN types ON properties.type_id = types.type_id WHERE $CONDITION;")"

if [[ -z $SEARCH_RESULTS ]] 
then
  # If data not found
  OUTPUT="I could not find that element in the database."
else
  # If data in database, parse results into string for output
  IFS='|'
  read -a VALUES <<< $SEARCH_RESULTS
  IFS=' '

  OUTPUT="The element with atomic number "${VALUES[0]}" is "${VALUES[1]}" ("${VALUES[2]}"). It's a "${VALUES[3]}", with a mass of "${VALUES[4]}" amu. "${VALUES[1]}" has a melting point of "${VALUES[5]}" celsius and a boiling point of "${VALUES[6]}" celsius. "
fi

echo $OUTPUT
