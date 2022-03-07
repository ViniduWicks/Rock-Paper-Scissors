// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title RockPaperScissors
 * @dev Rock Paper Scissors game to be played by a player once. Bet is determined by the balance of contract 
 */
contract RockPaperScissors {

    //Rules of the game. Contains the choice and the value beaten by the choice 
    mapping(string => string) private rules;

    //Owner of contract
    address private owner;

    //Result to see outcome of the game
    string public result = "Draw";

    //Balance of the contract
    uint256 public ContractBalance = address(this).balance;

    //Player and host choices and result of the game for viewing
    struct Game {
        string playerChoice;
        string hostChoice;
        string result;
    }
    //Array of games
    Game[] public games;

    /**
     * @dev Add the rules to the game.
     *      Set contract deployer as owner.
     */
    constructor() public {
        rules["ROCK"] = "SCISSORS";
        rules["PAPER"] = "ROCK";
        rules["SCISSORS"] = "PAPER";
        
        owner = msg.sender;
    }

    // modifier to check if user is owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can withdraw");
        _;
    }

    /**
     * @dev Fund contract by owner
     */
    function fundContract() public payable onlyOwner {}

    /**
     * @dev Get latest contract balance and assign to ContractBalance variable
     */
    function getContractBalance() public {
        ContractBalance =  address(this).balance;
    }

    /**
     * @dev Uses current time, sender address and sender balance to simulate a random number, and return a choice.
     * @return either ROCK, PAPER or SCISSORS
     */
    function getHostChoice() internal view returns(string memory){
        uint hostChoice =  uint256(keccak256(abi.encode(block.timestamp, msg.sender, address(msg.sender).balance))) / 1e74;
        if (hostChoice < 333) {
            return "ROCK";
        } else if (hostChoice < 666) {
            return "SCISSORS";
        } else {
            return "PAPER";
        }
    }

    /**
     * @dev Compares choice of player and host to return the result
     * @param playerChoice - choice of player, hostChoice - choice of host
     * @return -1 if player wins, 1 if host wins, or 0 is it's a draw 
     */
    function getResult(string memory playerChoice, string memory hostChoice) internal view returns(int8) {
        //string comparison to check if host beats player
        if (keccak256(bytes(rules[hostChoice])) == keccak256(bytes(playerChoice))) {
            return 1;
        } //string comparison to check if player beats host 
        else if (keccak256(bytes(rules[playerChoice])) == keccak256(bytes(hostChoice))) {
            return -1;
        }
        //return if draw 
        return 0;
    }

     /**
     * @dev Returns the value to player
     * @param value of ETH depending on result
     */
    function returnETHToPlayer(uint256 value) internal {
        payable(msg.sender).transfer(value);
    }

    /**
     * @dev Play function for processing the input from player and deciding on the result
     * If player wins, player gets twice the amount played with
     * If host wins, player gets nothing
     * If it's a draw, player gets the amount played with 
     * @param choice of player, either ROCK, PAPER or SCISSORS
     */
    function play(string memory choice) public payable {
        //Check if player input is either ROCK, PAPER or SCISSORS
        require(keccak256(bytes(choice)) == keccak256(bytes("ROCK")) || keccak256(bytes(choice)) == keccak256(bytes("SCISSORS")) || keccak256(bytes(choice)) == keccak256(bytes("PAPER")), "Please enter either ROCK, PAPER or SCISSORS");
        //Check if player uses some ETH to play
        require(msg.value > 0, "Please provide ETH to play");
        //Check if contract has enough funds to dispense if player wins
        require(address(this).balance > msg.value * 2, "Please bet lower than half of contract balance");
        //Get choice of host
        string memory hostChoice = getHostChoice();
        int8 res = getResult(choice, hostChoice);
        if (res == -1) {
            //Player won
            result = "You won";
            //Return twice the amount of ETH for player
            returnETHToPlayer(msg.value * 2);
        } else if (res == 1){
             //Host won
            result = "Host won";
        } else {
            result = "Draw";
            //Return the amount of ETH used for playing to player
            returnETHToPlayer(msg.value);
        }
        //Adds the game data for viewing
        games.push(Game(choice, hostChoice, result));
    }

    /**
     * @dev Withdraw all ETH from contract
     * Only owner is able to access this function
     */
    function withdrawAllETHFromContract() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}