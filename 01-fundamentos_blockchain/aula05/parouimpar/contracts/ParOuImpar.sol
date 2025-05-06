// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ParOuImpar{

    struct GameData {
        uint8 choiceP1;
        uint8 numberP1;
        uint8 numberP2;
        uint8 lastWinner;
    }

    GameData public gameData;
    GameData public lastGameData;

    constructor(){
        gameData.choiceP1 = 0;
        gameData.numberP1 = 0;
        gameData.numberP2 = 0;
        gameData.lastWinner = 0;

        lastGameData = gameData;
    }

    function resetGameFields() private{
        lastGameData = gameData;

        gameData.choiceP1 = 0;
        gameData.numberP1 = 0;
        gameData.numberP2 = 0;
        gameData.lastWinner = 0;
    }

    function initGame (uint8 newChoice, uint8 numberP1) public {
        require(newChoice == 1 || newChoice == 2, "Choose 1 or 2");
        require(numberP1 > 0 && numberP1 <= 10, "Number choice must be between 1 and 10");
        gameData.choiceP1 = newChoice;
        gameData.numberP1 = numberP1;
    }

    function playGame (uint8 numberP2) public{

        require(gameData.choiceP1 != 0, "first choose your option: 1 = par, 2 = impar!");
        require(numberP2 > 0 && numberP2 <= 10, "Choose a number between 1 and 10");

        gameData.numberP2 = numberP2;

        bool isEven = (numberP2 + gameData.numberP1) % 2 == 0;

        if(isEven && gameData.choiceP1 == 2)
            gameData.lastWinner = 1;
         else if(!isEven && gameData.choiceP1 == 1)
            gameData.lastWinner = 1;
        else 
            gameData.lastWinner = 2;   

        resetGameFields();    
    }
}
