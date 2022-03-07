const rules = {
  ROCK: "SCISSORS",
  PAPER: "ROCK",
  SCISSORS: "PAPER",
};

const getChoice = () => {
  let choice = Math.floor(Math.random() * 1000);
  if (choice < 333) {
    return "ROCK";
  } else if (choice < 666) {
    return "SCISSORS";
  } else {
    return "PAPER";
  }
};

const getResult = (playerChoice, hostChoice) => {
  if (rules[hostChoice] == playerChoice) return 1;
  else if (rules[playerChoice] == hostChoice) return -1;
  else return 0;
};

module.exports = {
  getChoice,
  getResult,
};
